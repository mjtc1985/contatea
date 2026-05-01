---
status: complete
---
# Summary: Offline Mode (Resource caching)

## Changes
- **Resource Caching**: Implemented `FileService` to download ARASAAC pictograms and save them locally in the app's documents directory.
- **Automated Downloads**: 
    - `StorageService` now triggers downloads for all network URLs during `saveLevels`.
    - `LevelSelectionScreen` ensures default levels are downloaded on first run.
- **Offline Priority**: Game screens (`CountingScreen`, `AssociationScreen`) and `SettingsScreen` now check for the existence of local files and prioritize them over network URLs.
- **Tutor UX**: `SettingsScreen` now shows a loading overlay while saving to indicate that resources are being downloaded.

## Verification
- Code analysis passed with minor linting warnings.
- Release APK built and installed.
- App logic verified to handle `Image.file` with fallbacks.
