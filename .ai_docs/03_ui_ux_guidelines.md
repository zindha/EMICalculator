# 03 — UI/UX Guidelines: Material 3 Design System & Custom Theme Engine

> **Design Philosophy:** "Financial decisions deserve clarity, confidence, and calm." Every pixel should reduce anxiety, not increase it.

---

## 1. Theme Engine Architecture

### 1.1 Theme Modes (3 modes)

| Mode | Primary Background | Surface | Use Case |
|---|---|---|---|
| **Light** | `#FFF8F0` (warm white) | `#FFFFFF` | Default daytime use |
| **Dark** | `#1A1A2E` (deep navy) | `#16213E` | Night mode, battery saving |
| **AMOLED** | `#000000` (pure black) | `#0D0D0D` | AMOLED displays, max contrast |

### 1.2 Dynamic Color Integration

```dart
// In app_theme.dart
final ColorScheme colorScheme = ColorScheme.fromImageProvider(
  provider: AssetImage('assets/brand_gradient.png'),
  brightness: brightness,
);
```

Fallback: If dynamic color source isn't available, use hardcoded brand palette.

### 1.3 Brand Color Palette

```
Primary:     #6C63FF  (Periwinkle — trust, stability)
Secondary:   #FF6584  (Coral — urgency, action)
Tertiary:    #00C9A7  (Mint — savings, success, money)

Positive:    #2ECC71  (Green — savings, health, good)
Warning:     #F39C12  (Amber — moderate stress, caution)
Danger:      #E74C3C  (Red — high stress, risky)
Info:        #3498DB  (Blue — information, tips)

Surface Warm:#FFF8F0  (Light base)
Surface Cool:#F0F4FF  (Alternate light surface)
```

### 1.4 Custom ThemeExtension

```dart
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color loanHealthExcellent;
  final Color loanHealthFair;
  final Color loanHealthRisky;
  final Color stressLow;
  final Color stressModerate;
  final Color stressHigh;
  final Color stressCritical;
  final Color savingsGreen;
  final Color costRed;
  final Color glassmorphism; // semi-transparent white/black for glass effect

  // ...copyWith, lerp implementations
}
```

---

## 2. Typography (Google Fonts)

### Font Stack

| Usage | Font | Weight | Size |
|---|---|---|---|
| **Display / Hero Numbers** | `GoogleFonts.spaceGrotesk()` | Bold (700) | 36–48px |
| **Headlines (H1–H3)** | `GoogleFonts.spaceGrotesk()` | SemiBold (600) | 24–32px |
| **Subheadings (H4–H6)** | `GoogleFonts.inter()` | Medium (500) | 18–22px |
| **Body / Labels** | `GoogleFonts.inter()` | Regular (400) | 14–16px |
| **Monetary Values** | `GoogleFonts.jetBrainsMono()` | Medium (500) | Tabular figures |
| **Caption / Small** | `GoogleFonts.inter()` | Regular (400) | 10–12px |

### Text Style Rules

- All monetary values use `JetBrains Mono` for aligned tabular figures.
- Key results (EMI, Savings, Interest) use `Space Grotesk` Bold at 32px+.
- Tooltips and helper text use Inter Regular 12px with 80% opacity.
- Line height: 1.5 for body, 1.2 for headings.

---

## 3. Spacing & Layout System

### 3.1 Base Unit

Base spacing unit = **8px**. All padding and gaps follow multiples of 8:

| Token | Value | Usage |
|---|---|---|
| `sp4` | 4px | Micro spacing, icon gaps |
| `sp8` | 8px | Tight padding, chip spacing |
| `sp16` | 16px | Default padding, card content |
| `sp24` | 24px | Section padding, card margins |
| `sp32` | 32px | Large sections, modal padding |
| `sp48` | 48px | Screen edge margins (desktop/tablet) |
| `sp64` | 64px | Hero section padding |

### 3.2 Corner Radii

| Token | Value | Usage |
|---|---|---|
| `radiusSm` | 8px | Chips, small badges |
| `radiusMd` | 16px | Default card rounding |
| `radiusLg` | 24px | Modals, bottom sheets, large cards |
| `radiusXl` | 32px | Hero sections, special containers |
| `radiusFull` | 999px | Circular avatars, pill buttons |

---

## 4. Glassmorphism Card Pattern

```dart
/// Reusable AppCard widget with optional glassmorphism overlay.
///
/// Apply for: result cards, loan offer cards, comparison cards.
AppCard(
  child: ...,
  glass: true, // adds backdrop blur + semi-transparent overlay
  borderRadius: 24,
  elevation: 2,
)
```

### Glassmorphism Specs (Light Mode)
- Background: `Colors.white.withOpacity(0.7)`
- Border: `Colors.white.withOpacity(0.3)` (1px)
- Blur: `12px` backdrop blur
- Shadow: `0px 8px 32px 0px rgba(0, 0, 0, 0.08)`

### Glassmorphism Specs (Dark / AMOLED)
- Background: `Colors.white.withOpacity(0.05)`
- Border: `Colors.white.withOpacity(0.1)` (1px)
- Blur: `12px` backdrop blur
- Shadow: `0px 8px 32px 0px rgba(0, 0, 0, 0.3)`

---

## 5. Implicit Animation & Transitions

### Animation Guidelines

| Element | Animation | Duration | Curve |
|---|---|---|---|
| Card tap | Scale 1.0 → 0.97 → 1.0 | 200ms | `easeInOut` |
| Slider value change | Smooth slide | 100ms | `easeOut` |
| Number change (EMI) | Animated counter | 300ms | `easeOutCubic` |
| Page transition | Slide right → left | 300ms | `easeInOut` |
| Health Score change | Radial sweep + count up | 600ms | `easeOutBack` |
| Stress Meter needle | Rotate with spring | 500ms | `spring(damping: 0.7)` |
| Fade in results | Opacity 0 → 1 | 400ms | `easeIn` |
| Snackbar | Slide up + fade | 250ms | `easeOutCubic` |

### Disabling Animations
Users with `Reduce Motion` accessibility setting should see immediate transitions (0ms duration).

```dart
final disabledAnimations = MediaQuery.of(context).disableAnimations;
```

---

## 6. Visual Cue Semantics

| Color | Meaning | Usage |
|---|---|---|
| 🟢 **Green** (`#2ECC71`) | Savings, health, benefit | Interest saved, prepayment benefit, good score |
| 🔴 **Red** (`#E74C3C`) | Cost, penalty, risk | Total interest paid, penalty fees, critical stress |
| 🟡 **Amber** (`#F39C12`) | Warning, moderate | Moderate stress, fair score |
| 🔵 **Blue** (`#3498DB`) | Information, neutral | Tips, explanations, tooltips |
| 🟣 **Purple** (`#6C63FF`) | Brand, action | Primary buttons, selected state |
| ⚪ **White/Grey** | Background, disabled | Cards, disabled inputs |

Always combine color with an icon or label — **never rely on color alone** for accessibility.

---

## 7. Feedback & Micro-interactions

### Haptic Feedback

| Action | Haptic Type |
|---|---|
| Slider value change | `HapticFeedback.lightImpact()` |
| Button tap | `HapticFeedback.mediumImpact()` |
| Error / invalid input | `HapticFeedback.heavyImpact()` |
| Calculation complete | `HapticFeedback.selectionClick()` |

### Sound
- No sounds in core app (respects silent mode).
- (Future: optional haptic-only "sound" via vibration patterns.)

---

## 8. Responsive Layout Strategy

| Screen Class | Width | Layout |
|---|---|---|
| **Compact** | < 600px | Single column, bottom sheet for details |
| **Medium** | 600–840px | Custom split: form left, results right |
| **Expanded** | > 840px | Full multi-column with comparison grid |

Use `LayoutBuilder` + `breakpoints` (not `MediaQuery`) for layout decisions to enable testability.

```dart
class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 840;
}
```

---

## 9. Accessibility (a11y) Requirements

- All tappable elements must have `semanticLabel`.
- All charts must have a `Semantics` container with a summary description.
- Minimum touch target: **48×48 dp**.
- Color contrast ratio: minimum **4.5:1** for normal text, **3:1** for large text.
- All interactive elements must be keyboard-focusable on web.
- Test regularly with `flutter run --enable-impeller` (for web) and Accessibility Scanner.
