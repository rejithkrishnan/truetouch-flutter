# 🧸 TrueTouch Design System & Memory Bank

Welcome to the **TrueTouch Memory Bank**. This document is the single source of truth for the entire application. It documents our architecture, design language, sensory philosophy, and technical standards.

---

## 🚀 1. Project Core & Tech Stack

TrueTouch is built as a high-end, sensory-friendly educational platform for children.

-   **Framework**: Flutter (Targeting iOS/Android/Tablet).
-   **State Management**: `flutter_riverpod` (AsyncNotifier, Provider patterns).
-   **Navigation**: `go_router` (Declarative routing).
-   **Audio Engine**: `just_audio` (Low-latency playback).
-   **Animation Engine**: `flutter_animate` (Centralized via `PremiumAnimatedText`).
-   **Persistence**: `shared_preferences` (Settings & Progress).

### Directory Structure
We follow a **Feature-Sliced** organization:
-   `lib/core/`: Application-wide services, routing, and themes.
-   `lib/data/`: Models, repositories, and mock data.
-   `lib/features/`: Independent modules (Home, Board Book, Sound Match).
-   `lib/shared/`: Reusable widgets used across multiple features.

---

## 🏗️ 2. Architectural Patterns

### Global Services
Located in `lib/core/services/`, these are accessed via Riverpod providers in `lib/core/providers.dart`:
-   **`AudioService`**: Manages VO/SFX buffers and volumes.
-   **`ProgressService`**: Persists star ratings and engagement stats.
-   **`HapticService`**: Centralized tactile feedback engine.
-   **`ScreenTimeService`**: Monitors session duration and triggers lockout.

### Persistence Strategy
-   **Settings**: Persistent flags (vibration, voice enabled, max screen time).
-   **Progress**: Keyed by `moduleId_categoryId_itemId` to track 1-5 star engagement.

---

## 🌟 3. Sensory Philosophy
-   **Calmness First**: Use soft, nursery-inspired colors. Avoid harsh primary colors or high-contrast vibrations.
-   **Micro-Rewards**: Every intentional tap provides immediate sensory feedback (confetti, scale, or haptics).
-   **Premium Simplicity**: Use clean, modern typography (Quicksand) and translucent "glassmorphism" to professionalize the experience.

---

## 🎨 4. Branding & Tokens

### The Nursery Palette
| Color Name | Hex Code | Purpose |
| :--- | :--- | :--- |
| **Splash / Background** | `#F1D7C0` | Primary Scaffolds. |
| **Golden Sunbeam** | `#FFCC4D` | **Premium Accents**, Shimmers, Success. |
| **Soft Coral** | `#FF7373` | UI Highlights, Card Labels. |
| **Soft Mint** | `#73D999` | Success states. |
| **Soft Sky** | `#73A6FF` | Navigation & Inactive states. |
| **Soft Lavender** | `#BF8CE6` | Category headers. |
| **Translucent White** | `0.1 - 0.15 Alpha` | Glass containers & Panels. |

### Typography & Corners
-   **Font**: Google Fonts: **Quicksand** (Weights: 500 to 900).
-   **Standard Radius**: `24px` for cards, `14px` for settings tiles.
-   **Secondary Radius**: `32px` for large home sections.

---

## ✨ 5. Standardized Interactive Atoms

### 1. Premium Animations (`PremiumAnimatedText`)
Mandatory for all text. Located in `lib/shared/widgets/premium_animated_text.dart`.
-   **`bobbing`**: Rhythmic vertical wave for titles.
-   **`drifting`**: Organic wandering for scene objects.
-   **`Dancing Drift`**: Combined `bobbing` + `hasDrift` for maximum engagement.

### 2. Tactile DNA (Haptics)
-   **Card Tap**: `heavyImpact`.
-   **Success**: `mediumImpact`.
-   **Parental Gate**: 100ms `selectionClick` pulse.

### 3. Unified Card DNA
All interactive items (Content Cards, Activity Cards, Game Tiles) must adhere to:
-   **Background**: `Colors.white.withValues(alpha: 0.15)` (Glassmorphism).
-   **Border**: `1px` white border at `0.2` alpha.
-   **Rounding**: `radius: 24px`.
## 🍭 Sensory Reward System

-   **Confetti Sprays**: Used exclusively for success states and interactive "Showers."
-   **Hold-to-Shower**: Confetti now supports sustained interaction. Holding a card "showering" the screen, while a quick tap provides a guaranteed **250ms burst**.
-   **Visual Response Priority**: Confetti triggers MUST happen on `onTapDown` and are **un-gated** by audio sequences. This ensures the child always feels the app is responsive, even if they tap while a word is being spoken.
-   **No More Bounce**: The 0.9 scale "button press" has been removed to maintain the "Glass Sheet" aesthetic and reduce visual clutter during rapid interactions.

## 🔡 Typography (100% Offline)

-   **Primary Font**: **Quicksand** (Google Fonts family).
-   **Bundled Strategy**: All font weights (Regular, Medium, Bold) are bundled locally in `assets/fonts/` and registered in `pubspec.yaml`.
-   **No Network Dependency**: The app theme uses native `fontFamily` registration. This ensures the sensory look is preserved in airplane mode and prevents "fallback font flickering."

## 🎬 Animation Atoms & Persistence

-   **Idle Animations**: Breathing, Swaying, and Floating must be implemented using `StatefulWidgets`.
-   **State Locking**: Randomized parameters (duration, scale, variance) must be locked in `initState`. This prevents visual "jumps" when a parent widget rebuilds (e.g., during a tap).
-   **Persistent Drifting**: All labels use `PremiumAnimatedText` with `hasDrift: true` for organic, asynchronous movement.
-   **Dynamic Achievement Colors**: Trophies and success overlays use themed colors:
    -   **Individual Mastery**: Trophy color matches the mastered card's nursery background.
    -   **Category Completion**: Trophies cycle through the nursery palette based on category index.
    -   **Sound Match**: Uses `Soft Mint` for victory states to reinforce success.

## 🛠️ Engineering & Production

-   **Splash Immersive**: Assets must use "Safe Margin" designs to accommodate diverse screen aspect ratios without cropping text.
-   **Android Manifest**: `INTERNET` permission is granted to ensure plugin stability in release builds.
-   **Kotlin Stack**: Project uses Kotlin DSL (`.kts`) and targeting Java 17 for modern standard compatibility.

---

*Updated: April 18, 2026 - Sensory Unification & Offline Reliability Pass.*

---

## 🔊 6. Audio Sensory Association
We follow a strict sequence to build sensory understanding:
1.  **Voice (Name)**: Speak the word clearly.
2.  **Sound (Action)**: Play the corresponding action/animal sound.
-   **Buffer**: **0ms** delay between clips for tight neural association.
-   **Context**: VO always respects the `parentalSettingsProvider` level.

---

## 💾 7. Data Layer Schemas

### Models (`lib/data/models/`)
-   **`Module`**: Top-level entry (Name, Icon, Route).
-   **`Category`**: Group of items (Name, Image).
-   **`ContentItem`**: The atomic learning unit.
    -   `voicePath`: Recording of the word.
    -   `soundPath`: Recording of the action/effect.

---

## 🛡️ 8. Child Safety & Parental Gate
-   **Gate Logic**: 3-second `onLongPress` required to exit the Child Zone.
-   **Screen Time**: Automatically redirects to the Parental Menu when the daily limit (set by `ScreenTimeService`) is reached.

---

## 📦 9. Shared Widget Inventory
-   **`BreathingWidget`**: Subtle scale-loop for interactive elements.
-   **`PremiumAnimatedText`**: Standardized text motion.
-   **`CategoryCelebrationOverlay`**: Full-screen confetti and star reward logic.
-   **`VolumeSliderTile`**: Premium settings slider.

---

## 🎮 10. Feature Modules

### **HomeScreen (Home Hub)**
-   Displays the "Module Grill" (Board Book, Sound Match, etc.).
-   Features the Premium Greeting (`PremiumAnimatedText` with Shimmer).

### **Board Book**
-   Interactive "Flashcard" style learning.
-   Supports category-based swiping and per-item star progress.

### **Sound Match (Upcoming)**
-   2x2 grid matching game.
-   Uses the standardized "Dancing Drift" for game tiles.

---
