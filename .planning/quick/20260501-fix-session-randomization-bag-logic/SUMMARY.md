---
status: complete
---
# Summary: Session Randomization Fix (Bag Logic)

## Changes
- **AssociationScreen**: Replaced random picking with a shuffled "bag" (list) of selected pairs. This ensures all selected words appear exactly once if rounds equals items.
- **CountingScreen**: Replaced `_usedNumbers` set with a shuffled `_numberBag`. This ensures unique counting targets throughout the session.
- **Improved UX**: Added logic to avoid the first item of a re-shuffled bag being the same as the last item of the previous bag.

## Verification
- Code analysis passed.
- Release APK built and installed successfully on tablet.
