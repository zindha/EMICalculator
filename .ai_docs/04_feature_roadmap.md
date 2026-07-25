# 04 — Feature Roadmap: 5 Production Phases

> **Strategy:** Build the foundation first, then the core differentiators, then the premium experience. Each phase is a shippable increment.

---

## Phase 1: Foundation (Project Scaffolding + Core Layer)

**Goal:** A compilable, themable app shell with routing and persistent storage initialized.

### Deliverables

| Task | File(s) | Status |
|---|---|---|
| `flutter create` project | Root `pubspec.yaml`, `main.dart` | ⬜ |
| Add all dependencies | `pubspec.yaml` | ⬜ |
| Set up `lib/core/` structure | All subdirectories | ⬜ |
| Theme engine (Light/Dark/AMOLED) | `lib/core/theme/` | ⬜ |
| Google Fonts integration | `lib/core/theme/app_typography.dart` | ⬜ |
| GoRouter setup with placeholder routes | `lib/core/routing/app_router.dart` | ⬜ |
| Custom ThemeExtension (`AppColorsExtension`) | `lib/core/theme/custom_theme_extension.dart` | ⬜ |
| Hive service + initialization | `lib/core/services/hive_service.dart` | ⬜ |
| App constants (numeric thresholds, hive keys) | `lib/core/constants/` | ⬜ |
| Shared widgets (AppCard, AppGauge stub) | `lib/shared/widgets/` | ⬜ |
| Number formatter mixin | `lib/shared/widgets/number_formatter.dart` | ⬜ |
| Feature shell directories | `lib/features/` (empty structure) | ⬜ |
| Code generation setup | `build.yaml`, `analysis_options.yaml` | ⬜ |

### Acceptance Criteria
- [ ] App compiles and runs on Android, iOS, Web
- [ ] 3 themes toggle correctly (Light / Dark / AMOLED)
- [ ] Hive boxes initialize without crash
- [ ] GoRouter navigates between placeholder feature screens
- [ ] `dart run build_runner build` succeeds

---

## Phase 2: MVP — Core Calculator + Dashboard

**Goal:** Fully functional EMI calculator with amortization chart, Loan Health Score, and EMI Stress Meter.

### Deliverables

#### 2.1 Calculator Feature — Domain Layer
| Task | File(s) |
|---|---|
| `EmiInput` freezed model | `features/calculator/domain/models/emi_input.freezed.dart` |
| `EmiResult` freezed model | `features/calculator/domain/models/emi_result.freezed.dart` |
| `AmortizationEntry` freezed model | `features/calculator/domain/models/amortization_entry.freezed.dart` |
| `EmiCalculationEngine` (EMI formula, edge cases) | `features/calculator/domain/engines/emi_calculation_engine.dart` |
| `LoanHealthScoreEngine` (score 0–100) | `features/calculator/domain/engines/loan_health_score_engine.dart` |
| `EmiStressMeterEngine` (stress levels) | `features/calculator/domain/engines/emi_stress_meter_engine.dart` |

#### 2.2 Calculator Feature — Data Layer
| Task | File(s) |
|---|---|
| Hive box for loan history | `features/calculator/data/datasources/loan_history_local_source.dart` |
| Repository implementation | `features/calculator/data/repositories/loan_history_repository_impl.dart` |

#### 2.3 Calculator Feature — Presentation Layer
| Task | File(s) |
|---|---|
| Providers (Riverpod) | `features/calculator/presentation/providers/` |
| Calculator Screen (form + results) | `features/calculator/presentation/pages/calculator_page.dart` |
| Amortization Schedule Widget | `features/calculator/presentation/widgets/amortization_table.dart` |
| Amortization Chart (fl_chart) | `features/calculator/presentation/widgets/amortization_chart.dart` |
| Health Score Badge Widget | `features/calculator/presentation/widgets/health_score_badge.dart` |
| Stress Meter Gauge Widget | `features/calculator/presentation/widgets/stress_meter_gauge.dart` |
| Result Summary Card | `features/calculator/presentation/widgets/result_summary_card.dart` |

#### 2.4 Dashboard Feature
| Task | File(s) |
|---|---|
| Dashboard Screen (recent calculations) | `features/dashboard/presentation/pages/dashboard_page.dart` |
| Loan history list tile widget | `features/dashboard/presentation/widgets/loan_history_tile.dart` |
| Quick actions (New Calc, Compare, Prepay) | `features/dashboard/presentation/widgets/quick_actions.dart` |

### Acceptance Criteria
- [ ] Enter Amount, Rate, Tenure → see correct EMI
- [ ] Edge cases handled: 0% interest, 1-month tenure, ₹1 crore+ loan
- [ ] Amortization chart renders with fl_chart
- [ ] Loan Health Score displays with correct color
- [ ] EMI Stress Meter animates on input change
- [ ] All numbers formatted in Indian locale (₹ 12,34,567)
- [ ] Previous calculations persist in Hive
- [ ] Dashboard shows last 10 calculations

---

## Phase 3: Differentiators — Comparison + Prepayment

**Goal:** The features that separate this app from a basic EMI calculator.

### Deliverables

#### 3.1 Comparison Feature
| Task | File(s) |
|---|---|
| `ComparisonInput` / `ComparisonResult` domain models | `features/compare/domain/models/` |
| `LoanComparisonEngine` (side-by-side analysis) | `features/compare/domain/engines/loan_comparison_engine.dart` |
| Comparison screen (multi-offer input) | `features/compare/presentation/pages/compare_page.dart` |
| Comparison card widget (single offer row) | `features/compare/presentation/widgets/comparison_card.dart` |
| Comparison chart (fl_chart grouped bar) | `features/compare/presentation/widgets/comparison_chart.dart` |
| "Best Pick" recommendation badge | `features/compare/presentation/widgets/recommendation_badge.dart` |
| Add/Remove offers (up to 5) | Riverpod notifier |

#### 3.2 Prepayment Feature
| Task | File(s) |
|---|---|
| `PrepaymentInput` / `PrepaymentResult` domain models | `features/prepayment/domain/models/` |
| `PrepaymentEngine` (3 strategies) | `features/prepayment/domain/engines/prepayment_engine.dart` |
| Prepayment screen (strategy selector) | `features/prepayment/presentation/pages/prepayment_page.dart` |
| Strategy comparison cards | `features/prepayment/presentation/widgets/strategy_card.dart` |
| Before/After amortization overlay chart | `features/prepayment/presentation/widgets/prepayment_chart.dart` |
| Savings summary (interest saved, months cut) | `features/prepayment/presentation/widgets/savings_summary.dart` |

### Acceptance Criteria
- [ ] Compare 2–5 loan offers with side-by-side metrics
- [ ] Comparison chart shows grouped bars for EMI, Interest, Total
- [ ] "Best Overall" recommendation works
- [ ] 3 prepayment strategies compute correctly (Reduce Tenure, Reduce EMI, Hybrid)
- [ ] Before/after chart visually shows interest saved
- [ ] Balance Transfer Analyzer calculates break-even month
- [ ] Remove or reorder offers during comparison

---

## Phase 4: Premium UX — Animations, Export, Accessibility

**Goal:** Polish the app to a premium, delightful experience.

### Deliverables

| Task | Description |
|---|---|
| **Animated number counters** | EMI, Savings, Interest animate on change |
| **Page transition animations** | Custom slide/fade route transitions |
| **Haptic feedback** | Haptics on slider, button, error |
| **Accessibility audit** | semanticLabels, contrast check, TalkBack testing |
| **Share / Export** | Share calculation as PDF or PNG summary card |
| **Localization** | English + Hindi (Phase 1), 5 more languages (Phase 2) |
| **Multi-currency** | Currency selector (USD, EUR, GBP, INR, JPY) |
| **App icon & splash screen** | Branded icon, animated splash |
| **Loading skeletons** | Shimmer placeholders during Hive read |
| **Empty & error states** | Illustrated empty states for no-history |
| **Dark mode micro-adjustments** | Fine-tuned shadows, opacities for dark/AMOLED |

### Acceptance Criteria
- [ ] Animations are smooth (60fps) on mid-range devices
- [ ] Accessibility Scanner reports ≥90% score
- [ ] PDF export generates correctly with all loan details
- [ ] App passes TalkBack navigation with logical focus order
- [ ] Multi-currency formatting works correctly
- [ ] Skeleton loading appears on first launch before Hive reads

---

## Phase 5: Future Growth (Post-Launch)

**Goal:** Expand the app into a comprehensive financial planning tool.

### Planned Features

| Feature | Priority | Description |
|---|---|---|
| **Balance Transfer Analyzer** | High | Simulate transferring balance to lower-rate card |
| **Loan Amortization PDF Reports** | High | Generate professional PDF for bank applications |
| **Payment Reminders** (Local Notifications) | Medium | Remind users before EMI due date |
| **Goal-Based Planning** | Medium | "I want to save ₹X on interest — how much extra to pay?" |
| **Tax Benefit Calculator** (Sec 80C / 24(b)) | Medium | For home loans in India |
| **Multi-Property Comparison** | Low | Compare loan options across multiple properties |
| **Web Version (PWA)** | Low | Fully responsive PWA deployment |
| **i18n — 5 more Indian languages** | Low | Regional language support |
| **Financial Glossary** | Low | 100+ financial terms with plain-English explanations |
| **Dark Mode Wallpapers** | Low | Curated wallpapers for AMOLED screens |
| **AI-Powered Loan Recommendations** | Experimental | Use on-device ML to suggest optimal loan structure |

---

## Development Principles (All Phases)

1. **Incremental Delivery:** Each phase is independently shippable. No phase depends on a future phase.
2. **No Regressions:** Every phase must pass all previous acceptance criteria.
3. **Tested Forward:** Write unit tests for new domain logic in every phase.
4. **Documentation First:** Write `.ai_docs/` entries before writing code for a new feature.
5. **Code Generation:** Run `build_runner` after every model/provider change — never manually edit generated files.
6. **Performance Budget:** Each screen must render in < 16ms (60fps). Use `DevTools` profiler regularly.
7. **Review Cycle:** Every PR/commit must pass the rules in `02_architecture_rules.md`.

---

## Dependency Versions (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Routing
  go_router: ^14.2.0

  # Models
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  # Storage
  hive_flutter: ^1.1.0
  hive: ^2.2.3

  # UI
  google_fonts: ^6.2.1
  dynamic_color: ^1.7.0
  fl_chart: ^0.68.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  # Code Gen
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  hive_generator: ^2.0.1

  # Linting
  flutter_lints: ^4.0.0
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10
```

> **Note:** Versions are approximate and should be verified against pub.dev at the time of Phase 1 implementation.
