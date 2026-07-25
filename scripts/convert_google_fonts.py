import re
import os
import sys

FILES = [
    "lib/features/calculator/presentation/pages/calculator_page.dart",
    "lib/features/calculator/presentation/widgets/tenure_toggle.dart",
    "lib/features/calculator/presentation/widgets/calculator_actions.dart",
    "lib/features/calculator/presentation/widgets/hero_card.dart",
    "lib/features/calculator/presentation/widgets/result_charts.dart",
    "lib/features/comparison/presentation/pages/comparison_page.dart",
    "lib/features/comparison/presentation/widgets/loan_input_card.dart",
    "lib/features/comparison/presentation/widgets/smart_insights_card.dart",
    "lib/features/comparison/presentation/widgets/comparison_table.dart",
    "lib/features/comparison/presentation/widgets/comparison_charts.dart",
    "lib/features/prepayment/presentation/widgets/prepayment_summary_card.dart",
    "lib/features/prepayment/presentation/widgets/prepayment_pie_chart.dart",
    "lib/features/prepayment/presentation/widgets/prepayment_strategy_toggle.dart",
    "lib/features/prepayment/presentation/widgets/prepayment_timeline_chart.dart",
    "lib/features/history/presentation/pages/history_page.dart",
]

def parse_args(args_str):
    """Parse a simple comma-separated argument list into a dict of property -> value."""
    props = {}
    for part in args_str.split(","):
        part = part.strip()
        if not part:
            continue
        if ":" in part:
            key, value = part.split(":", 1)
            props[key.strip()] = value.strip()
    return props

def build_style(base, props, context="context"):
    """Build a style expression with .copyWith() if there are overrides."""
    if not props:
        return base
    copy = ", ".join(f"{k}: {v}" for k, v in props.items())
    return f"{base}?.copyWith({copy})"

def choose_space_style(props):
    size = props.get("fontSize")
    if size:
        try:
            size_val = int(size)
            if size_val >= 30:
                return "Theme.of(context).textTheme.displaySmall"
            if size_val >= 22:
                return "Theme.of(context).textTheme.headlineMedium"
        except ValueError:
            pass
    return "Theme.of(context).textTheme.titleLarge"

def choose_inter_style(props):
    weight = props.get("fontWeight")
    size = props.get("fontSize")
    if weight and ("w600" in weight or "w700" in weight or "w500" in weight or "bold" in weight.lower()):
        return "Theme.of(context).textTheme.labelLarge"
    if size:
        try:
            size_val = int(size)
            if size_val >= 14:
                return "Theme.of(context).textTheme.bodyLarge"
            if size_val >= 12:
                return "Theme.of(context).textTheme.bodyMedium"
        except ValueError:
            pass
    return "Theme.of(context).textTheme.bodyMedium"

def process_file(filepath):
    if not os.path.exists(filepath):
        print(f"Skipped (not found): {filepath}")
        return

    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    original = content
    needs_app_typography = False

    # Regex for single-line or simple multi-line GoogleFonts calls.
    # This intentionally does NOT handle nested parentheses.
    pattern = re.compile(r"GoogleFonts\.(\w+)\((.*?)\)", re.DOTALL)

    def replacer(match):
        nonlocal needs_app_typography
        family = match.group(1)
        args_str = match.group(2)
        props = parse_args(args_str)

        if family == "jetBrainsMono":
            needs_app_typography = True
            base = "AppTypography.monetaryStyle(context)"
            return build_style(base, props)
        elif family == "spaceGrotesk":
            base = choose_space_style(props)
            return build_style(base, props)
        elif family == "inter":
            base = choose_inter_style(props)
            return build_style(base, props)
        else:
            return match.group(0)

    content = pattern.sub(replacer, content)

    # Remove google_fonts import if no calls remain
    if "GoogleFonts." not in content:
        content = re.sub(
            r"import\s+['\"]package:google_fonts/google_fonts\.dart['\"];\n?",
            "",
            content,
        )

    # Add AppTypography import if needed and not already present
    if needs_app_typography and "AppTypography" not in content:
        # Find a good place after existing imports
        import_match = re.search(r"(import\s+['\"][^'\"]+\.dart['\"];\n)", content)
        if import_match:
            insert_pos = import_match.end()
            relative = _relative_import_path(filepath)
            content = content[:insert_pos] + f"import '{relative}core/theme/app_typography.dart';\n" + content[insert_pos:]

    if original != content:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Updated: {filepath}")
    else:
        print(f"No changes: {filepath}")

def _relative_import_path(filepath):
    """Return the relative path from the file to lib/core/theme/app_typography.dart."""
    parts = filepath.split("/")
    depth = len(parts) - 1
    # filepath is like lib/features/calculator/presentation/pages/calculator_page.dart
    # depth from lib: features/calculator/presentation/pages = 4 levels -> 4 * ../
    # We need to go back to lib, so depth levels of ../
    return "../" * depth

if __name__ == "__main__":
    for fp in FILES:
        process_file(fp)
