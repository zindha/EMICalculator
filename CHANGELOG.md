# Changelog

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
