# 05 — Loan Comparison Feature

## Overview

The Loan Comparison module enables users to compare multiple loan offers side-by-side and receive data-driven recommendations. It supports 2, 3, 4, or more loans, highlights the best value across key dimensions, and generates human-readable insights.

## Architecture

```
lib/features/comparison/
├── domain/
│   ├── models/
│   │   ├── loan_offer.dart              # Freezed model for a single loan
│   │   ├── comparison_session.dart      # Freezed model for saved sessions
│   │   └── comparison_result.dart       # Computed metrics and highlights
│   └── engines/
│       ├── comparison_engine_service.dart   # Side-by-side analysis
│       ├── smart_insights_service.dart      # Human-readable recommendations
│       └── comparison_export_service.dart   # PDF, CSV, and share helpers
├── data/
│   └── repositories/
│       └── comparison_repository.dart    # Hive-backed persistence
└── presentation/
    ├── providers/
    │   └── comparison_provider.dart      # Riverpod state management
    ├── widgets/
    │   ├── loan_input_card.dart          # Editable loan input card
    │   ├── comparison_table.dart         # Horizontal comparison table
    │   ├── comparison_charts.dart        # Bar and savings charts
    │   └── smart_insights_card.dart      # Insight display card
    └── pages/
        └── comparison_page.dart          # Main comparison screen
```

## State Management

The module uses Riverpod providers declared in `comparison_provider.dart`:

- `activeComparisonNotifierProvider`: `StateNotifierProvider` that holds the current session.
- `comparisonResultProvider`: `Provider` that derives the analyzed result.
- `comparisonInsightsProvider`: `Provider` that generates smart insights.
- `savedComparisonsNotifierProvider`: `StateNotifierProvider` that manages persisted sessions.

## Persistence

Sessions are stored as JSON strings in a Hive box (`HiveConstants.comparisonBox`).
This avoids requiring generated Hive adapters and keeps the domain layer pure.

## Highlights

- **Lowest EMI**: Offer with the smallest monthly payment.
- **Lowest Interest**: Offer with the smallest total interest.
- **Shortest Tenure**: Offer with the shortest duration.
- **Lowest Total Payment**: Offer with the smallest total outflow.
- **Best Overall Value**: Weighted score combining total payment, EMI, tenure, and loan health.

## Export

- **PDF**: Generated with the `pdf` package; includes a summary table and highlights.
- **CSV**: Plain-text table with all loan inputs and computed metrics.
- **Image**: Captures the comparison content via `RepaintBoundary` and shares as PNG.

## Tests

- `test/features/comparison/domain/engines/comparison_engine_service_test.dart`
- `test/features/comparison/domain/engines/smart_insights_service_test.dart`
- `test/features/comparison/data/repositories/comparison_repository_test.dart`
- `test/features/comparison/presentation/widgets/comparison_table_test.dart`
