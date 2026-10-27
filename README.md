# Social Media Ad Optimization: Engagement, CTR and Conversions

IS 507 final project (University of Illinois). We analyse 500 Facebook and Instagram ad
impressions to understand what drives clicks and conversions across audiences, platforms,
devices and countries.

**Team:** Sakshi Katolkar, Shithil Shetty, Sneha Vyas, Srinath Venkatesh, Kanishka Gupta

**Data:** [Social Media Ad Dataset (Kaggle)](https://www.kaggle.com/datasets/ziya07/social-media-ad-dataset/data):
500 rows × 16 columns (user demographics, ad attributes, impressions, clicks, time spent,
day of week, device, conversion).

## Research questions

1. Which audience segments (age, interests, location) get high impressions but low conversions?
2. Which combinations of platform, ad type, day of week and device predict high or low CTR?
3. What is the best day-of-week × device combination to maximise conversions in each country?
4. Which ad, demographic and context variables are the strongest predictors of conversion?
5. Does a supervised engagement score predict conversion better than CTR?

## Repository layout

```
├── data/social_media_ad_optimization_raw.csv   raw dataset
├── notebooks/
│   ├── python/
│   │   ├── 01_eda_logreg.ipynb        EDA, CTR/CVR, logistic regression on day/device/country (RQ3)
│   │   ├── 02_random_forest.ipynb     random forest for conversion + best combos per country (RQ3)
│   │   └── 03_gbm_best_combo.ipynb    logistic regression drivers (RQ4) + gradient boosting best combos (RQ3)
│   └── r/
│       ├── Q1_R_equivalent.ipynb      R/tidymodels port of the logistic regression (RQ4)
│       ├── Q1_R_final.ipynb           R/XGBoost best day × device per country (RQ3)
│       └── Final_R_IS_507.ipynb       combined team notebook: RQ1–RQ5
├── models/                            fitted models written by the notebooks
├── reports/                           CSV outputs (top-3 day × device per country)
├── report/Project_Report_IS507.pdf    submitted project report
├── requirements.txt                   Python dependencies
└── install_packages.R                 R dependencies + IRkernel setup
```

## How to run

Python (3.9+):

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
jupyter notebook
```

R (4.5): run `Rscript install_packages.R` once, then open the notebooks in `notebooks/r/`
with the **R** (IRkernel) kernel.

All paths are relative to the notebook's folder, so open and run notebooks from
inside `notebooks/python/` or `notebooks/r/`. Every notebook runs top to bottom without errors,
and the saved outputs come from a clean run.

## Key results (current notebooks)

| Model | Notebook | Test ROC-AUC |
|---|---|---|
| Logistic regression, day + device + country only | `01_eda_logreg` | 0.45 |
| Random forest (no `engagement_score`) | `02_random_forest` | 0.60 (5-fold CV 0.60) |
| Gradient boosting (sklearn HistGradientBoosting) | `03_gbm_best_combo` | 0.56 |
| Logistic regression, all features (glmnet) | `Q1_R_equivalent` | 0.64 |
| XGBoost | `Q1_R_final` / `Final_R_IS_507` | 0.56 |

With only 500 rows, the conversion models are only modestly better than chance, so treat the
per-country "best combo" rankings as exploratory.

## Changes since the submitted report

The notebooks were cleaned up after the PDF report was submitted. Some fixes change the numbers,
so parts of the report no longer match the notebooks:

- **R metrics used the wrong positive class.** yardstick treats the first factor level (`0`) as
  the event, so ROC-AUC, precision, recall and F1 were computed for *non*-conversion. All calls now
  use `event_level = "second"` (for example, the glmnet AUC went from 0.36 to 0.64).
- **RQ5 is now evaluated on held-out data.** The supervised engagement score was fitted on the
  training rows and was then compared with CTR on all rows, including those training rows. On the
  20% test split the AUCs are 0.64 (engagement score) and 0.61 (CTR). The report says 0.68 vs 0.64.
  The engagement score is also a fitted conversion propensity, so this is not a like-for-like
  comparison with CTR.
- **The RQ3 XGBoost model is trained on the full training set.** Before, 15% of the training data
  was set aside for "early stopping" that was never configured. The best combos per country
  changed (see `reports/best_day_device_r.csv`).
- **RQ3 heatmaps and per-device averages use every day × device combination**, not just each
  country's top 3. The top-3 chart no longer stacks bars, which summed probabilities above 1.
- **The RQ4 feature chart now builds**: it previously failed with `top_features not found`. It
  shows standardized logistic-regression coefficients ranked by absolute size.
- **`02_random_forest` no longer uses `engagement_score`**, which correlates 0.81 with
  conversion and leaked the target.
- **`01_eda_logreg` picks its threshold by cross-validation on the training set.** It used to
  tune on the test set and then hard-code 0.466.
- **`03_gbm_best_combo` is labelled as the gradient boosting model it actually used.** It was
  called XGBoost, but XGBoost was not installed and the code fell back to sklearn's
  HistGradientBoosting.
- **Smaller fixes:**
  - The RQ2 record count was summing user IDs; it now counts rows.
  - The R train-set positive rate printed `NA`.
  - Weekdays are now in calendar order.
  - Removed hard-coded absolute paths, in-notebook package installs, and duplicate and empty cells.
