# Statistics

This chapter describes the statistical functions in the library. The
basic statistical functions include routines to compute the mean,
variance and standard deviation. More advanced functions allow you to
calculate absolute deviations, skewness, and kurtosis as well as the
median and arbitrary percentiles. The algorithms use recurrence
relations to compute average quantities in a stable way, without large
intermediate values that might overflow.

The functions are available in versions for datasets in the standard
double precision floating-point. All the functions operate on V
arrays.

The module `vsl.stats` contains functions for statistics and related declarations.

# References and Further Reading

The standard reference for almost any topic in statistics is the
multi-volume _Advanced Theory of Statistics_ by Kendall and Stuart.

- Maurice Kendall, Alan Stuart, and J. Keith Ord.
  _The Advanced Theory of Statistics_ (multiple volumes)
  reprinted as _Kendall's Advanced Theory of Statistics_.
  Wiley, ISBN 047023380X.

Many statistical concepts can be more easily understood by a Bayesian
approach. The following book by Gelman, Carlin, Stern and Rubin gives a
comprehensive coverage of the subject.

- Andrew Gelman, John B. Carlin, Hal S. Stern, Donald B. Rubin.
  _Bayesian Data Analysis_.
  Chapman & Hall, ISBN 0412039915.
