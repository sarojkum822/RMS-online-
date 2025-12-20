# 🏠 KirayaBook

<p align="center">
  <img src="assets/icon/icon.png" alt="KirayaBook Logo" width="120"/>
</p>

<p align="center">
  <b>Professional Property Management for Indian Landlords</b><br>
  <i>Manage properties, collect rent, track expenses — all in one place</i>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#development-journey">Journey</a> •
  <a href="#getting-started">Get Started</a>
</p>

---

## ✨ Features

### 🏢 Property Management
- Multi-property portfolio with houses & units
- BHK templates for quick unit setup
- Occupancy tracking & vacancy alerts

### 👥 Tenant Management
- Complete tenant profiles with ID verification
- AI-powered Aadhaar/ID card scanning (OCR)
- Automated rent cycle generation

### 💰 Financial Tracking
- Real-time rent collection dashboard
- Expense tracking with categories
- Professional PDF reports & receipts

### 🔐 Security
- Biometric authentication (fingerprint/face)
- Encrypted Personal Vault for documents
- Session-based security

### 📊 Analytics & Reports
- Revenue trends & charts
- Occupancy rates
- Payment method breakdown
- Export-ready financial reports

### 🌍 Localization
- English & Hindi support
- INR currency formatting
- Indian date formats

---

## 📱 Screenshots

<p align="center">
  <i>Coming soon...</i>
</p>

---

## 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.24+ |
| **State Management** | Riverpod 2.x |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **Local Database** | Drift (SQLite) |
| **Navigation** | GoRouter |
| **UI/Design** | Material 3, Google Fonts, Custom Aura Design System |
| **Security** | local_auth, Encrypted Storage |
| **Ads** | Google Mobile Ads |

---

## 🚀 Development Journey

### 📅 Timeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    KirayaBook Development Timeline               │
└─────────────────────────────────────────────────────────────────┘

  Oct 2024                                                    Dec 2024
    │                                                            │
    ▼                                                            ▼
    ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐
    │ v0.1 │───│ v0.2 │───│ v0.5 │───│ v0.8 │───│ v0.9 │───│ v1.0 │
    └──────┘   └──────┘   └──────┘   └──────┘   └──────┘   └──────┘
       │          │          │          │          │          │
       ▼          ▼          ▼          ▼          ▼          ▼
    ┌─────┐   ┌─────┐   ┌─────┐   ┌─────┐   ┌─────┐   ┌─────┐
    │Core │   │Multi│   │Rent │   │Aura │   │Vault│   │Prod │
    │CRUD │   │Unit │   │Track│   │Design│  │Lock │   │Ready│
    └─────┘   └─────┘   └─────┘   └─────┘   └─────┘   └─────┘
```

### 🎯 Version History

#### v0.1 — Foundation (Oct 2024)
- ✅ Basic property & tenant CRUD
- ✅ Firebase authentication
- ✅ Firestore integration

#### v0.2 — Multi-Unit Support (Oct 2024)
- ✅ House → Unit hierarchy
- ✅ BHK templates system
- ✅ Tenant-Unit assignment

#### v0.5 — Rent Management (Nov 2024)
- ✅ Automated rent cycle generation
- ✅ Payment tracking (Cash, UPI, Bank)
- ✅ WhatsApp payment reminders

#### v0.8 — Aura Design System (Nov 2024)
- ✅ Complete UI overhaul
- ✅ Premium glassmorphism effects
- ✅ Professional splash screen
- ✅ iOS-style navigation

#### v0.9 — Security & Vault (Dec 2024)
- ✅ Biometric authentication
- ✅ Encrypted Personal Vault
- ✅ Session-persistent security
- ✅ Separate lock controls

#### v1.0 — Production Ready (Dec 2024)
- ✅ Hindi localization
- ✅ AI-powered ID scanning
- ✅ PDF report generation
- ✅ Play Store optimization

---

## 🏗 Getting Started

### Prerequisites
- Flutter 3.24+
- Dart 3.0+
- Firebase project setup

### Installation

```bash
# Clone the repository
git clone https://github.com/sarojkum822/RMS-online-.git

# Navigate to project
cd RMS-online-

# Install dependencies
flutter pub get

# Generate code (freezed, riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Build Release

```bash
# Debug APK
flutter build apk --debug

# Release APK (~127MB, all architectures)
flutter build apk --release

# App Bundle for Play Store (~85MB, optimized per device)
flutter build appbundle --release
```

---

## 📁 Project Structure

```
lib/
├── core/                 # Constants, themes, services, utilities
│   ├── services/         # Business logic services
│   ├── theme/            # App theming (Aura Design System)
│   └── utils/            # Helper functions
├── data/                 # Data layer
│   ├── datasources/      # Local (Drift) & Remote (Firebase)
│   └── repositories/     # Repository implementations
├── domain/               # Business logic
│   ├── entities/         # Data models (Freezed)
│   └── repositories/     # Repository interfaces
├── features/             # Feature modules
│   ├── rent/             # Rent management feature
│   └── vault/            # Encrypted vault feature
├── presentation/         # UI layer
│   ├── providers/        # Riverpod providers
│   ├── routes/           # GoRouter navigation
│   ├── screens/          # Screen widgets
│   └── widgets/          # Reusable components
└── main.dart             # App entry point
```

---

## 👨‍💻 Author

**Saroj Kumar**
- GitHub: [@sarojkum822](https://github.com/sarojkum822)

---

## 📄 License

This project is proprietary software. All rights reserved.

---

<p align="center">
  Made with ❤️ in India 🇮🇳
</p>
