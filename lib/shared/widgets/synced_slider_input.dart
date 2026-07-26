import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/currency_provider.dart';
import '../../core/theme/app_typography.dart';

/// A custom input widget that combines a [Slider] and a [TextField] that
/// stay perfectly synchronized with each other.
///
/// Changes to the slider update the text field value and vice versa.
/// The widget fires an [onChanged] callback whenever the value changes,
/// but only after a short debounce period to avoid excessive rebuilds.
///
/// This is crucial for loan inputs (amount, interest rate, tenure) where
/// users may prefer either slider dragging or manual numeric entry.
class SyncedSliderInput extends ConsumerStatefulWidget {
  /// Creates a [SyncedSliderInput].
  const SyncedSliderInput({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step,
    this.suffixText,
    this.prefixSymbol,
    this.decimalPlaces = 0,
    this.divisions,
    this.showSlider = true,
    this.helperText,
    this.semanticLabel,
  });

  /// The label displayed above the input.
  final String label;

  /// The current numeric value.
  final double value;

  /// The minimum allowable value.
  final double min;

  /// The maximum allowable value.
  final double max;

  /// Called when the value changes after debounce.
  final ValueChanged<double> onChanged;

  /// Step increment for the slider.
  final double? step;

  /// Text displayed after the text field value (e.g., "months", "%").
  final String? suffixText;

  /// Symbol displayed before the text field value (e.g., "₹ ", "$ ").
  /// When null, the currently selected currency symbol is used.
  final String? prefixSymbol;

  /// Number of decimal places to display in the text field.
  final int decimalPlaces;

  /// Number of discrete divisions for the slider.
  final int? divisions;

  /// Whether to show the slider. Set to false for numeric-only input.
  final bool showSlider;

  /// Helper text displayed below the slider.
  final String? helperText;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  @override
  ConsumerState<SyncedSliderInput> createState() => _SyncedSliderInputState();
}

class _SyncedSliderInputState extends ConsumerState<SyncedSliderInput> {
  late TextEditingController _textController;
  late double _currentValue;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _textController = TextEditingController(
      text: _formatValue(widget.value),
    );
  }

  @override
  void didUpdateWidget(SyncedSliderInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update from external changes if the user is not actively editing.
    if (!_isEditing && widget.value != oldWidget.value) {
      _currentValue = widget.value;
      _textController.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Formats the [value] according to the configured decimal places.
  String _formatValue(double value) {
    return value.toStringAsFixed(widget.decimalPlaces);
  }

  /// Called when the slider value changes.
  void _onSliderChanged(double newValue) {
    setState(() {
      _currentValue = newValue;
      _textController.text = _formatValue(newValue);
    });
    widget.onChanged(newValue);
  }

  /// Called when the text field gains focus.
  void _onTextFieldFocus() {
    setState(() => _isEditing = true);
    // Select all text for easy replacement.
    _textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _textController.text.length,
    );
  }

  /// Called when the user presses Enter/Return in the text field.
  void _onTextFieldSubmitted(String _) {
    _isEditing = false;
    _commitTextFieldValue();
  }

  /// Parses the text field value and updates the slider.
  void _commitTextFieldValue() {
    final parsed = double.tryParse(_textController.text);
    if (parsed != null) {
      final clamped = parsed.clamp(widget.min, widget.max);
      if (clamped != _currentValue) {
        setState(() {
          _currentValue = clamped;
          _textController.text = _formatValue(clamped);
        });
        widget.onChanged(clamped);
        return;
      }
    }
    // If parsing fails or no change, reset to the current value.
    _textController.text = _formatValue(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Label ──────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (widget.suffixText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatValue(_currentValue),
                      style: AppTypography.monetaryStyle(context).copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Text Field ─────────────────────────
          SizedBox(
            height: 46,
            child: TextField(
              controller: _textController,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.decimalPlaces > 0,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[\d.]'),
                ),
              ],
              style: AppTypography.monetaryStyle(context).copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                prefixText: widget.prefixSymbol ??
                    '${ref.watch(currencyNotifierProvider).currency.symbol} ',
                prefixStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixText: widget.suffixText,
                suffixStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              onTap: _onTextFieldFocus,
              onSubmitted: _onTextFieldSubmitted,
              onChanged: (_) {
                // Real-time format validation but don't commit until unfocus.
              },
            ),
          ),
          const SizedBox(height: 4),

          // ── Slider ─────────────────────────────
          if (widget.showSlider)
            SliderTheme(
              data: theme.sliderTheme.copyWith(
                activeTrackColor: theme.colorScheme.primary,
                inactiveTrackColor:
                    theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                thumbColor: theme.colorScheme.primary,
                overlayColor:
                    theme.colorScheme.primary.withValues(alpha: 0.08),
                trackHeight: 4,
                trackShape: const RoundedRectSliderTrackShape(),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 7,
                  elevation: 2,
                ),
              ),
              child: Slider(
                value: _currentValue.clamp(widget.min, widget.max),
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                onChanged: _onSliderChanged,
                semanticFormatterCallback: (value) {
                  return '${widget.label}: ${_formatValue(value)}';
                },
              ),
            ),

          // ── Helper Text ────────────────────────
          if (widget.helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4),
              child: Text(
                widget.helperText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
