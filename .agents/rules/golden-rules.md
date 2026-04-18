---
trigger: always_on
glob: "**/*.dart"
description: Core design and interaction principles for the TrueTouch application.
---

# 🧸 TrueTouch Golden Rules

All code and UI changes must adhere to the following design philosophy to maintain a premium, sensory-friendly experience for children.

## 🌟 1. Sensory-Friendly Design
- **Color Palette**: Use only the approved "Nursery Palette" for all UI elements:
  - **Golden Sunbeam** (`0xFFFFCC4D`): Primary accents, shimmers, and success text.
  - **Soft Coral** (`0xFFFF7373`): Primary highlights and labels.
  - **Soft Mint** (`0xFF73D999`): Success states and secondary highlights.
  - **Soft Sky** (`0xFF73A6FF`): Navigation and inactive states.
  - **Soft Lavender** (`0xFFBF8CE6`): Category headers.
  - **Soft Peach** (`0xFFFF9966`): Secondary background tints.
  - **Splash Background** (`0xFFF1D7C0`): Primary page/scaffold backgrounds.
- **Calmness First**: UI should feel peaceful. Use soft gradients and rounded corners (minimum 14px, standard 24px).

## ✨ 2. Micro-Interactions & Rewards
- **Interactive Feedback**: Every user tap must provide tactile or visual feedback (confetti, scaling, or haptics).
- **Standardized Animation**: Use the **`PremiumAnimatedText`** widget for all animated text elements. It ensures consistent:
  - Per-character staggered entrance.
  - Looping Bobbing (`AnimationType.bobbing`) for titles.
  - **Dancing Drift**: Combine `AnimationType.bobbing` and `hasDrift: true` for interactive cards to create an organic, rhythmic wave.
  - Golden Sunbeam shimmer effects.

## 💎 3. Premium Simplicity (Glassmorphism)
- **Glass Containers**: Use translucent white containers (`alpha: 0.1` to `0.15`) with subtle borders for high-end organization.
- **The Card DNA**: All interactive cards MUST share the same tactical feedback:
  - **Visual**: `borderRadius: 24`, `alpha: 0.15` (Glass), and a standard shadow (`offset: Offset(0, 8)`, `blurRadius: 12`, `alpha: 0.15`).
  - **Interactive**: 300ms **0.9 Scale Bounce** animation on tap (scale down then spring back).
- **Typography**: Exclusively use the **Quicksand** font family. Keep labels clean and avoid cluttered interfaces.

## 🔊 4. Audio Sequencing & Sensory Association
- **Sequence Pattern**: When a child interacts with an object, always play the **Voice Name** first, followed immediately by the **Action/Animal Sound**.
- **Timing**: Use a 0ms buffer between clips to ensure tight sensory association between the word and the sound.
- **Volume Policy**: Respect the global `parentalSettingsProvider` volume levels for all sound effects.

## 📳 5. Tactile DNA (Haptics)
- **Standard Haptics**: 
  - Card Tap: `heavyImpact`
  - Success: `mediumImpact`
  - Parental Gate: 100ms pulse loop (`selectionClick`).
- Always respect the `isVibrationEnabled` setting before triggering haptics.

## 🛡️ 6. Child Safety & Parental Control
- **Parental Gate**: Any navigation out of the child zone MUST be protected by the 3-second hold-to-unlock gate.
- **Screen Time**: Adhere to the `screenTimeServiceProvider` limits for all module entry points.

## 🏆 7. Documentation & Continuity
- **Memory Bank Integrity**: Always update the **`DESIGN_SYSTEM.md`** (Memory Bank) to track all architectural, design, or behavioral changes in the app. This ensures the sensory DNA and technical standards are preserved for all future development.
