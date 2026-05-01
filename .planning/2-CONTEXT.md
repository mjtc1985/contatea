# Phase 2 Context: Image-Word Association Game

## Decisions
- **Mechanic**: Single image at top, N word buttons below.
- **Data Model**: `AssociationPair` class containing `imagePath`, `imageUrl`, and `word`.
- **Distractors**: Automatically pulled from the `word` field of other pairs in the same level.
- **Rounds**: Uses the same `totalRounds` logic as the counting game.
- **Navigation**: Home screen will now allow choosing between "Counting" and "Association" games.

## Technical Details
- `GameType` enum: `counting`, `association`.
- `GameLevel` updated to include `List<AssociationPair>`.
- `SettingsScreen` will adapt based on the selected `GameType`.
