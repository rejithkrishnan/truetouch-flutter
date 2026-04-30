# Color Match Module Implementation Plan

Build a new interactive learning module where children match objects to target colors.

## User Review Required

> [!IMPORTANT]
> **Target Visual**: I recommend a "Magic Paint Bucket" that tilts and "pours" color when tapped. 
> **Audio**: This module will focus on Color Names (e.g., "Find the Blue bird").

## Proposed Changes

### 1. Data Layer
- [NEW] `assets/modules/color_match/content.json`: Will contain categories like "Vibrant Colors" or "Soft Pastels".
- Each item will have an added `"hex"` field to identify its primary color for the game engine.

### 2. Implementation Logic
- **`ColorMatchNotifier`**: Manages the matching logic. 
- **Adaptive Confetti**: The confetti color will dynamically match the `targetColor` for a 100% immersive reward.
- **Difficulty**: Supports 2-card and 4-card layouts.

### 3. Files to Create
- `lib/features/color_match/models/color_match_state.dart` [NEW]
- `lib/features/color_match/providers/color_match_provider.dart` [NEW]
- `lib/features/color_match/color_match_screen.dart` [NEW]
- `lib/features/parent_menu/screens/color_match_settings_screen.dart` [NEW]

### 4. Integration
- Add "Color Match" to the **Home Hub**.
- Register in `ProgressService` for star tracking.

## Verification Plan

### Manual Verification
- Test color accuracy: Ensure a "Red" target only accepts "Red" objects.
- Check "Call to Action" re-play after 12s.
- Verify "Trophy Overlay" appears after a perfect 3-star round.
