# ddxHabits

A Flutter habit-tracking app for building better habits and breaking bad ones. Track progress with visual grids, goal chains, money jars, journals, contracts, and timed challenges — with optional Dropbox sync across devices.

## Features

- **Six tracker types** to cover different ways of building habits:
  - **Habit Grid** — a visual grid of squares you fill in as you "pay" for progress with credit.
  - **Goal Chain** — a sequence of goals you complete one at a time, shown as a chain.
  - **Money Jar** — drag coins into a jar to save toward a goal, with a liquid-wave or coin-stack view.
  - **Good / Bad Habit Journal** — a monthly calendar for tracking daily habits, with streak tracking for bad habits you're trying to break.
  - **Habit Contract** — commit to a habit with a time, place, and consequence.
  - **Timed Habit** — a built-in stopwatch to time yourself and beat your best, for activities like running a distance (quicker is better) or holding a core exercise (longer is better).
- **Edit and delete** any tracker from the drawer or its card header. Deletions and renames are sync-safe using tombstones.
- **Dropbox sync** — connect your own Dropbox app key, and data syncs automatically on every save across devices.
- **Import / Export** — back up all data to a single JSON file or restore it.
- **Themes** — system, light, or dark mode.
- **About screen** — links to the project site and to James Clear's books.

## Getting Started

### Prerequisites

- Flutter SDK (see `pubspec.yaml` for the required Dart SDK constraint)
- A Dropbox app key if you want sync (create one at <https://www.dropbox.com/developers/apps> with the `files.content.read` and `files.content.write` scopes)

### Run

```sh
flutter pub get
flutter run
```

Supports Android, Windows, and Linux.

### Enable Dropbox sync

1. Create a Dropbox app at <https://www.dropbox.com/developers/apps> with app folder access.
2. Open **Settings → Connect to Dropbox**.
3. Paste your app key and follow the browser flow to authorize.
4. Data syncs automatically on every save. Use **Sync Now** in Settings to pull and merge remote changes.

## How Data Is Stored

- All data is stored as JSON files in a `storage/` directory next to the app executable (on desktop) or in the app documents directory (on mobile).
- Each tracker type has its own file, plus a `tombstones.json` file that tracks deletions/renames so sync never resurrects deleted items.

| File | Contents |
| --- | --- |
| `habit_grids.json` | Habit grids |
| `goal_chains.json` | Goal chains |
| `money_jars.json` | Money jars |
| `habit_journals.json` | Good/bad habit journals |
| `habit_contracts.json` | Habit contracts |
| `timed_habits.json` | Timed habits |
| `tombstones.json` | Deletion/rename tombstones |

## Project Structure

```
lib/
  models/       # Data models (grids, chains, jars, journals, contracts, timed habits)
  providers/    # ChangeNotifier providers (habit data, settings/theme)
  screens/      # Home, settings, create/edit dialogs, Dropbox setup, about
  services/     # Persistence, Dropbox sync, import/export
  utils/        # Colors/constants, storage path helper
  widgets/      # Tracker widgets, calendar, drawer, home body
```

# Todo
nothing for now

## Changelog
### 1.1.0
- Add habit contract tracker type.
- Add habit deleting (sync-safe via tombstones).
- Add habit editing.
- Add timed habit tracker type with stopwatch and quick/long improvement direction.
- Add Info section in settings linking to the app's about screen.

### 1.0.1
- Improved sync reliability, storage moved to a `storage/` directory.

### 1.0.0
- Base app with habit grids, goal chains, money jars, and habit journals.
