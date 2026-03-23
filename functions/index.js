const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

function compactTokens(tokens) {
  return [...new Set((tokens || []).filter((token) => typeof token === 'string' && token))];
}

async function getUserTokens(uid) {
  if (!uid) {
    return [];
  }

  const snapshot = await db.collection('users').doc(uid).get();
  return compactTokens(snapshot.data()?.fcmTokens);
}

async function removeInvalidTokens(uid, invalidTokens) {
  if (!uid || invalidTokens.length === 0) {
    return;
  }

  await db.collection('users').doc(uid).set(
    {
      fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

async function clearActiveSession(uid) {
  if (!uid) {
    return;
  }

  await db.collection('users').doc(uid).set(
    {
      activeCustomerQueueId: admin.firestore.FieldValue.delete(),
      activeCustomerTokenId: admin.firestore.FieldValue.delete(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

async function sendUserNotification({ uid, title, body, data = {} }) {
  const tokens = await getUserTokens(uid);
  if (tokens.length === 0) {
    return;
  }

  const response = await messaging.sendEachForMulticast({
    tokens,
    notification: { title, body },
    data,
  });

  const invalidTokens = [];
  response.responses.forEach((result, index) => {
    if (!result.success) {
      invalidTokens.push(tokens[index]);
    }
  });

  await removeInvalidTokens(uid, invalidTokens);
}

async function notifyWaitingCustomers({ queueId, queueName, title, body, type }) {
  const snapshot = await db
    .collection('tokens')
    .where('queueId', '==', queueId)
    .where('status', '==', 'waiting')
    .get();

  for (const doc of snapshot.docs) {
    const token = doc.data();
    await sendUserNotification({
      uid: token.userId,
      title,
      body,
      data: {
        queueId,
        tokenId: doc.id,
        type,
      },
    });
  }
}

exports.notifyQueueUpdates = onDocumentUpdated('queues/{queueId}', async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();

  if (!before || !after) {
    return;
  }

  const queueId = event.params.queueId;
  const queueName = after.name || 'your queue';

  if (before.currentToken !== after.currentToken) {
    const nearTurnSnapshot = await db
      .collection('tokens')
      .where('queueId', '==', queueId)
      .where('status', '==', 'waiting')
      .where('tokenNumber', '>', after.currentToken)
      .where('tokenNumber', '<=', after.currentToken + 2)
      .get();

    for (const doc of nearTurnSnapshot.docs) {
      const token = doc.data();
      if (token.nearTurnNotificationSentAt) {
        continue;
      }

      const peopleAhead = Math.max(0, token.tokenNumber - after.currentToken - 1);
      const body =
        peopleAhead <= 0
          ? `Token ${token.tokenNumber} can be served now at ${queueName}.`
          : `Token ${token.tokenNumber} has ${peopleAhead} turns left at ${queueName}.`;

      await sendUserNotification({
        uid: token.userId,
        title: 'QueueLess alert',
        body,
        data: {
          queueId,
          tokenId: doc.id,
          type: 'near_turn',
        },
      });

      await doc.ref.update({
        nearTurnNotificationSentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }

  if (before.status !== after.status && after.status === 'paused') {
    await notifyWaitingCustomers({
      queueId,
      queueName,
      title: 'Queue paused',
      body: `${queueName} is temporarily paused. QueueLess will notify you when service moves again.`,
      type: 'queue_paused',
    });
  }

  if (before.status !== after.status && after.status === 'ended') {
    await notifyWaitingCustomers({
      queueId,
      queueName,
      title: 'Queue ended',
      body: `${queueName} has ended. Please check the app for the latest status.`,
      type: 'queue_ended',
    });
  }
});

exports.notifyTokenServed = onDocumentUpdated('tokens/{tokenId}', async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();

  if (!before || !after) {
    return;
  }

  if (before.status === after.status || after.status !== 'served' || after.servedNotificationSentAt) {
    return;
  }

  const queueSnapshot = await db.collection('queues').doc(after.queueId).get();
  const queueName = queueSnapshot.data()?.name || 'your queue';

  await sendUserNotification({
    uid: after.userId,
    title: 'Token served',
    body: `Token ${after.tokenNumber} has been served at ${queueName}.`,
    data: {
      queueId: after.queueId,
      tokenId: event.params.tokenId,
      type: 'token_served',
    },
  });

  await clearActiveSession(after.userId);

  await event.data.after.ref.update({
    servedNotificationSentAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});
