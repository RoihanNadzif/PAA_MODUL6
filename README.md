# 🚗 Car Rental - Aplikasi Sewa Mobil

Aplikasi mobile sewa mobil berbasis Flutter yang terhubung dengan REST API.

**API Server:** `https://car-rental-api-silk.vercel.app`

---

## 📁 Struktur Folder

```
lib/
├── main.dart
├── config/
│   └── api_config.dart
├── models/
│   ├── car_model.dart
│   ├── user_model.dart
│   ├── booking_model.dart
│   └── payment_model.dart
├── services/
│   ├── auth_service.dart
│   ├── car_service.dart
│   ├── booking_service.dart
│   └── payment_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── car/
│   │   ├── car_list_screen.dart
│   │   └── car_form_screen.dart
│   ├── booking/
│   │   ├── booking_form_screen.dart
│   │   ├── booking_list_screen.dart
│   │   ├── payment_form_screen.dart
│   │   └── payment_list_screen.dart
│   └── home/
│       └── home_screen.dart
└── widgets/
    ├── car_card.dart
    ├── custom_text_field.dart
    └── loading_indicator.dart
```