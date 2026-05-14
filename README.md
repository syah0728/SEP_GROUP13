# SEP_GROUP13 — Attendance & Operations (SAMS 2026)

Flutter mobile app untuk pengurusan kehadiran universiti.

## Modules

| Module | Status | Folder |
|--------|--------|--------|
| Manage Attendance | ✅ Siap | `lib/screens/manage_attendance/` |
| Manage Academic | 🔲 Placeholder | `lib/screens/manage_academic/` |
| Manage Co-curriculum | 🔲 Placeholder | `lib/screens/manage_cocurriculum/` |
| Manage Financial | 🔲 Placeholder | `lib/screens/manage_financial/` |

## Cara Setup (Firebase)

1. Buat Firebase project di [console.firebase.google.com](https://console.firebase.google.com)
2. Download `google-services.json` → letak dalam `android/app/`
3. Jalankan: `flutterfire configure` (ganti `lib/firebase_options.dart`)
4. Enable Firestore dalam Firebase console
5. Set Firestore rules: `allow read, write: if true;` (untuk development)

## Cara Tambah Module Baru

Ikut struktur folder yang ada:
```
lib/
  controllers/manage_<nama>/manage_<nama>_controller.dart
  models/manage_<nama>/manage_<nama>_model.dart
  screens/manage_<nama>/manage_<nama>_screen.dart
```

## Getting Started

- [Flutter documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
