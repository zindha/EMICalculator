# 01 — Project Context: EMI Calculator — Smart Loan Planner

> **Tagline:** *Compare • Save • Pay Faster*
>
> **One-liner:** A Personal Loan Decision Assistant that empowers users to make smarter borrowing decisions through rapid scenario simulation, personalized repayment insights, and actionable savings strategies.

---

## 1. Product Vision

The **EMI Calculator — Smart Loan Planner** is not a basic number cruncher. It is a full-fledged **Personal Loan Decision Assistant** designed to:

- **Educate** users on the true cost of borrowing (total interest, processing fees, opportunity cost).
- **Empower** users to compare loan offers side-by-side across multiple lenders.
- **Accelerate** debt freedom with prepayment simulation, balance transfer analysis, and snowball/avalanche strategies.
- **Gamify** financial health through a proprietary **Loan Health Score** and **EMI Stress Meter**.

The app works **100% offline-first** — all computation runs locally on-device, ensuring privacy and reliability even without internet access.

---

## 2. Target Audience

| Segment | Pain Point | App Solution |
|---|---|---|
| **Salaried Professionals** | Unsure if EMI fits monthly budget | EMI-to-Income Ratio + Stress Meter |
| **Home Buyers** | Comparing multiple bank offers | Side-by-side comparison tool |
| **Debt Consolidators** | Multiple high-interest loans | Snowball & Avalanche prepayment strategies |
| **First-time Borrowers** | Hidden fees, complex jargon | Transparent cost breakdown with tooltips |
| **Early Repayers** | Wondering if prepayment saves money | Prepayment simulation with interest saved |

---

## 3. Unique Features (Differentiators)

### 3.1 Loan Health Score™
A **0–100 score** that rates the overall quality of a loan based on:
- **Interest Rate** (lower = better)
- **EMI-to-Income Ratio** (<30% = healthy)
- **Loan Tenure** (shorter = better, within affordability)
- **Fees** (processing fee %, prepayment penalty presence)
- **Credit Utilization** (derived from remaining debt)

**Color Coding:**
- ✅ **80–100:** Excellent (Green)
- ⚠️ **50–79:** Fair (Amber)
- ❌ **0–49:** Risky (Red)

### 3.2 EMI Stress Meter™
A visual gauge that shows how much financial strain a particular EMI imposes:

- **🟢 Low Stress** (EMI ≤ 20% of income) — Green zone
- **🟡 Moderate Stress** (EMI 20–35% of income) — Amber zone
- **🟠 High Stress** (EMI 35–50% of income) — Orange zone
- **🔴 Critical Stress** (EMI > 50% of income) — Red zone with pulsing animation

### 3.3 Smart Prepayment Simulator
Compare **three strategies** for extra payments:
1. **Reduce Tenure** — Keep EMI same, shorten loan term → maximum interest savings
2. **Reduce EMI** — Keep tenure same, lower monthly burden
3. **Custom Hybrid** — Custom split between tenure reduction and EMI reduction

Shows **exact interest saved**, **months shaved off**, and a **before/after amortization chart**.

### 3.4 Loan Comparison Engine
Compare up to **5 loan offers** simultaneously on:
- EMI, Total Interest, Total Payment
- Effective Interest Rate (including fees)
- Loan Health Score (each rated)
- Side-by-side amortization charts
- Recommendation badge ("Best Overall", "Lowest EMI", "Fastest Payoff")

### 3.5 Balance Transfer Analyzer
Simulate transferring an existing loan to a new lender at a lower rate:
- Shows break-even point (when savings offset transfer fees)
- Net savings over remaining tenure
- Recommendation: ✓ Transfer or ✗ Stay

---

## 4. Core User Workflows

```
FLOW 1: Quick Calculation
  Input Amount, Rate, Tenure → See EMI, Total Interest, Amortization Schedule

FLOW 2: Smart Assessment
  Input Amount, Rate, Tenure, Monthly Income, Fees → See Loan Health Score + Stress Meter

FLOW 3: Prepayment Planning
  Select Existing Loan → Choose Strategy (Reduce Tenure/EMI/Hybrid) →
  Input Extra Payment → See Interest Saved + New Schedule

FLOW 4: Compare Offers
  Add 2–5 Loan Offers → Side-by-Side Cards → Sort by EMI/Interest/Score →
  Pick the Best

FLOW 5: Balance Transfer
  Select Current Loan → Input New Rate & Transfer Fee →
  See Break-Even Month + Net Savings
```

---

## 5. Constraints & Assumptions

- **Offline-First:** All features must work without internet. No Firebase required for core functionality.
- **Privacy:** No user data is transmitted. All calculations stay on-device.
- **No Ads:** The app does not display third-party advertisements.
- **Single Currency Mode:** Primary currency is INR (₹) with comma-formatting (e.g., ₹12,34,567). Future: multi-currency support.
- **Free:** The app is free, with no paywalls for any feature.

---

## 6. Success Metrics (Internal)

| Metric | Target |
|---|---|
| Time to first EMI calculation | < 3 seconds from app launch |
| Loan offers compared per session | ≥ 2 |
| Prepayment simulations per user | ≥ 1 per session |
| App size (APK) | < 15 MB |
| Crash-free rate | > 99.5% |
| Accessibility score (Google Accessibility Scanner) | ≥ 90% |
