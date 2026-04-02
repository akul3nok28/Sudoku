# Sudoku

Минималистичная игра «Судоку» на Flutter с поддержкой тем, уровней сложности и подсказок. Интерфейс оптимизирован под десктоп и мобильные размеры, а прогресс автоматически сохраняется.

## Возможности
- Генерация корректных головоломок с уникальным решением.
- Уровни сложности: лёгкий, средний, сложный.
- Режим заметок (карандаш).
- Подсказка для выбранной клетки.
- Лимит ошибок (3) с завершением игры.
- Автосохранение и восстановление прогресса.
- Смена цветовой темы.

## Технологии
- Flutter (Dart)
- Riverpod (state management)
- SharedPreferences (локальное хранение состояния)

## Структура проекта
- `lib/logic/` — генерация и проверка Судоку.
- `lib/providers/` — управление состоянием игры и сохранениями.
- `lib/models/` — модели данных (например, клетка).
- `lib/screens/` — экраны (меню, игра).
- `lib/widgets/` — переиспользуемые UI‑компоненты.
- `lib/core/` — константы, темы, строки.

## Запуск (dev)

### Требования
- Flutter SDK (рекомендуется версия из `pubspec.yaml`, минимум совместимая с `sdk: ^3.9.2`).
- Для Android: Android SDK + эмулятор или устройство.
- Для iOS/macOS: Xcode (только macOS).
- Для Windows: Visual Studio с компонентами Desktop development with C++.
- Для Linux: инструменты сборки (clang, cmake, ninja, pkg-config и др.).

### Подготовка
```bash
flutter pub get
```

### Запуск на нужной платформе
```bash
flutter devices
```

Примеры:
```bash
# Android
flutter run -d android

# iOS (только macOS)
flutter run -d ios

# Web (Chrome)
flutter run -d chrome

# Windows
flutter run -d windows

# macOS (только macOS)
flutter run -d macos

# Linux
flutter run -d linux
```

## Сборка релизных билдов

Важно: iOS и macOS можно собирать только на macOS. Windows‑хост не соберёт эти платформы.

### Android
```bash
flutter build apk
flutter build appbundle
```
Артефакты:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS)
```bash
flutter build ipa
```
Артефакт:
- `build/ios/ipa/*.ipa`

### Web
```bash
flutter build web
```
Артефакты:
- `build/web/`

### Windows
```bash
flutter build windows
```
Артефакты:
- `build/windows/runner/Release/`

### macOS (macOS)
```bash
flutter build macos
```
Артефакты:
- `build/macos/Build/Products/Release/`

### Linux
```bash
flutter build linux
```
Артефакты:
- `build/linux/x64/release/bundle/`

## Автосохранение
Состояние игры (доска, решение, время, ошибки, тема и сложность) сохраняется локально каждые несколько секунд и восстанавливается при следующем запуске.

## Лицензия
Проект не предназначен для публикации в pub.dev (`publish_to: none`).
