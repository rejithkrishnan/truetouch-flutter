# 🧸 TrueTouch: Project Blueprint & Kickoff Context

This document is automatically loaded into the agent context on every session. Use this high-density overview to understand the application architecture, tech stack, and module flows immediately without scanning the entire workspace.

---

## 📌 1. Project Mission & Core Tenets
- **What is TrueTouch?**: A toddler-friendly sensory exploration & early learning mobile app built in **Flutter 3.x / Dart 3.7+** (migrated from a Godot 4.6 prototype).
- **Target Audience**: Toddlers & preschoolers (ages 1–4).
- **Core Philosophy**: Zero cognitive overload, 100% offline-first, nursery pastel aesthetics, immediate tactile/visual feedback on every tap, strict child safety, and zero external tracking/analytics.

---

## 🛠️ 2. Tech Stack & Core Libraries
- **Framework**: Flutter (portrait orientation locked, immersive sticky fullscreen).
- **State Management**: `flutter_riverpod` (`Provider`, `AsyncNotifier`, `StateProvider`).
- **Routing**: `go_router` (`ShellRoute` wrapped in `ParentalGate`, custom `_FadePage` transitions).
- **Audio Engine**:
  - `just_audio`: Low-latency sound effects & multi-track looping BGM (Home, Board Book, Sound Match, Bubble Pop) with smooth cross-fading.
  - `flutter_tts`: Calibrated Text-to-Speech in `VoiceEngine` (en-GB female voice prioritized, slow pace 0.4).
- **2D Game Engine**: `flame` (used for interactive physics, water line, and floating bubble animations in Bubble Pop).
- **UI & Animations**: `flutter_animate` (entrance/shimmer), `confetti` (burst rewards), local bundled **Quicksand** font.
- **Hardware & Device**: `kiosk_mode` (screen pinning / Toddler Lock), `services` (`HapticFeedback`).
- **Persistence**: `shared_preferences` (offline storage for settings, screen time, progress, and stars).

---

## 📂 3. Directory Blueprint & Critical Files
```
lib/
├── main.dart                          # App bootstrap (locks portrait, overrides sharedPreferencesProvider)
├── app.dart                           # MaterialApp.router with global ScreenTimeOverlay
├── core/
│   ├── providers.dart                 # Central Riverpod DI registry for services and state
│   ├── routing/app_router.dart        # Route map: '/', '/home', '/board-book', '/sound-match', '/bubble-pop'
│   ├── services/
│   │   ├── audio_service.dart         # Multi-track BGM, playTtsCardSequence, playRandomPopSound
│   │   ├── voice_engine.dart          # Calibrated TTS wrapper with gender/locale fallbacks
│   │   ├── settings_service.dart      # Volumes, toggles, child name, screen time limit, bubble configs
│   │   ├── progress_service.dart      # Tap counts, 1-5 star ratings, sound match scores, celebration states
│   │   ├── screen_time_service.dart   # Daily usage timer tracking & limit enforcement
│   │   └── haptic_service.dart        # Centralized tactile triggers (heavy, medium, light, selectionClick)
│   └── theme/app_theme.dart           # AppColors (Nursery Palette), cardDecoration, Quicksand TextTheme
├── data/
│   ├── models/                        # Module, Category, ContentItem models
│   └── repositories/                  # ModuleRepository (modules.json), ContentRepository (content.json)
├── features/
│   ├── splash/                        # Animated splash screen (`/`)
│   ├── home/                          # Home hub (`/home`) with module grid & ToddlerLockButton
│   ├── board_book/                    # Flashcard module (`/board-book`) with toddler swipe guard
│   ├── sound_match/                   # Auditory guessing game (`/sound-match`) with accuracy scoring
│   ├── bubble_pop/                    # Flame 2D game (`/bubble-pop`) with floating letters & numbers
│   └── parent_menu/                   # Protected settings modal dialog (child profile, volumes, limits)
└── shared/widgets/
    ├── premium_animated_text.dart     # Standardized text atom (staggered entrance, bobbing wave, drift)
    ├── parental_gate.dart             # 3-second hold gesture shell gate guarding parent settings
    ├── hold_to_exit_button.dart       # 3-second hold to unpin & exit app with haptics
    ├── screen_time_overlay.dart       # Full-screen lock overlay when daily screen time is exhausted
    ├── category_celebration_overlay.dart # Confetti shower + trophy celebration modal
    ├── animated_background.dart       # Floating pastel ambient background image
    └── breathing_widget.dart          # Scale-loop animation for interactive elements
```

---

## 🎮 4. Feature Modules Summary
1. **Home Hub (`/home`)**:
   - Displays available learning games from `assets/data/modules.json`.
   - Displays personalized greeting for child (`childName` from settings).
   - Automatically triggers OS-level screen pinning (`startKioskMode()`) on startup.
   - Wrapped in `PopScope(canPop: false)` to suppress system back gestures.
   - Bottom-left includes `HoldToExitButton` (3-second hold with haptic pulses to unpin and exit).
2. **Board Book (`/board-book`)**:
   - Category-based flashcard swiping.
   - **Toddler Swipe Guard**: Uses `_HeavyPageScrollPhysics` (`dragStartDistanceMotionThreshold: 150.0`) so taps never cause accidental page turns.
   - Sequence: Tap $\rightarrow$ Immediate confetti burst + TTS speaks name $\rightarrow$ 0ms buffer $\rightarrow$ Object sound effect.
   - Progress: Tracks card tap count $\rightarrow$ 1–5 stars. Completing category triggers `CategoryCelebrationOverlay`.
3. **Sound Match (`/sound-match`)**:
   - Audio puzzle: Prompts child with an animal/object sound $\rightarrow$ Child taps matching card (2 or 4 options).
   - Scoring: 3 stars (0 mistakes), 2 stars (1 mistake), 1 star (2+ mistakes) saved per category.
   - 12-second automated idle timer re-prompts the child.
4. **Bubble Pop (`/bubble-pop`)**:
   - Real-time 2D game running on Flame Engine (`BubblePopGame`).
   - Floats bubbles containing letters (A–Z) and numbers (1–10) from bottom water layer.
   - Tap pops bubble $\rightarrow$ random pop SFX + haptic + TTS pronunciation of character.
5. **Parent Menu & Safety**:
   - Accessed via `ParentalGate` (3-second hold on gear icon with 100ms haptic heartbeat).
   - Manages child profile, independent music & voice volumes, daily screen time limits, and game toggles.

---

## ⚠️ 5. Crucial Architectural Rules & Gotchas
1. **Audio Lifecycle Pattern (NEVER VIOLATE)**:
   - Always cache service references in `initState()`: `_audio = ref.read(audioServiceProvider);`.
   - In `dispose()`, NEVER use `ref.read()` (ref is already dead). Use cached `_audio.cancelSequence()` and `_voice.stop()`.
   - Provider states must use `_disposed` boolean flags to guard async TTS callbacks.
   - Game providers must use `AsyncNotifierProvider.autoDispose` so timers/states are purged on exit.
2. **Sensory-Friendly Design Tokens**:
   - Always use `AppColors.nurseryPalette`: Golden Sunbeam (`0xFFFFCC4D`), Soft Coral (`0xFFFF7373`), Soft Mint (`0xFF73D999`), Soft Sky (`0xFF73A6FF`), Soft Lavender (`0xFFBF8CE6`), Soft Peach (`0xFFFF9966`), Splash (`0xFFF1D7C0`).
   - Cards must use `borderRadius: 24`, white glassmorphism (`alpha: 0.15`), and subtle 1px border (`alpha: 0.2`).
   - Never use default fonts; exclusively use the bundled **Quicksand** family.
3. **Responsive Visual Rewards**:
   - Confetti and haptics MUST trigger on `onTapDown` immediately without waiting for audio playback to finish.
4. **Memory Bank Integrity**:
   - Any architectural, feature, or design pattern change must be documented in [DESIGN_SYSTEM.md](file:///d:/Coding/flutter/trutouch/DESIGN_SYSTEM.md).
5. **Strictly No Graphify Tooling**:
   - NEVER invoke the Graphify skill, run graphify commands, or generate `graphify-out/` or `.graphify_*` files in this repository.
   - Codebase exploration must be performed exclusively with direct file inspection tools (`view_file`, `grep_search`, `list_dir`).
