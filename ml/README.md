# VSL Machine Learning (vsl.ml)

VSL aims to provide a robust set of tools for scientific computing with an emphasis
on performance and ease of use. In the `vsl.ml` module, some machine learning
models are designed as observers of data, meaning they re-train automatically when
data changes, while others do not require this functionality.

## Key Features

- **Observers of Data**: Some machine learning models in VSL act as observers,
  re-training automatically when data changes.
- **High Performance**: Leverages V’s performance optimizations and can integrate
  with C and Fortran libraries like Open BLAS and LAPACK.
- **Versatile Algorithms**: Supports a variety of machine learning algorithms and
  models.

## Usage

### Loading Data

The `Data` struct in `vsl.ml` is designed to hold data in matrix format for machine
learning tasks. Here's a brief overview of how to use it:

#### Creating a Data Object

You can create a `Data` object using the following methods:

- `Data.new`: Creates a new `Data` object with specified dimensions.
- `Data.from_raw_x`: Creates a `Data` object from raw x values (without y values).
- `Data.from_raw_xy`: Creates a `Data` object from raw x and y values combined in a single matrix.
- `Data.from_raw_xy_sep`: Creates a `Data` object from separate x and y raw values.

### Data Methods

The `Data` struct has several key methods to manage and manipulate data:

- `set(x, y)`: Sets the x matrix and y vector and notifies observers.
- `set_y(y)`: Sets the y vector and notifies observers.
- `set_x(x)`: Sets the x matrix and notifies observers.
- `split(ratio)`: Splits the data into two parts based on the given ratio.
- `clone()`: Returns a deep copy of the Data object without observers.
- `clone_with_same_x()`: Returns a deep copy of the Data object but shares the same x reference.
- `add_observer(obs)`: Adds an observer to the data object.
- `notify_update()`: Notifies observers of data changes.

### Stat Observer

The `Stat` struct is an observer of `Data`, providing statistical analysis of the
data it observes. It automatically updates its statistics when the underlying data
changes.

## Observer Models

The following machine learning models in VSL are compatible with the `Observer`
pattern. This means they can observe data changes and automatically update
themselves.

### K-Means Clustering

K-Means Clustering is used for unsupervised learning to group data points into
clusters. As an observer model, it re-trains automatically when the data changes,
which is useful for dynamic datasets that require continuous updates.

### K-Nearest Neighbors (KNN)

K-Nearest Neighbors (KNN) is used for classification tasks where the target
variable is categorical. As an observer model, it re-trains automatically when the
data changes, which is beneficial for datasets that are frequently updated.

### Logistic Regression

Logistic Regression is used for binary classification tasks. As an observer model,
it automatically updates when data changes, recalculating internal statistics and
preparing for retraining.

### Support Vector Machine (SVM)

Support Vector Machine (SVM) is used for binary classification with support for
non-linear decision boundaries through kernel functions. As an observer model, it
marks itself for retraining when data changes.

### Decision Tree

Decision Tree can handle both classification and regression tasks. As an observer
model, it marks itself for retraining when data changes, allowing the tree to be
rebuilt with new data.

### Random Forest

Random Forest is an ensemble method combining multiple decision trees. As an
observer model, it marks itself for retraining when data changes, allowing the
entire forest to be rebuilt.

## Non-Observer Models

The following machine learning models in VSL do not require the observer pattern
and are trained once on a dataset without continuous updates.

### Linear Regression

Linear Regression is used for predicting a continuous target variable based on one
or more predictor variables. It is typically trained once on a dataset and used to
make predictions without requiring continuous updates. Hence, it is not implemented
as an observer model.
