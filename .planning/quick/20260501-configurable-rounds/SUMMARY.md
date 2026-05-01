# Quick Task: Configurable Rounds per Session

## Problem
The number of rounds (successful counting challenges) required to win is hardcoded to 3.

## Solution
- Add `totalRounds` to `GameLevel` model.
- Add a selector in `SettingsScreen` to adjust this value.
- Update `CountingScreen` to use the dynamic value.

## Status
Complete ✓
