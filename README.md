# TrueTouch Flutter

A toddler-friendly sensory exploration and early learning app.
Migrated from Godot 4.6 → Flutter 3.x.

## Features
- **Board Book** — Infinite swipe-through cards with images, voice labels & sounds
- **Sound Match** — Match animal sounds to pictures (puzzle game)
- **Parental Gate** — 3-second long-press to access Parent Menu
- **Parental Controls** — Toggle sound, vibration, music; configure cards-per-page and active categories
- **Background Music** — Looping piano track

## Getting Started

### Prerequisites
- Flutter 3.22+ & Dart 3.4+
- Android SDK (API 21+)

### Setup
```bash
flutter pub get
flutter run
```

### Asset Migration from Godot
Run the migration helper to copy assets from the Godot project:
```bash
# From repo root
dart tools/migrate_assets.dart
```

## Project Structure
```
lib/
├── main.dart           # Entry point
├── app.dart            # MaterialApp + router
├── core/               # Theme, routing, services, providers
├── data/               # Models + repositories
├── features/           # Feature-first screens & widgets
└── shared/             # Reusable widgets
```
