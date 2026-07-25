import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Toggle switch for selecting tenure input in months or years.
class TenureToggle extends StatelessWidget {
  /// Creates a [TenureToggle].
  const TenureToggle({
    super.key,
    required this.inYears,
    required this.onChanged,
  });

  /// Whether the toggle is currently in years mode.
  final bool inYears;

  /// Called when the user selects a different mode.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Months',
              selected: !inYears,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'Years',
              selected: inYears,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
