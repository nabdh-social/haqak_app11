# 🇾🇪 حقك كمواطن يمني

تطبيق Flutter شامل يوفر دليلاً قانونياً للمواطنين اليمنيين.

## 📋 المتطلبات
- Flutter SDK 3.24.0 أو أحدث
- Android SDK (API 21+)

## 🚀 خطوات البناء

```bash
# 1. انتقل لمجلد المشروع
cd flutter_app

# 2. ثبّت الاعتماديات
flutter pub get

# 3. بناء APK (إصدار)
flutter build apk --release

# 4. ستجد APK في:
# build/app/outputs/flutter-apk/app-release.apk
```

## ⚠️ قبل البناء
1. أضف خط Cairo في `assets/fonts/`
2. أضف أيقونات التطبيق في `android/app/src/main/res/mipmap-*/`
3. عدّل `applicationId` في `android/app/build.gradle` إذا أردت

## 🏗️ هيكل المشروع
```
flutter_app/
├── android/          ← ملفات Android
├── assets/fonts/     ← خطوط التطبيق
├── lib/
│   └── main.dart     ← كود التطبيق الكامل
└── pubspec.yaml      ← إعدادات المشروع
```
