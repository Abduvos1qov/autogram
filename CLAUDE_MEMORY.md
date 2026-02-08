# Claude Memory - AUTOGRAM Loyihasi

## Asosiy Ma'lumotlar

- **Loyiha nomi:** Autogram
- **Maqsad:** Avtomobillar uchun Reels-formatli platforma (O'zbekiston uchun)
- **Til:** Dart/Flutter
- **Backend:** Supabase
- **Video:** Cloudflare Stream

## Arxitektura

- **Pattern:** Clean Architecture + BLoC
- **State Management:** flutter_bloc
- **DI:** GetIt
- **Navigation:** GoRouter
- **Error Handling:** dartz Either pattern

## Loyiha Tuzilmasi

```
lib/
├── main.dart, app.dart, bootstrap.dart
├── core/           # Umumiy kodlar
├── features/       # Feature modullar
│   ├── auth/       # Autentifikatsiya
│   ├── home/       # Bosh sahifa (feed)
│   ├── reels/      # Video player
│   ├── search/     # Qidiruv + filtr
│   ├── listing/    # E'lon detallari
│   ├── saved/      # Saqlanganlar
│   ├── chat/       # Xabarlar
│   ├── profile/    # Profil
│   └── notifications/
├── navigation/     # GoRouter
├── di/            # GetIt injection
└── l10n/          # Tarjimalar (uz, ru, en)
```

## Feature Modullari Tuzilishi

Har bir feature modul 3 layerdan iborat:
1. **domain/** - entities, repositories (abstract), usecases
2. **data/** - models, datasources, repositories (impl)
3. **presentation/** - bloc, screens, widgets

## Muhim Dependencies

```yaml
flutter_bloc, get_it, go_router, dio
supabase_flutter, video_player
sqflite, shared_preferences, flutter_secure_storage
easy_localization, cached_network_image
dartz (Either pattern)
```

## Tillar

- O'zbekcha (uz) - asosiy
- Русский (ru)
- English (en)

## Keyingi Qadamlar

1. Supabase projectni sozlash (database, auth, storage)
2. Cloudflare Stream integratsiya
3. Payment integration (Click, Payme, Uzum)
4. Firebase FCM for push notifications

## Eslab Qolish Kerak

- Birinchi fazada FAQAT avto kategoriyasi
- Ko'chmas mulk keyinroq qo'shiladi
- O'zbekiston bozori uchun mo'ljallangan
- Narxlar USD va UZS da
- Shaharlar: Toshkent, Samarqand, Buxoro, Farg'ona, va boshqalar
