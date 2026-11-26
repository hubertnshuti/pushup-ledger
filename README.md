# Pushup Ledger

An offline Android app for building a daily push-up habit. Set a daily goal of 50,
log your sets, and any reps you miss carry over as debt to be cleared by the end of
the week.

## Features

- **Daily goal** with live progress and morning and evening training windows
- **Carry-over debt**: missed reps roll forward and must be cleared by Sunday night
- **History**: a contribution grid of every day, plus a weekly summary
- **Reminders**: scheduled notifications based on your actual progress
- **Home-screen widget** showing what is left today
- **Backup export** to a JSON file
- **Private by design**: no account, no internet, all data stays on the phone

## Tech stack

- Flutter and Dart, Material 3 with a custom theme
- `provider` for state management
- SQLite (`sqflite`) for local storage
- `flutter_local_notifications` for exact scheduled reminders
- Kotlin for the home-screen widget and file export

## Architecture

```
lib/
├── core/      constants, dates, theme, text
├── domain/    pure Dart business rules (no Flutter imports)
├── data/      SQLite database and repositories
├── state/     app controller
├── services/  notifications, permissions, widget, backup
└── ui/        screens and widgets
```

The database stores only raw facts: the logged sets and a few settings. Progress,
debt, streaks and weekly results are all computed from them, so there is a single
source of truth. Time is injected through a `Clock`, which keeps the rules fully
testable.

## Getting started

Requirements: Flutter (stable) and the Android SDK.

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter analyze
flutter test
```

The test suite covers the business rules (daily goal, debt, week results, streaks,
reminder planning) and the main user flows.
