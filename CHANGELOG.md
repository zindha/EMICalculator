# Changelog

## 1.5.0 - Production Release

### Fixed
- **History screen infinite loading:** `HistoryNotifier` now recovers from repository/Hive failures and immediately shows an attractive empty state instead of spinning forever.
- **Calculator editing workflow:** added Reset, Undo, and Redo to `CalculatorInputNotifier` with a session-level history stack.
- **Privacy Policy launch failure:** Settings now launches the external privacy policy URL via `url_launcher` and shows a Material dialog/SnackBar on error instead of failing silently.
- **Application branding:** replaced generic "Smart Loan Planner" header with the official app name and Dzynova Technologies branding on Dashboard, Splash, and About screens.
- **About page:** redesigned as a professional card-based layout showing app icon, app name, version, developer, contact email, and copyright.
- **Quick Actions layout:** cards now use a responsive, adaptive grid that scales from small phones to tablets and landscape.
- **Bottom Navigation:** improved height, padding, icon/label sizing, SafeArea handling, and touch targets (48dp minimum) for a professional feel.
- **Page headers:** consistent height, spacing, typography, and SafeArea usage across Dashboard, Calculator, History, and Settings.
- **Settings responsiveness:** fixed accent color section, cards, list tiles, and About section for small, medium, large, and landscape screens; prevented overflow and clipping.
- **Material 3 consistency:** unified card radii, button radii, padding, margins, typography, elevation, loading indicators, and section spacing across all screens.
- **Performance:** removed unnecessary rebuilds, added missing `const` constructors, and cleaned up unused imports / dead code.
- Release signing: replaced debug-only signing with `key.properties`-based release config (falls back to debug if keystore absent).
- Broken `$e` error interpolation in `const` SnackBars on prepayment and what-if pages.
- Silent `catch (_)` error swallowing in 3 repositories (history, comparison, prepayment) — now logs via `debugPrint`.
- AMOLED mode: replaced the `ThemeMode.system` hack with a proper `isAmoled` flag + Hive persistence.
- Version number mismatch: synced settings page (`1.2.0` → `1.0.0`) to match `pubspec.yaml`.
- Missing privacy policy URL — added `AppConstants.privacyPolicyUrl`.
- Hardcoded `Color(0xFF...)` values replaced with `AppColors` constants across 6 chart, table, and page files.
- `dart:ui` import removed from domain-layer `prepayment_export_service.dart`.
- Deprecated `Color.value` usage eliminated — component accessors and `Color == Color` comparisons.
- Off-screen TextField tap warning in `what_if_page_test.dart`.
- Splash screen timer leak in `widget_test.dart`.

### Added
- **Calculator undo/redo tests:** new unit tests for `CalculatorInputNotifier` history stack (reset, undo, redo, redo-after-edit clears forward history, boundary no-ops).
- **History error-recovery tests:** new unit tests verifying `HistoryNotifier` falls back to an empty list when the repository throws and preserves existing data when refresh fails.
- `mocktail` dev dependency to support notifier/repository unit tests.
- `url_launcher` dependency for external privacy policy links.
- Reduce Motion support: animations respect `MediaQuery.disableAnimations` across 4 widgets (router transitions, tenure toggle, hero card, calculator cross-fade).
- Semantics labels on 6 chart widgets (pie, line, bar, grouped bar, principal-interest, savings bars).
- Shared `ImageExportService` utility — replaces ~120 lines of duplicated image capture/share code across 4 pages.
- `EmiCalculatorService` unit tests: 26 test cases covering EMI, interest, payment, amortization, health score, stress levels, and validation.
- `dynamic_color` integration for Material You on Android 12+.
- Production release keystore (`upload-keystore.jks`) and `android/key.properties` for Play Store signing.
- `privacyPolicyUrl` constant wired into the Settings page.

### Changed
- `flutter_lints` downgraded to `^5.0.0` for Dart 3.6.x compatibility.
- 26 test variable declarations changed from `final` to `const`.
- Flutter web bootstrap config cleaned up.
- `ExportException` classes kept with `const` constructors; PDF `TextStyle` constructors use `// ignore` comments due to Dart 3.6 const restrictions.

### Quality
- **Static analysis:** 0 errors, 0 warnings, 0 info (`flutter analyze` passes clean).
- **Test suite:** 77/77 tests passing.
- **Code reuse:** `ImageExportService` eliminates duplicated export logic; `_colorToInt()` helper replaces deprecated `Color.value` usage.

## 1.4.0 - What If Simulator

### Added
- Real-time What If Simulator to compare a baseline loan scenario with a modified one.
- Interactive sliders for loan amount, interest rate, and tenure.
- Instant updates for EMI, total interest, and total payment as sliders move.
- Side-by-side comparison cards for baseline and new scenarios.
- Savings / extra cost summary card with color-coded values.
- Payment breakdown pie chart comparing both scenarios.
- Reset button to restore baseline values.
- Image export/share for the what-if comparison.
- Unit tests for the what-if provider.

## 1.3.0 - EMI Calculator Improvements

### Added
- Months/Years toggle for tenure input on the calculator.
- Expanded result card with Principal, Interest, Total Payment, and Health Score.
- Save-to-history action in the calculator app bar.
- Export/share action supporting PDF, CSV, and image capture.
- Functional History page with favorite and delete actions.
- Settings tiles for Currency, Rate App, and Privacy Policy.

## 1.2.0 - Loan Prepayment Planner

### Added
- Loan Prepayment Planner to simulate prepayments and their impact on loans.
- Support for one-time, monthly, quarterly, half-yearly, yearly, custom, and combined prepayment rules.
- Two prepayment strategies: Reduce Tenure and Reduce EMI.
- Original vs. updated loan summary: EMI, tenure, total interest, total payment, interest saved, money saved, months saved, and completion date.
- Interactive balance timeline chart and payment breakdown pie chart.
- Per-rule smart recommendations (e.g., "Paying ₹5,000 extra every month saves ₹3.2 Lakhs.").
- Export prepayment plans as PDF, CSV, or image.
- Save, history, and favorites for prepayment plans via Hive.
- Unit tests for prepayment engine and repository.

## 1.1.0 - Loan Comparison Module

### Added
- Loan Comparison feature to compare 2, 3, 4, or unlimited loan offers side-by-side.
- Editable loan input cards for Loan Name, Loan Amount, Interest Rate, Tenure, Processing Fee, Insurance, and Down Payment.
- Comparison highlights: Lowest EMI, Lowest Interest, Shortest Tenure, Lowest Total Payment, and Best Overall Value.
- Horizontal scrollable comparison table.
- Comparison charts: grouped cost bars, principal vs. interest bars, and savings bars.
- Dynamic smart insights with human-readable recommendations.
- Export comparisons as PDF, CSV, or image.
- Save, history, favorites, rename, and duplicate comparison sessions via Hive.
- Unit and widget tests for comparison engine, smart insights, repository, and table.

## 1.0.0 - Initial Release

### Added
- EMI Calculator with sliders for loan amount, interest rate, and tenure.
- Advanced fields for processing fee, insurance, and down payment.
- Amortization schedule with PDF and CSV export.
- Loan Health Score and EMI Stress Meter.
- Dashboard with quick actions and recent calculations.
- Light, Dark, and AMOLED themes.
