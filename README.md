# supernoVA

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev) [![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Go](https://img.shields.io/badge/go-%2300ADD8.svg?style=for-the-badge&logo=go&logoColor=white)](https://go.dev)

[![License](https://img.shields.io/badge/License-GPL%20v3-blue)](LICENSE)

Crossplatform messenger based on Flutter.

### About project
supernoVA is a real-time chat application designed from the ground up for speed and reliability. The client is written entirely in Dart using the Flutter framework, providing native performance on Windows, Linux, macOS, Android, and iOS from a single codebase. The backend is powered by Go, chosen for its lightweight concurrency model and excellent WebSocket support (ofc also for multistreaming).

### Requirements
 - Flutter SDK ^3.44.4
 - Dart ^3.12.2
 - Windows 10+ / macOS / Linux
 - brain

### Installation

```bash
git clone https://github.com/ma3rd-nepon/flutter-go-chat.git

cd flutter-go-chat

flutter pub get

```

### Project structure

```
lib/
├── main.dart              # main app file
├── models/                # Data models (User, Message, Chat)
├── services/              # Database/WebSocket Utilities
├── screens/               # App screens
├── widgets/               # Widgets
```

### Technologies

| Layer | Technology | Implemented By | Status |
|-------|------------|----------------|--------|
| **Frontend** | Flutter, Dart  | ma3rd-nepon | WIP |
| **Backend** | Go / SQLite     | MetSunSawedOfWire | DONE |
| **Requests** | WebSocket, HTTP | MetSunSawedOfWire | TBA |
| **Database** | SQLite, PostgreSQL | MetSunSawedOfWire | WIP |
| **State** | setState, Provider, Riverpod | ma3rd-nepon | DONE |
| **Auth** | JWT, OAuth 2.0 | ma3rd-nepon | TBA |
| **Storage** | Local FS, S3 | MetSunSawedOfWire | TBA |
| **Sponsor** | Money | MetSunSawedOfWire | WIP |


---



- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.