# QueueLess

QueueLess is an AI-powered Flutter mobile application for digital queue management. It lets customers join queues remotely, track live token progress, and ask queue-related questions, while admins can create queues, manage service flow, and review AI-generated operational insights.

## Project Overview

Manual queue handling leads to long wait times, crowded waiting areas, and poor service visibility. QueueLess replaces physical waiting with a real-time digital token system backed by Firebase Firestore and local persistence through Hive.

The app follows a role-first flow:

- Splash
- Onboarding
- Role Selection
- Customer flow or Admin flow

## Problem Statement

Many businesses still manage queues manually. That creates:

- Long and uncertain waiting times
- Crowded service areas
- Poor customer experience
- Weak service visibility for admins
- Lost customers during peak demand

## Solution

QueueLess provides:

- Real-time digital token management
- Role-based customer and admin experiences
- Firestore-powered live queue synchronization
- AI wait-time predictions and queue assistance
- Admin insights and optimization suggestions
- Hive-backed local history and session recovery

## Core Features

### Customer Features

- Join a queue with a queue ID or QR code
- Track current token, people ahead, and estimated wait time
- Receive near-turn alerts when 2 turns are left
- Use a dedicated AI Queue Assistant screen
- Review queue history and reopen active sessions
- Recover active sessions after app relaunch

### Admin Features

- Create a new queue with average service time
- Share queue access through queue ID and QR code
- Serve next token
- Pause and resume the queue
- End the queue
- View AI insights
- Review admin analytics and queue history

### AI Features

- Natural-language Queue Assistant for customers
- Smart wait-time prediction
- AI business insights for admins
- Queue optimization suggestions when wait time grows too long

## Tech Stack

- Flutter
- Material UI
- Riverpod
- Firebase Firestore
- Firebase Authentication (Anonymous Auth)
- Firebase Cloud Messaging
- Hive
- Google Gemini API
- GoRouter

## Architecture

The app uses a clean MVVM structure with clear separation of UI, state, and data access.

- `lib/models` - domain models
- `lib/viewmodels` - Riverpod state and feature logic
- `lib/repositories` - Firestore, analytics, history, and session logic
- `lib/core/services` - Firebase, notifications, Hive, identity, bootstrap, Gemini
- `lib/views` - feature screens
- `lib/widgets` - reusable UI building blocks
- `functions` - Firebase Cloud Functions for backend notifications

## App Flow

### Customer Flow

- Splash
- Onboarding
- Role Selection
- Customer Home
- Join Queue
- Queue Status
- AI Queue Assistant
- Queue Completed
- Customer History

### Admin Flow

- Splash
- Onboarding
- Role Selection
- Admin Home
- Create Queue
- Admin Dashboard
- AI Insights
- Analytics and History

## Firebase Data Model

The project uses these primary collections:

- `users/{uid}` - role, FCM tokens, active customer session, last admin queue
- `queues/{queueId}` - queue metadata, admin ownership, status, counters
- `tokens/{tokenId}` - queue membership, token status, notification bookkeeping

## Project Structure

```text
lib/
  core/
  models/
  providers/
  repositories/
  storage/
  viewmodels/
  views/
  widgets/
functions/
test/
firebase.json
firestore.rules
firestore.indexes.json
```

## Firebase Setup

1. Create or use a Firebase project.
2. Enable:
   - Firestore
   - Anonymous Authentication
   - Cloud Messaging
3. Add `google-services.json` to `android/app/`.
4. Deploy Firestore rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```


## Current Status

Implemented in the repository:

- Role-first navigation flow
- Customer and admin dashboards
- Real-time queue logic with Firestore
- Hive-backed history and session recovery
- AI assistant and admin insights
- Firestore rules and indexes
- Cloud Functions source for backend notifications

Deployment status depends on your Firebase plan:

- Firestore deployment is supported on Spark
- Cloud Functions deployment requires Blaze


