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
- **Golden Shimmer**: All premium/success text should use the "Golden Sunbeam" color (`0xFFFFCC4D`) and a `.shimmer()` animation.

## 💎 3. Premium Simplicity (Glassmorphism)
- **Glass Containers**: Use translucent white containers (`alpha: 0.1` to `0.15`) with subtle borders for high-end organization.
- **Typography**: Exclusively use the **Quicksand** font family. Keep labels clean and avoid cluttered interfaces.

## 📳 4. Tactile DNA (Haptics)
- **Standard Haptics**: 
  - Card Tap: `heavyImpact`
  - Success: `mediumImpact`
  - Parental Gate: 100ms pulse loop (`selectionClick`).
- Always respect the `isVibrationEnabled` setting before triggering haptics.

## 🛡️ 5. Child Safety & Parental Control
- **Parental Gate**: Any navigation out of the child zone MUST be protected by the 3-second hold-to-unlock gate.
- **Screen Time**: Adhere to the `screenTimeServiceProvider` limits for all module entry points.
