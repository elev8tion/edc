# 🙏 Everyday Christian

**A faith-centered mobile app providing personalized biblical guidance through AI-powered conversations.**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()

---

## 📱 About

Everyday Christian is a **100% local-first** pastoral counseling app that provides:

- 🤖 **AI-powered pastoral guidance** using on-device TensorFlow Lite LSTM
- 📖 **31,103 Bible verses** from the World English Bible (WEB) translation
- 🛡️ **Crisis detection & intervention** (suicide, self-harm, abuse)
- 🎨 **Beautiful glassmorphic UI** with modern Flutter design
- 🌍 **Bilingual support** (English & Spanish)
- 🔒 **Complete privacy** - zero cloud dependencies, no data collection

---

## ✨ Features

### Core Functionality
- **AI Chat:** Character-level LSTM trained on 19,750 pastoral examples
- **Daily Verse:** Smart verse selection based on user preferences
- **Devotionals:** Structured reading plans and devotional content
- **Prayer Journal:** Track prayers with categories and streaks
- **Verse Library:** Full-text search across 31,103 verses
- **Reading Plans:** Guided Bible reading with progress tracking

### Safeguards
- ✅ Crisis detection (suicide, self-harm, abuse keywords)
- ✅ Account lockout system (3 strikes = 30-day ban)
- ✅ Content filtering (prosperity gospel, hate speech)
- ✅ Professional referrals (therapy, hotlines, legal)
- ✅ Legal disclaimers (not professional counseling)

### Technical Features
- 🚀 **On-device AI inference** (<5s response time)
- 💾 **SQLite database** (26 MB, 31,103 verses)
- 🔐 **Biometric authentication** (Face ID, Touch ID)
- 📊 **Progress tracking** (reading streaks, prayer stats)
- 🌙 **Dark mode** support
- 📴 **Offline-first** (no internet required)

---

## 🏗️ Architecture

### Tech Stack
- **Frontend:** Flutter 3.0+ (Dart 3.0+)
- **State Management:** Riverpod 2.4.9
- **Database:** SQLite (sqflite 2.3.0)
- **AI/ML:** TensorFlow Lite 0.11.0
- **Storage:** SharedPreferences + FlutterSecureStorage

### AI System
- **Theme Classifier:** 751 KB TFLite model (75 theme categories)
- **Text Generator:** 8.1 MB LSTM model (2-layer, 1536 units, 86-char vocab)
- **Training Data:** 19,750 pastoral guidance examples
- **Bible Database:** 31,103 verses (WEB translation)

### Project Structure
```
lib/
├── core/
│   ├── database/        # SQLite helpers, migrations, models
│   ├── services/        # Business logic (18 services)
│   ├── providers/       # Riverpod state management
│   └── widgets/         # Reusable UI components
├── features/
│   ├── auth/            # Authentication & biometrics
│   └── chat/            # AI conversation interface
├── screens/             # 14 main screens
├── services/            # AI services (LSTM, theme classifier)
└── theme/               # App theming & styles
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Xcode 14+ (for iOS) or Android Studio (for Android)
- macOS (for iOS builds)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/elev8tion/edc.git
   cd edc
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation:**
   ```bash
   dart run build_runner build
   ```

4. **Run the app:**
   ```bash
   # iOS Simulator
   flutter run -d ios

   # Android Emulator
   flutter run -d android

   # macOS Desktop
   flutter run -d macos
   ```

---

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Coverage
- **49 test files** (unit, widget, integration)
- Comprehensive service tests (database, AI, auth, safeguards)
- Mock implementations for external dependencies

---

## 📦 Building for Production

### iOS

1. **Configure signing:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select your team and provisioning profile

2. **Build release:**
   ```bash
   flutter build ipa --release
   ```

3. **Upload to TestFlight:**
   ```bash
   xcrun altool --upload-app --file build/ios/ipa/*.ipa
   ```

### Android

1. **Generate signing key:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Build release:**
   ```bash
   flutter build appbundle --release
   ```

3. **Upload to Play Console:**
   - Navigate to [Play Console](https://play.google.com/console)
   - Upload `build/app/outputs/bundle/release/app-release.aab`

---

## 📊 Project Stats

- **Lines of Code:** 44,042 (lib/)
- **Dart Files:** 140 (lib) + 49 (test)
- **Development Time:** 8 days (Sept 30 - Oct 8, 2025)
- **Commits:** 50+
- **Training Examples:** 19,750
- **Bible Verses:** 31,103
- **Supported Themes:** 75

---

## 🛡️ Privacy & Security

### Data Collection
- ✅ **Zero data collection** - all processing happens on-device
- ✅ **No analytics** - we don't track you
- ✅ **No cloud services** - no external API calls
- ✅ **Local storage only** - SQLite + SharedPreferences

### Security Features
- 🔐 Biometric authentication (Face ID, Touch ID)
- 🔒 FlutterSecureStorage for sensitive data
- 🛡️ Crisis detection & intervention
- ⚠️ Content filtering (harmful theology)

---

## ⚖️ Legal

### Disclaimer
**This app provides pastoral guidance, NOT professional counseling.**

- Not a substitute for licensed therapy
- Not medical or legal advice
- AI responses may contain errors
- Crisis situations require professional help

**Crisis Resources:**
- **Suicide & Crisis Lifeline:** 988 (call or text)
- **Crisis Text Line:** Text HOME to 741741
- **RAINN (Sexual Assault):** 800-656-4673

### License
Proprietary - All rights reserved

**Bible Content:**
- World English Bible (WEB) - Public Domain
- Original source: [eBible.org](https://ebible.org)

---

## 🙏 Acknowledgments

- **Bible Translation:** World English Bible (WEB) from eBible.org
- **TensorFlow Lite:** On-device machine learning
- **Flutter Team:** Excellent cross-platform framework
- **Riverpod:** State management
- **Claude Code:** Development assistance

---

## 📞 Contact

- **Developer:** elev8tion
- **GitHub:** [elev8tion/edc](https://github.com/elev8tion/edc)
- **Issues:** [GitHub Issues](https://github.com/elev8tion/edc/issues)

---

## 🔄 Version History

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

**Built with ❤️ for the body of Christ**

*"In nothing be anxious, but in everything, by prayer and petition with thanksgiving, let your requests be made known to God."* - Philippians 4:6 (WEB)
