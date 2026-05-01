# Phase 3 Context: Refined Game Logic & Selection

## Decisions
- **Association Selection Screen**: Added an intermediate step before the association game where the tutor selects which specific pairs will appear in the current session.
- **Counting Randomization**: 
  - If `totalRounds <= targetCount`, ensure all target numbers in a session are unique.
  - If `totalRounds > targetCount`, fallback to preventing only consecutive duplicates.
- **Association Repetition**: If the number of selected pairs is less than `totalRounds`, the game will cycle through the selected pairs to fill the session.

## Technical Details
- New Screen: `AssociationSelectionScreen`.
- `CountingScreen`: Maintain a `List<int> _sessionNumbers` to track used targets.
- `AssociationScreen`: Will receive a filtered list of `AssociationPair` from the selection screen.
