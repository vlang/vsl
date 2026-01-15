# Classification

Learn classification algorithms in VSL.

## What You'll Learn

- K-Nearest Neighbors
- Logistic Regression
- Support Vector Machines
- Decision Trees
- Random Forest
- Classification metrics
- Model evaluation

## K-Nearest Neighbors (KNN)

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([][]f64{}, []f64{})!  // Assume populated
mut model := ml.KNN.new(mut data, 'knn_model')!
model.train()
prediction := model.predict(k: 3, to_pred: [1.0, 2.0])!
```

## Logistic Regression

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([][]f64{}, []f64{})!  // Assume populated
mut model := ml.LogReg.new(mut data, 'logreg_model')
model.train(epochs: 1000, learning_rate: 0.01)
probability := model.predict([1.0, 2.0])
```

## Support Vector Machine (SVM)

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([][]f64{}, []f64{})!  // Assume populated
mut model := ml.SVM.new(mut data, 'svm_model')
model.set_kernel(.rbf, 1.0, 3)  // RBF kernel
model.set_C(10.0)
model.train(max_iter: 200, tolerance: 1e-3)
prediction := model.predict([1.0, 2.0])
```

## Decision Tree

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([][]f64{}, []f64{})!  // Assume populated
mut model := ml.DecisionTree.new(mut data, 'dt_model')
model.set_criterion(.gini)
model.set_max_depth(10)
model.train()
prediction := model.predict([1.0, 2.0])
```

## Random Forest

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([][]f64{}, []f64{})!  // Assume populated
mut model := ml.RandomForest.new(mut data, 'rf_model')
model.set_n_estimators(100)
model.train()
prediction := model.predict([1.0, 2.0])
probability := model.predict_proba([1.0, 2.0])
```

## Next Steps

- [Logistic Regression](05-logistic-regression.md) - Detailed logistic regression guide
- [SVM](06-svm.md) - Support Vector Machines
- [Decision Trees](07-decision-trees.md) - Decision tree classification
- [Random Forest](08-random-forest.md) - Ensemble learning
- [Examples](../../examples/) - Working examples

