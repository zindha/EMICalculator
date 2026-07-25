/// Application-wide constants for numeric thresholds, limits, and defaults.
///
/// All business-logic thresholds should be defined here rather than hardcoded
/// in UI or domain logic files.
class AppConstants {
  const AppConstants._();

  // ──────────────────────────────────────────────
  // Loan Input Limits
  // ──────────────────────────────────────────────

  /// Minimum loan amount in rupees.
  static const double minLoanAmount = 1000;

  /// Maximum loan amount in rupees.
  static const double maxLoanAmount = 100000000; // 10 Crore

  /// Default loan amount in rupees.
  static const double defaultLoanAmount = 500000; // 5 Lakh

  /// Minimum annual interest rate (percentage).
  static const double minInterestRate = 0.0;

  /// Maximum annual interest rate (percentage).
  static const double maxInterestRate = 50.0;

  /// Default annual interest rate (percentage).
  static const double defaultInterestRate = 10.5;

  /// Minimum loan tenure in months.
  static const int minTenureMonths = 1;

  /// Maximum loan tenure in months (30 years).
  static const int maxTenureMonths = 360;

  /// Default loan tenure in months.
  static const int defaultTenureMonths = 60; // 5 years

  /// Minimum processing fee (percentage).
  static const double minProcessingFee = 0.0;

  /// Maximum processing fee (percentage).
  static const double maxProcessingFee = 5.0;

  /// Minimum down payment in rupees.
  static const double minDownPayment = 0.0;

  // ──────────────────────────────────────────────
  // EMI Stress Meter Thresholds
  // ──────────────────────────────────────────────

  /// Maximum percentage of income considered "low stress".
  static const double stressLowThreshold = 0.20; // 20%

  /// Maximum percentage of income considered "moderate stress".
  static const double stressModerateThreshold = 0.35; // 35%

  /// Maximum percentage of income considered "high stress".
  static const double stressHighThreshold = 0.50; // 50%

  // ──────────────────────────────────────────────
  // Loan Health Score Thresholds
  // ──────────────────────────────────────────────

  /// Minimum score for "Excellent" loan health.
  static const int healthScoreExcellent = 80;

  /// Minimum score for "Fair" loan health.
  static const int healthScoreFair = 50;

  // ──────────────────────────────────────────────
  // Amortization Schedule
  // ──────────────────────────────────────────────

  /// Maximum number of months to display in amortization preview.
  /// If the loan tenure exceeds this, show a summary with pagination.
  static const int maxAmortizationPreviewMonths = 120;

  // ──────────────────────────────────────────────
  // Slider Step Values
  // ──────────────────────────────────────────────

  /// Step increment for loan amount slider.
  static const double loanAmountStep = 10000;

  /// Step increment for interest rate slider.
  static const double interestRateStep = 0.1;

  /// Step increment for tenure slider (in months).
  static const int tenureStepMonths = 1;

  // ──────────────────────────────────────────────
  // UI Constants
  // ──────────────────────────────────────────────

  /// Default padding value.
  static const double padding = 16.0;

  /// Default border radius for cards.
  static const double defaultCardRadius = 16.0;

  /// Large border radius for hero sections.
  static const double largeCardRadius = 24.0;

  // ──────────────────────────────────────────────
  // Legal
  // ──────────────────────────────────────────────

  /// URL for the app's privacy policy.
  ///
  /// Prefer [AppInfo.privacyPolicyUrl] for user-facing branding.
  static const String privacyPolicyUrl =
      'https://sites.google.com/view/emi-calculator-privacy';
}
