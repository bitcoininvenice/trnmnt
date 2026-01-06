# TRNMNT 🏀

**Basketball Tournament Manager**

TRNMNT is a professional mobile application built with **Flutter** designed to manage basketball tournaments with ease, style, and security.

---

## 🌟 Key Features

### 🏆 Tournament Management
*   **Flexible Modes**:
    *   **Group Phase**: Automatic round-robin schedule generation with standings.
    *   **Elimination**: Single-elimination bracket support (Quarterfinals, Semifinals, Finals).
    *   **Hybrid**: Start with a group phase and proceed to a playoff bracket.
*   **Custom Scoring Rules**: Configure points for Wins, Draws, and Losses (e.g., FIBA rules: Win=2, Loss=1).
*   **Consolation Brackets**: Optional support for 3rd-4th, 5th-6th, and 7th-8th place matches.

### 🛡️ Secure & Offline-First
*   **Encrypted Database**: All data is stored locally using **Drift (SQLite)** with **SQLCipher (AES-256 encryption)**.
*   **Secure Storage**: Database encryption keys are securely managed via Android Keystore / iOS Keychain.
*   **Privacy Focused**: No cloud dependencies; your data stays on your device.

### 👥 Team Management
*   Create, edit, and delete teams.
*   **Smart Search**: Quickly find and select teams during tournament setup with real-time filtering.
*   **Auto-Balancing**: Automatically handles "Bye" rounds for tournaments with an odd number of teams.

### ⏱️ Match Utilities
*   **Live Game Timer**: Standalone full-screen timer with customizable duration, buzzer sounds, and visual alerts.
*   **Quick Scoring**: Simple interface to record match results and instantly update brackets and standings.

---

## 🛠️ Technology Stack

*   **Framework**: [Flutter](https://flutter.dev) (Dart)
*   **State Management**: [Riverpod](https://riverpod.dev)
*   **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
*   **Database**: [Drift](https://drift.simonbinder.eu/) + SQLCipher
*   **UI/UX**: Material 3 Design, [flutter_animate](https://pub.dev/packages/flutter_animate), Google Fonts.

---

## 🚀 Getting Started

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   Android Studio / Xcode for emulators or physical devices.

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/bitcoininvenice/trnmnt.git
    cd trnmnt
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the App**
    ```bash
    flutter run
    ```

### Build for Release (Android)
To generate an optimized APK:
```bash
flutter build apk --release
```
The output will be located at `build/app/outputs/flutter-apk/app-release.apk`.

