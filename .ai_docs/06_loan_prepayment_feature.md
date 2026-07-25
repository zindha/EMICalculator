# 06 — Loan Prepayment Planner Feature

## Overview

The Loan Prepayment Planner enables users to simulate the effect of extra payments on a loan. Users can model one-time, recurring, or custom prepayments and choose between reducing the loan tenure or reducing the monthly EMI. The module provides original vs. updated loan metrics, a balance timeline chart, dynamic smart insights, and export/share capabilities.

## Architecture

```
lib/features/prepayment/
├── domain/
│   ├── models/
│   │   ├── prepayment_frequency.dart     # Enum: oneTime, monthly, quarterly, halfYearly, yearly, custom
│   │   ├── prepayment_strategy.dart      # Enum: reduceEmi, reduceTenure
│   │   ├── prepayment_rule.dart          # Immutable prepayment rule model
│   │   ├── prepayment_input.dart         # Immutable input model
│   │   └── prepayment_result.dart        # Result model with schedule and savings
│   └── engines/
│       ├── prepayment_engine_service.dart     # Core simulation engine
│       └── prepayment_export_service.dart     # PDF, CSV, image export
├── data/
│   └── repositories/
│       └── prepayment_repository.dart     # Hive-backed persistence
└── presentation/
    ├── providers/
    │   └── prepayment_provider.dart       # Riverpod state management
    ├── pages/
    │   └── prepayment_page.dart           # Main planner screen
    └── widgets/
        ├── prepayment_strategy_toggle.dart
        ├── prepayment_summary_card.dart
        ├── prepayment_timeline_chart.dart
        └── prepayment_what_if_sliders.dart
```

## Domain Logic

### PrepaymentEngineService

Pure Dart service that computes the updated amortization schedule given a `PrepaymentInput`.

- **Reduce Tenure:** EMI stays the same, extra payments reduce principal, and the loop terminates when the balance is cleared.
- **Reduce EMI:** Tenure stays the same, EMI is recalculated each month after applying the extra payment.
- Combined rules are flattened into a `Map<int, double>` of month → extra payment.
- Extra payments are capped to prevent overpayment.
- Total payment is derived from the last schedule entry's `totalPaidSoFar`.

## State Management

- `prepaymentInputNotifierProvider` manages the current input.
- `prepaymentResultProvider` watches the input and computes the result.
- `savedPrepaymentPlansNotifierProvider` manages saved plans.
- `prepaymentExportServiceProvider` exposes the export service.

## Persistence

- Plans are stored as JSON strings in the Hive `prepaymentBox`.
- Repository supports save, get, delete, toggle favorite, and get all sorted by creation date.

## UI

- Strategy toggle selects Reduce EMI or Reduce Tenure.
- What-if sliders adjust base loan amount, interest rate, and tenure.
- Prepayment rules list with add/remove support.
- Summary card shows original vs. updated metrics.
- Timeline chart visualizes the balance over time.
- Smart insights give human-readable recommendations.
- App bar actions for save, saved plans, and export/share.

## Export

- **PDF:** Full summary + amortization schedule via `pdf` package.
- **CSV:** Machine-readable summary + schedule.
- **Image:** Captures the current screen via `RepaintBoundary`.

## Tests

- Unit tests for `PrepaymentEngineService` covering reduce tenure, reduce EMI, combined rules, overpayment cap, and 0% interest.
- Unit tests for `PrepaymentRepository` covering save, get, delete, and toggle favorite.

## Future Enhancements

- Animated number counters for savings metrics.
- What-if comparison between Reduce EMI and Reduce Tenure side-by-side.
- Goal-based planning: "How much extra should I pay to save ₹X?"
- Balance transfer analyzer integration.
