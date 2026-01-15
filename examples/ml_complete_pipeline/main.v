module main

// Complete Machine Learning Pipeline Example
// This example demonstrates a full ML workflow similar to scikit-learn/Python
// using VSL's new preprocessing, metrics, model_selection, and plotting modules.
//
// Workflow:
// 1. Load and explore data
// 2. Preprocessing (scaling, encoding, binning)
// 3. Train/test split with stratification
// 4. Train models (Lasso regression, Logistic regression)
// 5. Evaluate with metrics (ROC, PR curves, confusion matrix)
// 6. Visualize results
import rand
import vsl.preprocessing
import vsl.model_selection
import vsl.metrics
import vsl.ml
import vsl.la
import vsl.plot

fn main() {
	println('='.repeat(60))
	println('   VSL Complete Machine Learning Pipeline Example')
	println('='.repeat(60))
	println('')

	// ============================================================
	// PART 1: Generate synthetic dataset (similar to bank loan data)
	// ============================================================
	println('📊 Part 1: Generating Synthetic Dataset')
	println('-'.repeat(40))

	// Generate synthetic data for a loan prediction problem
	// Features: Income, Age, Experience, Education level, Credit score
	// Target: Loan approved (1) or not (0)
	x_data, y_data := generate_loan_dataset()

	println('Dataset shape: ${x_data.len} samples, ${x_data[0].len} features')
	println('Feature names: Income, Age, Experience, Education, CreditScore')
	println('')

	// ============================================================
	// PART 2: Data Preprocessing
	// ============================================================
	println('🔧 Part 2: Data Preprocessing')
	println('-'.repeat(40))

	// 2.1 Standard Scaling (Z-score normalization)
	println('  Applying StandardScaler...')
	mut scaler := preprocessing.StandardScaler.new()
	x_scaled := scaler.fit_transform(x_data)!

	println('  Mean after scaling (should be ~0): ${scaler.mean_[0]:.4f}')
	println('  Std after scaling: ${scaler.std_[0]:.4f}')

	// 2.2 Demonstrate Label Encoding
	println('\n  Demonstrating LabelEncoder...')
	education_labels := ['Graduate', 'Undergraduate', 'Graduate', 'PhD', 'Undergraduate']
	mut label_encoder := preprocessing.LabelEncoder.new()
	encoded_labels := label_encoder.fit_transform(education_labels)!
	println('  Original: ${education_labels}')
	println('  Encoded:  ${encoded_labels}')
	println('  Classes:  ${label_encoder.classes_}')

	// 2.3 Demonstrate One-Hot Encoding
	println('\n  Demonstrating OneHotEncoder...')
	categories := [['Graduate'], ['PhD'], ['Undergraduate']]
	mut onehot_encoder := preprocessing.OneHotEncoder.new(false)
	onehot_encoded := onehot_encoder.fit_transform(categories)!
	println('  One-hot encoded shape: ${onehot_encoded.len} x ${onehot_encoded[0].len}')

	// 2.4 Demonstrate Binning
	println('\n  Demonstrating Binning...')
	ages := [25.0, 35.0, 45.0, 55.0, 65.0, 30.0, 40.0, 50.0]
	age_bins := preprocessing.cut(ages, 3, ['Young', 'Middle', 'Senior'])!
	println('  Ages: ${ages}')
	println('  Binned: ${age_bins}')

	// Quantile binning
	qbins := preprocessing.qcut(ages, 4, ['Q1', 'Q2', 'Q3', 'Q4'])!
	println('  Quantile binned: ${qbins}')

	println('')

	// ============================================================
	// PART 3: Train/Test Split
	// ============================================================
	println('📐 Part 3: Train/Test Split')
	println('-'.repeat(40))

	// Stratified train/test split
	split_result := model_selection.train_test_split(x_scaled, y_data, model_selection.TrainTestSplitConfig{
		test_size:   0.3
		stratify:    true
		shuffle:     true
		random_seed: 42
	})!

	println('  Train set: ${split_result.x_train.len} samples')
	println('  Test set:  ${split_result.x_test.len} samples')

	// Count class distribution
	mut train_positives := 0
	for y in split_result.y_train {
		if y == 1.0 {
			train_positives++
		}
	}
	mut test_positives := 0
	for y in split_result.y_test {
		if y == 1.0 {
			test_positives++
		}
	}
	train_ratio := f64(train_positives) / f64(split_result.y_train.len)
	test_ratio := f64(test_positives) / f64(split_result.y_test.len)
	println('  Train positive ratio: ${train_ratio * 100.0:.1f}%')
	println('  Test positive ratio:  ${test_ratio * 100.0:.1f}% (should be similar due to stratification)')
	println('')

	// ============================================================
	// PART 4: Cross-Validation Demo
	// ============================================================
	println('🔄 Part 4: Cross-Validation')
	println('-'.repeat(40))

	// K-Fold cross-validation
	kfold := model_selection.KFold.new(5, true, 42)
	folds := kfold.split(split_result.x_train.len)!
	println('  5-Fold CV splits created')
	for i, fold in folds {
		println('    Fold ${i + 1}: Train=${fold.train_indices.len}, Test=${fold.test_indices.len}')
	}
	println('')

	// ============================================================
	// PART 5: Train Regression Model (Lasso)
	// ============================================================
	println('📈 Part 5: Lasso Regression')
	println('-'.repeat(40))

	// For regression, use a continuous target
	// Create a regression target: weighted sum of features + noise
	x_reg, y_reg := generate_regression_dataset()

	mut scaler_reg := preprocessing.StandardScaler.new()
	x_reg_scaled := scaler_reg.fit_transform(x_reg)!

	reg_split := model_selection.train_test_split(x_reg_scaled, y_reg, model_selection.TrainTestSplitConfig{
		test_size:   0.3
		random_seed: 42
	})!

	// Create ML Data for Lasso
	mut lasso_data := ml.Data.from_raw_xy_sep[f64](reg_split.x_train, reg_split.y_train)!

	mut lasso_model := ml.Lasso.new(mut lasso_data, 'lasso_model', 0.01)
	lasso_model.max_iter = 2000
	lasso_model.train()

	println('  Lasso coefficients: ${format_floats(lasso_model.coef_)}')
	println('  Lasso intercept: ${lasso_model.intercept_:.4f}')

	// Predict on test set
	mut y_pred_reg := []f64{}
	for row in reg_split.x_test {
		y_pred_reg << lasso_model.predict(row)
	}

	// Regression metrics
	mse := metrics.mean_squared_error(reg_split.y_test, y_pred_reg)!
	rmse := metrics.root_mean_squared_error(reg_split.y_test, y_pred_reg)!
	mae := metrics.mean_absolute_error(reg_split.y_test, y_pred_reg)!
	r2 := metrics.r2_score(reg_split.y_test, y_pred_reg)!

	println('\n  Regression Metrics:')
	println('    MSE:  ${mse:.4f}')
	println('    RMSE: ${rmse:.4f}')
	println('    MAE:  ${mae:.4f}')
	println('    R²:   ${r2:.4f}')
	println('')

	// ============================================================
	// PART 6: Train Classification Model (Logistic Regression)
	// ============================================================
	println('🎯 Part 6: Logistic Regression Classification')
	println('-'.repeat(40))

	// Create ML Data for classification
	mut clf_data := ml.Data.from_raw_xy_sep[f64](split_result.x_train, split_result.y_train)!

	mut clf_model := ml.LogReg.new(mut clf_data, 'logreg_model')
	clf_model.params.set_lambda(0.1) // L2 regularization

	println('  Training logistic regression...')
	clf_model.train(ml.LogRegTrainConfig{
		epochs:        1000
		learning_rate: 0.1
	})

	// Get predictions and probabilities on test set
	mut y_pred_proba := []f64{}
	mut y_pred := []f64{}
	for row in split_result.x_test {
		prob := clf_model.predict(row)
		y_pred_proba << prob
		y_pred << if prob >= 0.5 { 1.0 } else { 0.0 }
	}

	// Classification metrics
	accuracy := metrics.accuracy_score(split_result.y_test, y_pred)!
	precision := metrics.precision_score(split_result.y_test, y_pred)!
	recall := metrics.recall_score(split_result.y_test, y_pred)!
	f1 := metrics.f1_score(split_result.y_test, y_pred)!

	println('\n  Classification Metrics:')
	println('    Accuracy:  ${accuracy:.4f}')
	println('    Precision: ${precision:.4f}')
	println('    Recall:    ${recall:.4f}')
	println('    F1 Score:  ${f1:.4f}')

	// Confusion matrix
	cm := metrics.confusion_matrix(split_result.y_test, y_pred)!
	println('\n  Confusion Matrix:')
	println('    TN=${cm[0][0]}  FP=${cm[0][1]}')
	println('    FN=${cm[1][0]}  TP=${cm[1][1]}')
	println('')

	// ============================================================
	// PART 7: ROC and PR Curves
	// ============================================================
	println('📉 Part 7: ROC and PR Curves')
	println('-'.repeat(40))

	// ROC curve
	roc := metrics.roc_curve(split_result.y_test, y_pred_proba)!
	auc_score := metrics.roc_auc_score(split_result.y_test, y_pred_proba)!
	println('  ROC AUC: ${auc_score:.4f}')

	// Precision-Recall curve
	pr := metrics.precision_recall_curve(split_result.y_test, y_pred_proba)!
	ap_score := metrics.average_precision_score(split_result.y_test, y_pred_proba)!
	println('  Average Precision: ${ap_score:.4f}')

	// Other metrics
	gini := metrics.gini_coefficient(split_result.y_test, y_pred_proba)!
	ks := metrics.ks_statistic(split_result.y_test, y_pred_proba)!
	log_loss_val := metrics.log_loss(split_result.y_test, y_pred_proba)!

	println('  Gini Coefficient: ${gini:.4f}')
	println('  KS Statistic: ${ks:.4f}')
	println('  Log Loss: ${log_loss_val:.4f}')
	println('')

	// ============================================================
	// PART 8: Correlation Matrix
	// ============================================================
	println('🔢 Part 8: Correlation Analysis')
	println('-'.repeat(40))

	// Create matrix from data
	mut data_matrix := la.Matrix.new[f64](x_data.len, x_data[0].len)
	for i in 0 .. x_data.len {
		for j in 0 .. x_data[0].len {
			data_matrix.set(i, j, x_data[i][j])
		}
	}

	// Compute correlation matrix
	corr_matrix := la.correlation_matrix(data_matrix)
	println('  Correlation Matrix (5x5):')
	for i in 0 .. corr_matrix.m {
		mut row := '    '
		for j in 0 .. corr_matrix.n {
			row += '${corr_matrix.get(i, j):7.3f} '
		}
		println(row)
	}
	println('')

	// ============================================================
	// PART 9: Generate Visualizations
	// ============================================================
	println('📊 Part 9: Generating Visualizations')
	println('-'.repeat(40))

	// 9.1 ROC Curve
	println('  Generating ROC curve...')
	mut roc_plot := plot.plot_roc_curve(roc.fpr, roc.tpr, auc_score)
	roc_plot.show() or { println('    (Could not display ROC curve)') }

	// 9.2 Precision-Recall Curve
	println('  Generating Precision-Recall curve...')
	mut pr_plot := plot.plot_precision_recall_curve(pr.precision, pr.recall, ap_score)
	pr_plot.show() or { println('    (Could not display PR curve)') }

	// 9.3 Confusion Matrix
	println('  Generating Confusion Matrix...')
	mut cm_plot := plot.plot_confusion_matrix(cm, ['Rejected', 'Approved'])
	cm_plot.show() or { println('    (Could not display confusion matrix)') }

	// 9.4 Correlation Matrix
	println('  Generating Correlation Matrix...')
	feature_names := ['Income', 'Age', 'Experience', 'Education', 'CreditScore']
	mut corr_plot := plot.plot_correlation_matrix(corr_matrix, feature_names)
	corr_plot.show() or { println('    (Could not display correlation matrix)') }

	// 9.5 Feature Importance
	println('  Generating Feature Importance...')
	theta := clf_model.params.access_thetas()
	mut importances := []f64{}
	for t in theta {
		importances << if t < 0 { -t } else { t }
	}
	mut importance_plot := plot.plot_feature_importance(importances, feature_names, 5)
	importance_plot.show() or { println('    (Could not display feature importance)') }

	// 9.6 Actual vs Predicted (Regression)
	println('  Generating Actual vs Predicted plot...')
	mut avp_plot := plot.plot_actual_vs_predicted(reg_split.y_test, y_pred_reg)
	avp_plot.show() or { println('    (Could not display actual vs predicted)') }

	// 9.7 Residuals Plot
	println('  Generating Residuals plot...')
	mut residuals := []f64{}
	for i in 0 .. reg_split.y_test.len {
		residuals << reg_split.y_test[i] - y_pred_reg[i]
	}
	mut residual_plot := plot.plot_residuals(y_pred_reg, residuals)
	residual_plot.show() or { println('    (Could not display residuals)') }

	println('')
	println('='.repeat(60))
	println('   ✅ ML Pipeline Complete!')
	println('='.repeat(60))
	println('')
	println('Summary:')
	println('  - Preprocessed ${x_data.len} samples with ${x_data[0].len} features')
	println('  - Trained Lasso regression (R² = ${r2:.4f})')
	println('  - Trained Logistic regression (AUC = ${auc_score:.4f})')
	println('  - Generated 7 visualization plots')
	println('')
}

// generate_loan_dataset creates a synthetic loan approval dataset
fn generate_loan_dataset() ([][]f64, []f64) {
	mut x := [][]f64{}
	mut y := []f64{}

	// Seed for reproducibility
	rand.seed([u32(42), u32(42)])

	for _ in 0 .. 200 {
		// Generate features
		income := rand.f64_in_range(30000.0, 150000.0) or { 90000.0 }
		age := rand.f64_in_range(22.0, 65.0) or { 40.0 }
		experience := rand.f64_in_range(0.0, 40.0) or { 15.0 }
		education := rand.f64_in_range(1.0, 4.0) or { 2.0 } // 1=HS, 2=Bachelor, 3=Master, 4=PhD
		credit_score := rand.f64_in_range(300.0, 850.0) or { 650.0 }

		x << [income, age, experience, education, credit_score]

		// Generate target based on features (with some noise)
		score := 0.4 * (income / 150000.0) + 0.1 * (age / 65.0) + 0.1 * (experience / 40.0) +
			0.15 * (education / 4.0) + 0.25 * ((credit_score - 300.0) / 550.0)

		noise := rand.f64_in_range(-0.1, 0.1) or { 0.0 }
		y << if score + noise > 0.5 { 1.0 } else { 0.0 }
	}

	return x, y
}

// generate_regression_dataset creates a synthetic regression dataset
fn generate_regression_dataset() ([][]f64, []f64) {
	mut x := [][]f64{}
	mut y := []f64{}

	// Seed for reproducibility
	rand.seed([u32(123), u32(123)])

	for _ in 0 .. 150 {
		x1 := rand.f64_in_range(0.0, 10.0) or { 5.0 }
		x2 := rand.f64_in_range(0.0, 10.0) or { 5.0 }
		x3 := rand.f64_in_range(0.0, 10.0) or { 5.0 }

		x << [x1, x2, x3]

		// y = 2*x1 + 0.5*x2 - 1*x3 + noise
		noise := rand.f64_in_range(-1.0, 1.0) or { 0.0 }
		y << 2.0 * x1 + 0.5 * x2 - 1.0 * x3 + 5.0 + noise
	}

	return x, y
}

// format_floats formats a slice of floats nicely
fn format_floats(arr []f64) string {
	mut parts := []string{}
	for v in arr {
		parts << '${v:.4f}'
	}
	return '[' + parts.join(', ') + ']'
}
