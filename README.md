# EMI Calculator

**Compare • Save • Pay Faster**

A professional personal loan decision assistant that helps users calculate EMIs, compare loan offers, simulate prepayments, and explore what-if scenarios with confidence.

Built with ❤️ by **Dzynova Technologies**.

## Latest Release Highlights

- **Polished, production-ready UI** — consistent Material 3 design, responsive layouts, and smooth transitions across phones, foldables, and tablets.
- **Calculator undo/redo/reset** — edit loan values with confidence using session-level history.
- **History that never hangs** — instant load with a graceful empty state and robust error recovery.
- **Dzynova Technologies branding** — professional About page with app version, developer info, contact email, and copyright.
- **Privacy Policy** — accessible from Settings and launched via `url_launcher` with proper error handling.
- **Responsive Quick Actions & Navigation** — adaptive grid, generous touch targets, and improved bottom navigation.

## Features

- **EMI Calculator**: Calculate monthly EMI, principal, interest, total payment, and amortization schedule. Supports months/years tenure toggle, processing fee, insurance, and down payment.
- **Loan Comparison**: Compare unlimited loan offers side-by-side with dynamic smart insights, comparison tables, and charts.
- **Loan Prepayment Planner**: Simulate one-time, monthly, quarterly, half-yearly, yearly, or custom prepayments. Choose between reducing EMI or tenure, with detailed savings analysis.
- **What If Simulator**: Compare a baseline loan scenario with a modified one in real time using interactive sliders.
- **History & Favorites**: Save, favorite, and browse recent calculations with local Hive persistence.
- **Loan Health Score**: Get a 0–100 score rating the overall quality of a loan.
- **EMI Stress Meter**: Visual gauge of financial strain based on income.
- **Export & Share**: Export schedules, comparisons, prepayment plans, and what-if scenarios as PDF, CSV, or image.
- **Themes**: Light, Dark, and AMOLED modes, plus Material You dynamic color support on Android 12+.

## Modules

### Loan Comparison
Compare unlimited loan offers side-by-side. Edit loan name, amount, interest rate, tenure, processing fee, insurance, and down payment. Highlights include lowest EMI, lowest interest, shortest tenure, and best overall value, backed by grouped charts and smart insights.

### Loan Prepayment Planner
Simulate prepayments with one-time, monthly, quarterly, half-yearly, yearly, or custom rules. Choose between reducing tenure or EMI, and see interest saved, money saved, months saved, and the updated completion date.

### What If Simulator
Explore how changes to loan amount, interest rate, and tenure affect cost. Compare baseline and modified scenarios side-by-side with real-time updates and a payment-breakdown pie chart.

## About Dzynova Technologies

Dzynova Technologies builds modern, reliable, and user-friendly mobile applications focused on productivity and everyday financial tools.

- **Developer**: Dzynova Technologies
- **Contact**: zindhak@gmail.com (also shown in-app on **Settings → About**)
- **Copyright**: © 2026 Dzynova Technologies. All Rights Reserved.

## Privacy

We value your privacy. The EMI Calculator processes loan calculations locally on your device and does not collect personal data.

- **Privacy Policy**: [https://sites.google.com/view/emi-calculator-privacy](https://sites.google.com/view/emi-calculator-privacy)

The Privacy Policy is also available inside the app from **Settings → Privacy Policy**.

## Tech Stack

- **Flutter** — cross-platform UI framework
- **Riverpod** — state management
- **Hive** — local NoSQL persistence
- **Material 3** — modern design system
- **go_router** — declarative routing

## Getting Started

This project is a Flutter application.

```bash
# Install dependencies
flutter pub get

# Run tests
flutter test

# Run the app
flutter run
```

New to Flutter? Check out the official resources:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
