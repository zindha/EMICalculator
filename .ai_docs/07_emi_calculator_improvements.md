# 07 — EMI Calculator Improvements

## Overview

This release polishes the core EMI Calculator with a cleaner UX, months/years toggle, richer result cards, history persistence, and export/share support.

## Changes

### Input UX
- Added a months/years toggle above the tenure slider (`TenureToggle`).
- Slider label and suffix adapt to the selected mode.

### Result Card
- `HeroCard` now shows a -stat grid:
  - Principal
  - Interest
  - Total Payment
  - Loan Health Score
- Existing animated EMI counter is preserved.

### History & Favorites
- Added `HistoryRepository` (`lib/features/history/data/repositories/history_repository.dart`) backed by Hive.
- Added `HistoryNotifier` provider (`lib/features/history/presentation/providers/history_provider.dart`).
- Calculator app bar now has a save action to persist the current calculation.
- `HistoryPage` displays saved calculations with favorite and delete actions.

### Export & Share
- Added `calculator_actions.dart` helper for save/export.
- Share action supports PDF, CSV, and image capture of the calculator screen.
- `ExportService` already supported PDF and CSV; image capture uses `RepaintBoundary` + `Share.shareXFiles`.

### Settings
- Added placeholder tiles for Currency, Rate App, and Privacy Policy.
- Updated version label to 1.3.0.

## Tests

- Widget test for `TenureToggle` should be added.
- Unit test for `HistoryRepository` save/favorite/delete should be added.

## Future Work

- Full currency selection and formatting integration.
- Rate App and Privacy Policy actions.
- Material You dynamic color support.
- Expandable amortization schedule grouping by year.
