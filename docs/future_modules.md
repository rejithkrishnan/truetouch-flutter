# 🧸 TrueTouch — Future Module Ideas

A catalog of toddler-friendly game modules under consideration for TrueTouch. Each module is designed to introduce a new interaction paradigm while respecting the app's sensory-friendly design philosophy.

---

## 🎨 1. Finger Paint Canvas

**Interaction**: Free-form touch drawing
**Plugin**: `CustomPainter` + `GestureDetector` (built-in Flutter)

- **Gameplay**: Free-form finger painting on a blank canvas with nursery palette colors.
- **Sensory Hook**: Each color has a unique haptic pattern. Shaking the phone clears the canvas with a "splash" animation.
- **Difficulty**: None — pure creative play. Great for motor skills.
- **Complexity**: Low
- **Status**: 💡 Idea

---

## 🧩 2. Drag & Drop Puzzle

**Interaction**: Drag-to-slot
**Plugin**: Flutter's built-in `Draggable` + `DragTarget`

- **Gameplay**: A simple 2x2 or 3x3 picture is split into pieces. The child drags each piece to its correct slot.
- **Sensory Hook**: Pieces "snap" with `mediumImpact` haptics. Correct placement triggers a confetti burst on that tile. Completing the puzzle reveals the animal and speaks its name.
- **Scoring**: Stars based on time or number of misplacements.
- **Difficulty**: Beginner (2x2) → Expert (3x3).
- **Complexity**: Medium
- **Status**: 💡 Idea

---

## 🎹 3. Baby Piano / Sound Board

**Interaction**: Multi-touch tap
**Plugin**: `just_audio` (already in project) or `flutter_midi` (new)

- **Gameplay**: Large, colorful keys on screen. Each key plays a musical note + shows a bouncing emoji (🎵, ⭐, 🌈).
- **Sensory Hook**: Keys use nursery palette colors. Pressing multiple keys creates "chords." Can switch between Piano, Xylophone, and Animal Sounds modes.
- **Scoring**: None — zero cognitive load, pure sensory play.
- **Complexity**: Low-Medium
- **Status**: 💡 Idea

---

## 🫧 4. Pop the Bubbles

**Interaction**: Rapid-tap moving targets
**Plugin**: `flame` (lightweight 2D game engine for Flutter — new dependency)

- **Gameplay**: Bubbles with letters/numbers/colors float up the screen. The child taps to pop them.
- **Sensory Hook**: Each pop triggers a satisfying "pop" SFX + mini confetti. Voice says the letter/number.
- **Educational**: Introduces letters and counting in a zero-pressure environment.
- **Why Flame?**: Handles smooth sprite rendering and collision detection efficiently for many floating objects.
- **Scoring**: Stars based on number of bubbles popped in a session.
- **Complexity**: Medium (new engine dependency)
- **Status**: 💡 Idea

---

## ✋ 5. Shape Sorter (Drag to Hole)

**Interaction**: Drag-to-match
**Plugin**: Flutter's built-in `Draggable` + `DragTarget` with `ClipPath`

- **Gameplay**: Shapes (Circle, Square, Triangle, Star) appear at the bottom. Matching cutout holes are at the top. The child drags each shape to its matching hole.
- **Sensory Hook**: Wrong hole — shape bounces back with a shake. Correct hole — shape "falls in" with a satisfying thud haptic + confetti. Voice says the shape name.
- **Difficulty**: Beginner (3 shapes) → Expert (6 shapes with similar shapes like Rectangle vs Square).
- **Complexity**: Medium
- **Status**: 💡 Idea

---

## 🎯 6. Peek-a-Boo (Where's the Animal?)

**Interaction**: Tap-to-reveal
**Plugin**: `flutter_animate` (already in project) + basic `Stack`/`Positioned`

- **Gameplay**: 3 bushes/boxes on screen. An animal sound plays. The child taps the bushes to find which one the animal is hiding behind.
- **Sensory Hook**: Bushes use `BreathingWidget`. Wrong bush — bush shakes, nothing inside. Correct bush — animal pops out with a bounce animation + confetti.
- **Scoring**: Stars based on accuracy (similar to Sound Match).
- **Complexity**: **Low** — reuses most of Sound Match's existing architecture.
- **Status**: 💡 Idea

---

## 🌈 7. Color Mixing Lab

**Interaction**: Drag-and-pour
**Plugin**: `CustomPainter` (built-in Flutter)

- **Gameplay**: Two "paint tubes" drip colors into a bowl. The child sees what new color they create (Red + Blue = Purple!).
- **Sensory Hook**: The bowl "swirls" with an animation. Voice says "You made Purple!" Great for early science concepts.
- **Difficulty**: Beginner (primary colors only) → Expert (secondary + tertiary).
- **Complexity**: Medium
- **Status**: 💡 Idea

---

## 🎨 8. Color Match

**Interaction**: Tap-to-match (like Sound Match but visual)
**Plugin**: Existing stack (no new dependencies)

- **Gameplay**: A "Magic Paint Bucket" fills with a color. The child picks the object that matches from a set of cards.
- **Sensory Hook**: Correct match "tips" the bucket and pours color-matched confetti. Voice says "Find the Red one!"
- **Scoring**: Stars based on accuracy per color.
- **Complexity**: **Low** — nearly identical architecture to Sound Match.
- **Status**: 📋 Planned (implementation plan drafted)

---

## Plugin Dependency Summary

| Plugin | Already in project? | Used by |
| :--- | :--- | :--- |
| `just_audio` | ✅ Yes | Piano, all modules (SFX) |
| `flutter_animate` | ✅ Yes | Peek-a-Boo, all modules (animations) |
| `confetti` | ✅ Yes | All modules (reward system) |
| `Draggable`/`DragTarget` | ✅ Built-in | Puzzle, Shape Sorter |
| `CustomPainter` | ✅ Built-in | Finger Paint, Color Mixing |
| `flame` | ❌ New | Bubble Pop |
| `flutter_midi` | ❌ New (optional) | Piano |

---

## Recommended Build Order

1. **Color Match** — Already planned, mirrors Sound Match architecture.
2. **Peek-a-Boo** — Low complexity, reuses Sound Match patterns.
3. **Baby Piano** — No new plugins needed, high engagement value.
4. **Shape Sorter** — Introduces drag interaction paradigm.
5. **Drag & Drop Puzzle** — Builds on Shape Sorter's drag mechanics.
6. **Pop the Bubbles** — Requires `flame` engine (new dependency).
7. **Finger Paint** — Pure creative play, no scoring needed.
8. **Color Mixing Lab** — Most complex, educational value is high.

---

*Created: May 1, 2026*
