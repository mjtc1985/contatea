# Quick Task: UI Homogeneity and Randomization Improvement

## Objective
1. Harmonize UI by using the progress bar from AssociationScreen in CountingScreen.
2. Ensure progress bar starts empty and increments correctly.
3. Prevent consecutive repetitions of the same item (number or word) in game rounds.

## Plan
1. **CountingScreen**:
   - Change `_currentRound` to start at 0.
   - Replace dot-based progress with `LinearProgressIndicator`.
   - Update `_generateNewChallenge` to avoid repeating the last target number.
2. **AssociationScreen**:
   - Update `_nextRound` to avoid repeating the last target word.
3. **Verification**:
   - Run `flutter analyze` to ensure no regressions.
   - Update `STATE.md`.
