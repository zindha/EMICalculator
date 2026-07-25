# 02 — Architecture Rules: Feature-Driven Clean Architecture with Riverpod

> **Golden Rule:** Layers must NEVER leak. Presentation only talks to Domain via Riverpod providers. Domain only talks to Data via repository interfaces. Data implements those interfaces.

---

## 1. Project Structure (Immutable)

```
lib/
├── main.dart                          # App entry, ProviderScope, Hive init
├── app.dart                           # MaterialApp.router, theme, GoRouter
│
├── core/
│   ├── config/
│   │   └── app_config.dart            # App-wide constants (app name, version)
│   ├── constants/
│   │   ├── api_constants.dart         # Reserved for future API use
│   │   ├── app_constants.dart         # Numeric thresholds, limits
│   │   └── hive_constants.dart        # Hive box names, field keys
│   ├── theme/
│   │   ├── app_theme.dart             # ThemeData builder (light/dark/AMOLED)
│   │   ├── custom_theme_extension.dart # Custom ThemeExtension for brand colors
│   │   ├── app_colors.dart            # All color definitions
│   │   └── app_typography.dart        # Google Fonts + text styles
│   ├── routing/
│   │   └── app_router.dart            # GoRouter config, routes, redirects
│   └── services/
│       ├── hive_service.dart          # Hive initialization, box management
│       └── calculation_logger.dart    # (Optional) internal debug logging
│
├── shared/
│   ├── models/
│   │   ├── loan_offer.freezed.dart        # Freezed model for loan offers
│   │   ├── loan_offer.g.dart              # Generated JSON serialization
│   │   ├── amortization_entry.freezed.dart
│   │   └── amortization_entry.g.dart
│   ├── widgets/
│   │   ├── app_card.dart              # Reusable glassmorphism card
│   │   ├── app_gauge.dart             # Custom gauge widget (Stress Meter)
│   │   ├── health_score_indicator.dart # Loan Health Score badge
│   │   ├── number_formatter.dart      # INR/global formatting mixin
│   │   └── empty_state.dart           # Empty state placeholder
│   └── repositories/
│       └── loan_history_repository.dart  # Hive-backed loan history CRUD
│
└── features/
    ├── dashboard/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── calculator/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── compare/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── prepayment/
        ├── data/
        ├── domain/
        └── presentation/
```

---

## 2. Layer Isolation Rules

### Presentation Layer (`presentation/`)
| ✅ Allowed | ❌ Forbidden |
|---|---|
| Import Riverpod providers | Import Hive directly |
| Use `ConsumerWidget` / `ConsumerStatefulWidget` | Use `setState()` (except for AnimationControllers) |
| Call provider `ref.read()` / `ref.watch()` | Calculate EMI/stress/score inline |
| Render formatted data via shared widgets | Access `BuildContext` outside widget tree |
| Trigger notifier methods on user actions | Direct DB or file I/O |

### Domain Layer (`domain/`)
| ✅ Allowed | ❌ Forbidden |
|---|---|
| Pure Dart classes (no Flutter dependency) | Import `package:flutter/` |
| Calculation engines (EMI, amortization, score) | Access Hive, SharedPreferences, or any I/O |
| Repository abstract interfaces | Depend on any generated code (freezed/riverpod) |
| `Either<Failure, Success>` or sealed result types | UI rendering or BuildContext |
| `@freezed` model classes (shared layer) | Side effects (logging to file, etc.) |

### Data Layer (`data/`)
| ✅ Allowed | ❌ Forbidden |
|---|---|
| Implement repository interfaces | Expose Hive types to domain |
| Hive box read/write operations | Calculation logic |
| DTO → Domain model mapping | Flutter widget imports |
| Freezed + JsonSerializable models | Business rules/validation |

---

## 3. Riverpod Usage Contract

### Provider Types (Use in this priority order)

```dart
// 1. Simple providers — for pure computation, no disposal needed
//    Use for: calculation results, derived state, pure functions
@riverpod
SomeResult myCalculator(MyCalculatorRef ref) { ... }

// 2. Notifier — for mutable state with methods
//    Use for: form state, loan inputs, toggle switches
@riverpod
class LoanInputNotifier extends _$LoanInputNotifier {
  @override
  LoanInput build() => const LoanInput();
  void updateAmount(double amt) => state = state.copyWith(amount: amt);
}

// 3. AsyncNotifier — for async operations with loading/error states
//    Use for: Hive read/write, future calculations
@riverpod
class LoanHistoryNotifier extends _$LoanHistoryNotifier {
  @override
  Future<List<LoanOffer>> build() async { ... }
}

// 4. StreamProvider — for reactive streams
//    Use for: Hive box watchers, real-time updates
@riverpod
Stream<List<LoanOffer>> loanHistoryStream(LoanHistoryStreamRef ref) { ... }
```

### Naming Conventions

| Pattern | Example |
|---|---|
| `calculatorProvider` | `loanCalculatorProvider` |
| `inputNotifierProvider` | `loanInputNotifierProvider` |
| `historyNotifierProvider` | `loanHistoryNotifierProvider` |
| Provider file name | `providers/calculator_provider.dart` |

### Autodispose Rules
- Stateless providers (pure computations) → `@riverpod` (auto-dispose by default)
- Notifiers holding form/input state → `@Riverpod(keepAlive: true)`
- Hive stream providers → `@riverpod` (auto-dispose OK, streams re-establish)

---

## 4. Dependency Injection Rules

- **Never** use `Provider.of<T>()` or `context.read<T>()` manually.
- Use Riverpod's `ref.read()` / `ref.watch()` exclusively.
- Repository interfaces are injected via Riverpod `Provider`:
  ```dart
  @riverpod
  LoanHistoryRepository loanHistoryRepository(LoanHistoryRepositoryRef ref) {
    return LoanHistoryRepositoryImpl(hiveService: ref.watch(hiveServiceProvider));
  }
  ```

---

## 5. Error Handling Contract

```dart
// In domain layer — sealed result types
sealed class CalculationResult<T> {
  const CalculationResult();
}
final class Success<T> extends CalculationResult<T> {
  final T data;
  const Success(this.data);
}
final class Failure<T> extends CalculationResult<T> {
  final String message;
  final Object? error;
  const Failure(this.message, {this.error});
}

// In presentation layer — Notifier handles errors
@riverpod
class LoanCalculatorNotifier extends _$LoanCalculatorNotifier {
  @override
  CalculationResult<EmiResult> build(LoanInput input) {
    try {
      final engine = EmiCalculationEngine();
      final result = engine.calculate(input);
      return Success(result);
    } on CalculationException catch (e) {
      return Failure(e.message, error: e);
    } catch (e) {
      return Failure('Unexpected calculation error', error: e);
    }
  }
}
```

---

## 6. Code Generation Pipeline

Every time models or providers change, run:

```bash
# Riverpod code gen
dart run build_runner build --delete-conflicting-outputs

# Or watch for continuous generation
dart run build_runner watch --delete-conflicting-outputs
```

**Do NOT** manually edit `.freezed.dart`, `.g.dart`, or `.riverpod.dart` files.

---

## 7. Testing Strategy

| Layer | Test Type | Tools |
|---|---|---|
| **Domain** (engines, models) | Unit tests | `flutter_test` |
| **Data** (repositories) | Unit tests with Hive mock | `flutter_test`, `hive` mock |
| **Presentation** (providers) | Provider tests | `riverpod` test utilities |
| **Presentation** (widgets) | Widget tests | `flutter_test`, `WidgetTester` |
| **Integration** | Full flow tests | `integration_test` |

File naming: `{file_name}_test.dart` alongside source files.

---

## 8. What NOT To Do

❌ **DO NOT** use `Provider`, `ChangeNotifierProvider`, `MultiProvider` — Riverpod only.
❌ **DO NOT** use `ScaffoldMessenger.of(context).showSnackBar()` — use a global snackbar notifier or pass via ref.
❌ **DO NOT** import domain or data files directly into widgets — go through providers.
❌ **DO NOT** create `StatefulWidget` with `setState` for business state — use Notifier.
❌ **DO NOT** hardcode numeric thresholds — define in `constants/app_constants.dart`.
❌ **DO NOT** skip error handling for edge cases (0% interest, 0 tenure, negative values).
