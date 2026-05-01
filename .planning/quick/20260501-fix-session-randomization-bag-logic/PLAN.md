# Quick Task: Fix Session Randomization with Bag Logic

## Objective
Ensure that both games (Counting and Word Association) use all selected items before repeating any, following a "bag" (shuffled list) mechanic.

## Changes
- **AssociationScreen**: 
    - Implemented `_remainingPairs` bag.
    - Shuffles pairs at the start and when empty.
    - Guaranteed usage of all selected items if rounds <= available items.
- **CountingScreen**:
    - Implemented `_numberBag` to replace `_usedNumbers` set.
    - Shuffles numbers from 1 to `targetCount`.
    - Correctly resets on "Play Again".

## Verification
- Code analysis.
- Build and deploy to tablet.
