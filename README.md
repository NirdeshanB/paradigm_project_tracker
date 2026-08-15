# Paradigm Project Tracker

<p align="center">
  <img src="assets/images/logo.png" alt="Paradigm Projects Logo" width="180"/>
</p>

An internal CRM and project management mobile application built for **Paradigm Digital Solutions**. The app provides team members with a unified dashboard to manage customer pipelines, track communications logs, schedule follow-ups, and receive targeted task reminders in real-time.

---

## 🚀 Key Premium Features

* **Real-time Synchronization**: Instant client updates, activity log trails, and team edits powered by a reactive Firebase Firestore backbone.
* **Lag-Free Theme Engine**: Toggle between high-contrast slate-dark mode and borderless clean light mode instantly. Caches lookups and layout frames to guarantee 60/120 FPS transitions.
* **Targeted Alarms & Reminders**: Real-time foreground alarm checks wake up screens and launch glassmorphic overlays complete with actions to complete or snooze.
* **Audio Alerts & Sound Mixer**: Plays native device looping alarm ringtones when reminder thresholds are reached. Features an inline sound mixer slider inside settings with audio-check preview chirps.
* **Assignee-Targeted Notifications**: Intelligent filters ensure loud audio alarms trigger strictly for the team member assigned to the project.
* **In-App Auto Update Checker**: Keeps the entire team on the latest software version automatically. Displays release notes and triggers browser downloads instantly.
* **Database-Driven Configurations**: Selector options, next action fields, and currency types update reactively from dynamic Firestore document modifications.

---

## 🛠️ Technology Stack

* **Framework**: Flutter (Dart SDK)
* **Backend**: Firebase Auth, Cloud Firestore
* **Notifications & Audio**: Flutter Ringtone Player (v4.x Plugin API)
* **Design Guidelines**: Material 3, Custom Typography (Inter & Outfit)

---

## 📦 Automating Team Version Updates (CI/CD Releases)

Instead of manually sending updated APKs to team members, the application utilizes a Firestore-driven **In-App Update Checker**:

1. Compile the updated release APK:
   ```bash
   flutter build apk --release
   ```
2. Upload the APK binary to your GitHub releases repository.
3. Update the Firestore configurations document:
   * **Path**: `/config/appVersion`
   * **Schema**:
     ```json
     {
       "latestVersion": "1.0.1",
       "downloadUrl": "https://github.com/NirdeshanB/paradigm_project_tracker/releases/download/v1.0.1/app-release.apk",
       "features": [
         "Targeted user alarm reminders support",
         "Sound volume mixer preferences slider",
         "Optimized MaterialApp rebuild loops"
       ],
       "isForceUpdate": false
     }
     ```
4. Active user applications will immediately present a non-intrusive dialog prompt containing release notes and direct download actions.

---

## 🏁 Getting Started & Execution

1. Configure Flutter SDK (>= 3.2.0) on your local environment.
2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```
3. Launch on a connected Android/iOS target:
   ```bash
   flutter run
   ```
