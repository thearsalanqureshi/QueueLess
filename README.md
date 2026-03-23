# QueueLess

An AI-powered Flutter mobile application that helps businesses manage customer queues digitally and allows customers to join queues remotely without waiting physically.

---

# Project Overview
QueueLess is a lightweight smart queue management system built with Flutter.  
It allows customers to **join queues remotely**, track their **live token status**, and receive notifications when their turn is near.

The app also provides **AI-powered insights and wait-time predictions** to help businesses reduce crowding, optimize service time, and improve customer experience.

---

# Problem Statement
Many businesses still manage queues manually. This leads to:

- Long waiting times
- Crowded waiting areas
- Poor customer experience
- Inefficient service management
- Customers leaving before their turn

Customers waste time waiting, while businesses struggle to handle peak hours effectively.

---

# Solution
QueueLess introduces a **digital token system** where customers can join queues using their mobile phones and monitor their position in real time.

AI features analyze queue data to provide:

- smarter wait-time predictions
- business insights
- queue optimization suggestions
- conversational queue assistance

---

# Key Features

### Join Queue
Customers can enter a **Queue ID or scan QR code** to join a queue instantly.

### Create Queue (Admin)
Businesses can create and manage queues from their mobile device.

### Live Queue Status
Users can see:

- current serving token
- their token number
- number of people ahead
- estimated waiting time

### Smart Notifications
Users receive notifications when **their turn is approaching (2 tokens left).**

### AI Queue Assistant
Customers can ask questions like:

- "How long will my wait be?"
- "When should I come back?"

The AI replies using real-time queue data.

### Smart Wait-Time Prediction
AI estimates waiting time based on:

- number of people ahead
- average service duration
- current serving speed

### AI Business Insights
Admin dashboard shows simple analytics such as:

- customers served
- average service time
- busiest hours
- queue performance insights

### Queue Optimization Suggestions
AI suggests operational improvements such as:

- opening another counter
- adjusting service flow during peak hours

### Queue History
Recent queues are stored locally for quick rejoining.

### Offline Token Mode
Users can still generate tokens locally when network connectivity is unstable.

---

# Tech Stack

## Frontend
Flutter (Material UI)

## Backend
Firebase Firestore – Real-time queue updates

## AI
Google Gemini API – intelligent queue insights and assistant

## Local Storage
Hive – queue history and offline token support

## State Management
Riverpod

## Architecture
MVVM (Model – View – ViewModel)

---

# App Flow

Splash Screen  
→ Onboarding  
→ Home Screen  

Home Options:

Join Queue  
→ Enter Queue ID / Scan QR  
→ Queue Status Screen

Create Queue (Admin)  
→ Admin Dashboard  
→ Serve Next Token / Pause Queue / End Queue

---

# Development Timeline

### Phase 1
Project architecture setup  
MVVM structure implementation

### Phase 2
Core queue system development  
Token generation and serving logic

### Phase 3
Firestore real-time synchronization

### Phase 4
Gemini AI integration

### Phase 5
Hive local storage and offline support

### Phase 6
Firebase notifications and production optimization

### Phase 7
Testing, bug fixes, and Play Store deployment

---

# Challenges & Solutions

| Challenge | Solution |
|--------|--------|
| Real-time queue updates | Implemented Firestore streams for instant updates |
| Wait-time accuracy | AI prediction based on average service duration |
| Network interruptions | Offline token fallback with Hive storage |
| Queue congestion | AI queue optimization suggestions |
| User confusion | Minimal and clean UI design |

---

# Key Learnings

- Riverpod enables scalable and maintainable state management.
- Firestore streams are highly effective for real-time systems.
- AI insights significantly improve operational decisions.
- Clean UI design improves usability for both customers and businesses.
- Offline storage is important for reliability in unstable networks.

---

# Future Improvements

- Multi-counter queue system
- QR-based instant queue joining
- Advanced analytics dashboard
- Web dashboard for businesses
- Multi-branch queue management
- AI demand prediction

---

# Target Use Cases

QueueLess can be used by:

- Clinics and hospitals
- Banks
- Salons and barbershops
- Government offices
- Repair service centers
- Pharmacies
- Universities

---

# Deployment

Target Platform:

Android (Google Play Store)

---

# Author
Flutter Mobile Application Project