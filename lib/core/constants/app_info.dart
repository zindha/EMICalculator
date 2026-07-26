/// Centralized application branding and company information.
///
/// All user-facing strings related to the app name, company, and legal
/// information should be sourced from here so the app presents a consistent,
/// professional identity.
class AppInfo {
  const AppInfo._();

  /// Official application name displayed throughout the app.
  static const String appName = 'EMI Calculator';

  /// Short tagline shown under the app name.
  static const String tagline = 'Compare • Save • Pay Faster';

  /// Current application version.
  static const String version = '1.5.0';

  /// Company / developer name.
  static const String companyName = 'Dzynova Technologies';

  /// Contact email address — shown only inside the Privacy Policy.
  static const String contactEmail = 'zindhak@gmail.com';

  /// Short company description for the About screen.
  static const String companyDescription =
      'Modern finance tools designed to help users '
      'calculate, compare and optimize loans with confidence.';

  /// Copyright notice.
  static const String copyright = '© 2026 Dzynova Technologies';

  /// Full privacy policy URL (hosted on GitHub Pages).
  static const String privacyPolicyUrl =
      'https://zindha.github.io/EMICalculator/privacy-policy.html';
}
