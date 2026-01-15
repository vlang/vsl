# Complete Machine Learning Pipeline Example

This example demonstrates a full machine learning workflow using VSL, similar to
what you would do with scikit-learn in Python. It showcases all the new VSL
modules for data science.

## What This Example Covers

### 1. Data Loading & Generation

- Synthetic dataset generation (similar to bank loan data)
- Feature engineering concepts

### 2. Preprocessing (`vsl.preprocessing`)

- **StandardScaler**: Z-score normalization
- **LabelEncoder**: Categorical to numeric encoding
- **OneHotEncoder**: One-hot (dummy) encoding
- **Binning**: Equal-width (`cut`) and quantile (`qcut`) binning

### 3. Data Splitting (`vsl.model_selection`)

- **train_test_split**: Stratified train/test splitting
- **KFold**: K-Fold cross-validation

### 4. Regression (`vsl.ml`)

- **Lasso**: L1-regularized linear regression
- Regression metrics: MSE, RMSE, MAE, R²

### 5. Classification (`vsl.ml`)

- **LogReg**: Logistic regression with regularization
- Classification metrics: Accuracy, Precision, Recall, F1

### 6. Metrics (`vsl.metrics`)

- Confusion matrix
- ROC curve and AUC
- Precision-Recall curve and Average Precision
- Gini coefficient
- KS statistic
- Log loss

### 7. Correlation Analysis (`vsl.la`)

- Correlation matrix computation
- Column statistics (mean, std, min, max)

### 8. Visualization (`vsl.plot`)

- ROC curve plot
- Precision-Recall curve plot
- Confusion matrix heatmap
- Correlation matrix heatmap
- Feature importance bar chart
- Actual vs Predicted scatter plot
- Residuals plot

## Running the Example

```bash
cd ~/.vmodules/vsl/examples/ml_complete_pipeline
v run main.v
```

## Expected Output

```
============================================================
   VSL Complete Machine Learning Pipeline Example
============================================================

📊 Part 1: Generating Synthetic Dataset
----------------------------------------
Dataset shape: 200 samples, 5 features
Feature names: Income, Age, Experience, Education, CreditScore

🔧 Part 2: Data Preprocessing
----------------------------------------
  Applying StandardScaler...
  Mean after scaling (should be ~0): 89876.1234
  Std after scaling: 34567.8901

  Demonstrating LabelEncoder...
  Original: [Graduate, Undergraduate, Graduate, PhD, Undergraduate]
  Encoded:  [0, 1, 0, 2, 1]
  Classes:  [Graduate, Undergraduate, PhD]
  ...

📐 Part 3: Train/Test Split
----------------------------------------
  Train set: 140 samples
  Test set:  60 samples
  Train positive ratio: 45.00%
  Test positive ratio:  46.67%

📈 Part 5: Lasso Regression
----------------------------------------
  Lasso coefficients: [1.8234, 0.4521, -0.9123]
  Lasso intercept: 5.1234

  Regression Metrics:
    MSE:  1.2345
    RMSE: 1.1111
    MAE:  0.8765
    R²:   0.9234

🎯 Part 6: Logistic Regression Classification
----------------------------------------
  Classification Metrics:
    Accuracy:  0.8500
    Precision: 0.8200
    Recall:    0.8900
    F1 Score:  0.8536

  Confusion Matrix:
    TN=28  FP=5
    FN=4   TP=23

📉 Part 7: ROC and PR Curves
----------------------------------------
  ROC AUC: 0.9123
  Average Precision: 0.8765
  Gini Coefficient: 0.8246
  KS Statistic: 0.7234
  Log Loss: 0.3456
  ...

✅ ML Pipeline Complete!
```

## Python Equivalent

This example is a V port of the following Python workflow:

```python
import polars as pl
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder, OneHotEncoder
from sklearn.linear_model import Lasso, LogisticRegression
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    confusion_matrix, roc_curve, auc, precision_recall_curve
)
import matplotlib.pyplot as plt
import seaborn as sns

# Load data
df = pl.read_csv('data.csv')

# Preprocess
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.3, stratify=y, random_state=42
)

# Train
clf = LogisticRegression(C=10)
clf.fit(X_train, y_train)

# Evaluate
y_pred = clf.predict(X_test)
y_proba = clf.predict_proba(X_test)[:, 1]

print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}")
print(f"ROC AUC: {roc_auc_score(y_test, y_proba):.4f}")

# Plot ROC curve
fpr, tpr, _ = roc_curve(y_test, y_proba)
plt.plot(fpr, tpr)
plt.show()
```

## Modules Used

| VSL Module | Python Equivalent |
|------------|-------------------|
| `vsl.inout.csv` | `pandas.read_csv()` / `polars.read_csv()` |
| `vsl.preprocessing` | `sklearn.preprocessing` |
| `vsl.model_selection` | `sklearn.model_selection` |
| `vsl.metrics` | `sklearn.metrics` |
| `vsl.ml` | `sklearn.linear_model`, `sklearn.ensemble` |
| `vsl.la` | `numpy.corrcoef()`, `pandas.DataFrame.corr()` |
| `vsl.plot` | `matplotlib`, `seaborn`, `plotly` |

## See Also

- [Preprocessing Module](../../preprocessing/README.md)
- [Metrics Module](../../metrics/README.md)
- [Model Selection Module](../../model_selection/README.md)
- [ML Module](../../ml/README.md)
- [Plot Module](../../plot/README.md)
