# 🧸 TrueTouch Design System & Memory Bank

Welcome to the **TrueTouch Memory Bank**. This document serves as the single source of truth for the app's design language, sensory philosophy, and interactive patterns. Every new module (like Sound Match) must adhere to these standards to ensure a premium, cohesive experience for children and parents.

---

## 🌟 1. Design Philosophy
- **Sensory Friendly**: Use soft, nursery-inspired colors. Avoid harsh primary colors or high-contrast vibrations that might overstimulate.
- **Micro-Interactions**: Every tap should feel alive. Use confetti, scaling, and haptic feedback to reward exploration.
- **Premium Simplicity**: Use clean, modern typography (Quicksand) and translucent "glassmorphism" to make the app feel high-end, not "cheaply child-like."
- **Safe & Calm**: Backgrounds should be soft (Splash/Peach tints) with gentle animations (floating, rhythmic bobbing).

---

## 🎨 2. The Nursery Palette
Located in: `lib/core/theme/app_theme.dart`

| Color Name | Hex Code | Purpose |
| :--- | :--- | :--- |
| **Splash / Background** | `#F1D7C0` | Primary background and boot splash color. |
| **Soft Coral** | `#FF7373` | UI Accents, Card Labels. |
| **Soft Mint** | `#73D999` | Success states, Card Labels. |
| **Soft Sky** | `#73A6FF` | Navigation, Audio toggles. |
| **Soft Lavender** | `#BF8CE6` | Secondary categories, progress indicators. |
| **Golden Sunbeam** | `#FFCC4D` | **Premium Accents**, Welcome text, Section Headers. |
| **Soft Peach** | `#FF9966` | Secondary text, UI highlights. |
| **Translucent White** | `rgba(255, 255, 255, 0.1)` | Section containers, "Glass" panels. |

---

## 🖋️ 3. Typography
We use **Google Fonts: Quicksand** for its rounded, friendly, yet professional character.

- **Display Large**: (64px, 900 weight) — Primary titles (e.g., "True Touch").
- **Title Large**: (24px, 600 weight) — Sub-titles and section descriptors.
- **Headline Medium**: (48px, 800 weight) — Card labels and oversized interactive text.
- **Body Large**: (22px, 700 weight) — Interactive prompts and menu items.
- **Body Medium**: (18px, 500 weight) — Settings labels and secondary info.

---

## ✨ 4. Visual Atoms & Decorations

### Corner Radii
- **Activity Cards**: `24px` (pill-like or rounded rect).
- **Sub-pages / Settings Tiles**: `14px`.
- **Large Sections (Home)**: `32px`.

### Shadows
- **Card Shadow**: `BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, 6))`
- **Text Glow**: Subtle shadows for golden text: `Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)`.

---

## 📳 5. Interactive & Tactile Patterns

### Haptic DNA
| Action | Pattern | Implementation |
| :--- | :--- | :--- |
| **Card Tap** | Heavy Impact | `hapticServiceProvider.heavyImpact()` |
| **Success/Unlock** | Medium Impact | `HapticFeedback.mediumImpact()` |
| **Parental Hold** | Pulse Loop | `Timer` (100ms interval) + `selectionClick()` |

### Golden Shimmer
- **Usage**: Apply `.shimmer()` using `flutter_animate` to all Golden Sunbeam text.
- **Duration**: `2000.ms` for greetings, `4000.ms` for section headers.

---

## 📦 6. Shared Widget Library
- **`ActivityCard`**: Main entry point for modules on the home screen.
- **`SettingsTile`**: Standardized row for settings with icons and subtitles.
- **`VolumeSliderTile`**: Custom slider with icon leading and value tracking.
- **`StatChip`**: Circular analytics visualization with gold/white accents.

---

## 🎮 7. Upcoming: Sound Match Patterns
- **Grid Layout**: 2x2 or 2x3 grid of cards.
- **Match Animation**: Cards should scale up and shimmer when correctly matched.
- **Success State**: Full-screen confetti celebration using `CategoryCelebrationOverlay`.

---
