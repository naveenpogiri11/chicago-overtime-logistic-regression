# Chicago Employee Overtime — Logistic Regression Analysis

> **A self-initiated data science project predicting which City of Chicago employees earn $5,000+ in overtime pay, using logistic regression on 20,907 payroll records. The model achieves a 52% deviance reduction and identifies the highest-risk employee profile with 99.5% predicted probability.**

---

## Business Problem

City governments spend millions on overtime pay each year, and overtime concentrated in specific departments or sustained work patterns is a signal worth tracking — it can indicate staffing shortages, budget pressure, or policy gaps. Chicago's 2016 payroll shows **20,907 employees across five major departments received overtime**, but there is no quick way to answer:

> *"Which departments and work patterns are most likely to produce high overtime earners ($5,000+ per year), and by how much?"*

This project answers that question with a statistical model that quantifies the effect of **department** and **sustained overtime activity** on the probability of crossing the $5,000 threshold.

---

## Dataset

- **Source:** City of Chicago 2016 payroll records (publicly available)
- **Records:** 20,907 employees
- **Scope:** Five largest departments by headcount

| Department | Employee count |
|---|---|
| Police | 10,463 |
| Fire | 4,786 |
| Streets and Sanitation | 2,454 |
| Water Management | 1,764 |
| Aviation | 1,440 |

- **Target variable:** `over5000` — binary flag (1 if total overtime pay ≥ $5,000)
- **Class balance:** ~54% earned $5,000+ (11,384 of 20,907)
- **Predictors used:** `department.name`, `nummos` (number of months receiving overtime)

---

## Approach

1. **Sampling** — drew a reproducible random sample of 4,500 employees (`set.seed(14902438)`) to keep the analysis computationally light and prevent overfitting to the full population.
2. **Modeling** — fit a logistic regression: `glm(over5000 ~ department.name + nummos, family = binomial)`.
3. **Prediction grid** — used `expand.grid()` to generate predicted probabilities for every possible combination of department × months-worked (75 profiles).
4. **Scenario analysis** — identified the highest- and lowest-risk employee profiles for business interpretation.

---

## Results

### 1. Model fit

| Metric | Value |
|---|---|
| Null Deviance | 6,211.7 |
| Residual Deviance | 2,983.0 |
| **Deviance Reduction** | **52.0%** |
| AIC | 2,995.0 |
| Sample size | 4,500 |

The 52% drop in deviance from null to residual model shows that department + months-worked together carry substantial predictive signal.

### 2. Coefficient estimates

| Predictor | Coefficient | Std. Error | z-value | p-value | Direction |
|---|---|---|---|---|---|
| (Intercept) | −4.419 | 0.210 | −21.09 | <0.001 | — |
| Fire | **+1.312** | 0.196 | 6.70 | <0.001 | ↑ strong |
| Police | +0.220 | 0.185 | 1.19 | 0.235 | ↑ not significant |
| Streets and Sanitation | **−1.489** | 0.216 | −6.89 | <0.001 | ↓ strong |
| Water Management | −0.505 | 0.238 | −2.13 | 0.034 | ↓ moderate |
| `nummos` | **+0.706** | 0.020 | 35.32 | <0.001 | ↑ strongest |

### 3. Department effect interpretation

- **Fire department**: strongest positive driver. Employees here are far more likely to cross the $5,000 threshold than the Aviation reference group.
- **Streets and Sanitation**: strongest negative driver. Employees are far less likely to cross the threshold, holding months constant.
- **Water Management**: moderate negative effect (p = 0.034).
- **Police**: small positive effect, but not statistically significant (p = 0.235).

### 4. Sustained activity is the single biggest lever

Each additional month of overtime activity increased the log-odds by **+0.706** (p < 0.001). Exponentiating, each extra month roughly **doubles the odds** of being a $5K+ earner — meaning an employee on overtime 12 months/year is in a completely different tier than one on overtime for 2 months.

### 5. Highest- and lowest-risk profiles

From the 75-profile prediction grid:

| Profile | Predicted probability of $5,000+ overtime |
|---|---|
| **Fire department, 12 months of overtime** | **99.5%** |
| Fire department, 11 months | 99.1% |
| Fire department, 8 months | ~95% |
| Aviation, 2 months | 4.7% |
| Water Management, 2 months | 2.9% |
| **Streets and Sanitation, 0 months** | **0.3%** |

### 6. Business implication

A simple, data-driven rule for labor-cost monitoring emerges:

> **Flag any Fire department employee receiving overtime for 8+ consecutive months** — the model predicts >95% probability that they will cross the $5,000 threshold.

This gives budget analysts an **early-warning signal mid-year** instead of waiting for year-end totals.

---

## How to Run

### Prerequisites
- R 4.0 or later
- R packages: `rio`, `moments`

### Steps

```bash
# 1. Clone
git clone --insert_url_here
cd chicago-overtime-logistic-regression

# 2. Install R dependencies
Rscript -e 'install.packages(c("rio", "moments"))'

# 3. Run
Rscript scripts/overtime_logistic_regression.R
```

The dataset is included in `data/`, so no manual download is required.

---

## Skills Demonstrated

- Logistic regression modeling (`glm` with binomial family) and interpretation of coefficients, deviance, and AIC
- Reproducible sampling with `set.seed()` for training-set construction
- Scenario analysis via full factorial prediction grids (`expand.grid()`)
- Translating statistical output into business recommendations
- R programming for end-to-end data science workflows

---
