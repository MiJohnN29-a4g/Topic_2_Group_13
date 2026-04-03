# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
flutter pub get      # Install dependencies
flutter run          # Run on connected device/emulator
flutter analyze      # Static analysis
flutter test         # Run tests
flutter clean        # Clean build artifacts
```

## Architecture Overview

**Flutter movie streaming app (FlixFilm)** - Netflix-style UI with movie/series browsing and playback.

### Project Structure

```
lib/
├── main.dart           # App entry point, MaterialApp with dark theme
├── models/
│   └── movie.dart      # Movie & Episode data models
├── data/
│   └── movie_data.dart # Hardcoded movie list (TMDB images, YouTube trailers)
└── screens/
    ├── login_screen.dart      # Landing page with login form
    ├── register_screen.dart   # Simple registration form
    ├── landing_screen.dart    # Main home screen with hero banner + trending row
    ├── home_screen.dart       # Alternate home screen (auto-rotating banner)
    ├── detail_screen.dart     # Movie details dialog with trailer preview
    └── watch_screen.dart      # Video player screen (movie or series with episodes)
```

### Key Patterns

- **Navigation**: Direct `Navigator.push/Replacement` between screens; `showDialog` for detail view
- **State Management**: `StatefulWidget` with local state; no global state management solution
- **Data Flow**: Static `movies` list in `movie_data.dart` serves as single data source
- **UI Theme**: Dark theme (`ThemeData.dark()`), black backgrounds, red accent color
- **Images**: `cached_network_image` for poster/backdrop caching from TMDB
- **Video**: YouTube embed via `webview_flutter` (currently placeholder until package added)

### Dependencies

- `cached_network_image` - Image caching
- `webview_flutter` - YouTube embed (declared but not fully integrated)
- `cupertino_icons` - iOS-style icons

### Notes

- Login/register screens are UI-only (no authentication backend)
- Series support: `Movie.episodes` list distinguishes movies from series
- Test file (`test/widget_test.dart`) contains default template test, not actual app tests
