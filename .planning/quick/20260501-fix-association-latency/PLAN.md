# Quick Task: Fix Association Game Latency

## Objective
Remove the 1-second delay when selecting a correct answer in the Word Association game to match the speed of the Counting game.

## Plan
1. **AssociationScreen**:
   - Remove `Future.delayed` in `_handleOptionSelected` for correct answers.
   - Call `_nextRound()` immediately after `_audioService.playSuccess()`.
   - Optional: Cache file existence checks to avoid sync I/O in `build`.
2. **Verification**:
   - Build and test on tablet.
   - Update `STATE.md`.
