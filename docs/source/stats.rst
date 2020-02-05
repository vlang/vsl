.. index::
   single: statistics
   single: mean
   single: standard deviation
   single: variance
   single: estimated standard deviation
   single: estimated variance
   single: t-test
   single: range
   single: min
   single: max

**********
Statistics
**********

This chapter describes the statistical functions in the library.  The
basic statistical functions include routines to compute the mean,
variance and standard deviation.  More advanced functions allow you to
calculate absolute deviations, skewness, and kurtosis as well as the
median and arbitrary percentiles.  The algorithms use recurrence
relations to compute average quantities in a stable way, without large
intermediate values that might overflow.

The functions are available in versions for datasets in the standard
double precision floating-point. All the functions operate on V
arrays.

The module :file:`vsl.stats` contains functions for the root
finding methods and related declarations.

Mean, Standard Deviation and Variance
=====================================

.. function:: fn mean (data []f64) f64

   This function returns the arithmetic mean of :data:`data`, a dataset of
   length :data:`n`.  The arithmetic mean, or
   *sample mean*, is denoted by :math:`\Hat\mu` and defined as,

   .. math:: \Hat\mu = {1 \over N} \sum x_i

   where :math:`x_i` are the elements of the dataset :data:`data`.  For
   samples drawn from a gaussian distribution the variance of
   :math:`\Hat\mu` is :math:`\sigma^2 / N`.

.. function:: fn geometric_mean(data []f64) f64

   This function returns the geometric mean of :data:`data`, a dataset of
   length :data:`n`. 

.. function:: fn harmonic_mean(data []f64) f64

   This function returns the harmonic mean of :data:`data`, a dataset of
   length :data:`n`. 

.. function:: fn sample_variance (data []f64) f64

   This function returns the estimated, or *sample*, variance of
   :data:`data`, a dataset of length :data:`n`.  The
   estimated variance is denoted by :math:`\Hat\sigma^2` and is defined by,

   .. only:: not texinfo

      .. math:: {\Hat\sigma}^2 = {1 \over (N-1)} \sum (x_i - {\Hat\mu})^2

   .. only:: texinfo

      ::

         \Hat\sigma^2 = (1/(N-1)) \sum (x_i - \Hat\mu)^2

   where :math:`x_i` are the elements of the dataset :data:`data`.  Note that
   the normalization factor of :math:`1/(N-1)` results from the derivation
   of :math:`\Hat\sigma^2` as an unbiased estimator of the population
   variance :math:`\sigma^2`.  For samples drawn from a Gaussian distribution
   the variance of :math:`\Hat\sigma^2` itself is :math:`2 \sigma^4 / N`.

   This function computes the mean via a call to :func:`mean`.  If
   you have already computed the mean then you can pass it directly to
   :func:`variance_m`.

.. function:: fn sample_variance_mean (data []f64, mean f64) f64

   This function returns the sample variance of :data:`data` relative to the
   given value of :data:`mean`.  The function is computed with :math:`\Hat\mu`
   replaced by the value of :data:`mean` that you supply,

   .. only:: not texinfo

      .. math:: {\Hat\sigma}^2 = {1 \over (N-1)} \sum (x_i - mean)^2

   .. only:: texinfo

      ::

         \Hat\sigma^2 = (1/(N-1)) \sum (x_i - mean)^2

.. function:: fn population_variance (data []f64) f64

   This function returns the variance of
   :data:`data`, a dataset of length :data:`n`.  The
   estimated variance is denoted by :math:`\Hat\sigma^2` and is defined by,

   .. only:: not texinfo

      .. math:: {\Hat\sigma}^2 = {1 \over (N-1)} \sum (x_i - {\Hat\mu})^2

   .. only:: texinfo

      ::

         \Hat\sigma^2 = (1/(N-1)) \sum (x_i - \Hat\mu)^2

   where :math:`x_i` are the elements of the dataset :data:`data`.  Note that
   the normalization factor of :math:`1/(N-1)` results from the derivation
   of :math:`\Hat\sigma^2` as an unbiased estimator of the population
   variance :math:`\sigma^2`.  For samples drawn from a Gaussian distribution
   the variance of :math:`\Hat\sigma^2` itself is :math:`2 \sigma^4 / N`.

   This function computes the mean via a call to :func:`mean`.  If
   you have already computed the mean then you can pass it directly to
   :func:`variance_m`.

.. function:: fn population_variance_mean (data []f64, mean f64) f64

   This function returns the population variance of :data:`data` relative to the
   given value of :data:`mean`.  The function is computed with :math:`\Hat\mu`
   replaced by the value of :data:`mean` that you supply,

   .. only:: not texinfo

      .. math:: {\Hat\sigma}^2 = {1 \over (N-1)} \sum (x_i - mean)^2

   .. only:: texinfo

      ::

         \Hat\sigma^2 = (1/(N-1)) \sum (x_i - mean)^2

.. function:: fn sample_stddev (data []f64) f64
              fn sample_stddev_mean (data []f64, mean f64) f64
              fn population_stddev (data []f64) f64
              fn population_stddev_mean (data []f64, mean f64) f64

   The standard deviation is defined as the square root of the variance.
   These functions return the square root of the corresponding variance
   functions above.

.. function:: fn tss (data []f64) f64
              fn tss_mean (data []f64, mean f64) f64

   These functions return the total sum of squares (TSS) of :data:`data` about
   the mean.  For :func:`tss_m` the user-supplied value of
   :data:`mean` is used, and for :func:`tss` it is computed using
   :func:`mean`.

   .. only:: not texinfo

      .. math:: {\rm TSS} = \sum (x_i - mean)^2

   .. only:: texinfo

      ::

         TSS =  \sum (x_i - mean)^2

Absolute deviation
==================

.. function:: fn absdev (data []f64) f64

   This function computes the absolute deviation from the mean of
   :data:`data`, a dataset of length :data:`n`.  The
   absolute deviation from the mean is defined as,

   .. only:: not texinfo

      .. math:: absdev  = {1 \over N} \sum |x_i - {\Hat\mu}|

   .. only:: texinfo

      ::

         absdev  = (1/N) \sum |x_i - \Hat\mu|

   where :math:`x_i` are the elements of the dataset :data:`data`.  The
   absolute deviation from the mean provides a more robust measure of the
   width of a distribution than the variance.  This function computes the
   mean of :data:`data` via a call to :func:`mean`.

.. function:: fn absdev_mean (data []f64, mean f64) f64

   This function computes the absolute deviation of the dataset :data:`data`
   relative to the given value of :data:`mean`,

   .. only:: not texinfo

      .. math:: absdev  = {1 \over N} \sum |x_i - mean|

   .. only:: texinfo

      ::

         absdev  = (1/N) \sum |x_i - mean|

   This function is useful if you have already computed the mean of
   :data:`data` (and want to avoid recomputing it), or wish to calculate the
   absolute deviation relative to another value (such as zero, or the
   median).

.. index:: skewness, kurtosis

Higher moments (skewness and kurtosis)
======================================

.. function:: fn skew (data []f64) f64

   This function computes the skewness of :data:`data`, a dataset of length
   :data:`n`.  The skewness is defined as,

   .. only:: not texinfo

      .. math::

         skew = {1 \over N} \sum
          {\left( x_i - {\Hat\mu} \over {\Hat\sigma} \right)}^3

   .. only:: texinfo

      ::

         skew = (1/N) \sum ((x_i - \Hat\mu)/\Hat\sigma)^3

   where :math:`x_i` are the elements of the dataset :data:`data`.  The skewness
   measures the asymmetry of the tails of a distribution.

   The function computes the mean and estimated standard deviation of
   :data:`data` via calls to :func:`mean` and :func:`sd`.

.. function:: fn skew_mean_stddev (data[] f64, mean f64, sd f64) f64

   This function computes the skewness of the dataset :data:`data` using the
   given values of the mean :data:`mean` and standard deviation :data:`sd`,

   .. only:: not texinfo

      .. math:: skew = {1 \over N} \sum {\left( x_i - mean \over sd \right)}^3

   .. only:: texinfo

      ::

         skew = (1/N) \sum ((x_i - mean)/sd)^3

   These functions are useful if you have already computed the mean and
   standard deviation of :data:`data` and want to avoid recomputing them.

.. function:: fn kurtosis (data []f64) f64

   This function computes the kurtosis of :data:`data`, a dataset of length
   :data:`n`.  The kurtosis is defined as,

   .. only:: not texinfo

      .. math::

         kurtosis = \left( {1 \over N} \sum
          {\left(x_i - {\Hat\mu} \over {\Hat\sigma} \right)}^4
          \right)
          - 3

   .. only:: texinfo

      ::

         kurtosis = ((1/N) \sum ((x_i - \Hat\mu)/\Hat\sigma)^4)  - 3

   The kurtosis measures how sharply peaked a distribution is, relative to
   its width.  The kurtosis is normalized to zero for a Gaussian
   distribution.

.. function:: fn kurtosis_mean_stddev (data[] f64, mean f64, sd f64) f64

   This function computes the kurtosis of the dataset :data:`data` using the
   given values of the mean :data:`mean` and standard deviation :data:`sd`,

   .. only:: not texinfo

      .. math::

         kurtosis = {1 \over N}
           \left( \sum {\left(x_i - mean \over sd \right)}^4 \right)
           - 3

   .. only:: texinfo

      ::

         kurtosis = ((1/N) \sum ((x_i - mean)/sd)^4) - 3

   This function is useful if you have already computed the mean and
   standard deviation of :data:`data` and want to avoid recomputing them.

Autocorrelation
===============

.. function:: fn lag1_autocorrelation (const double data[], const size_t stride, const size_t n) f64

   This function computes the lag-1 autocorrelation of the dataset :data:`data`.

   .. only:: not texinfo

      .. math::

         a_1 = {\sum_{i = 2}^{n} (x_{i} - \Hat\mu) (x_{i-1} - \Hat\mu)
         \over
         \sum_{i = 1}^{n} (x_{i} - \Hat\mu) (x_{i} - \Hat\mu)}

   .. only:: texinfo

      ::

         a_1 = {\sum_{i = 2}^{n} (x_{i} - \Hat\mu) (x_{i-1} - \Hat\mu)
                \over
                \sum_{i = 1}^{n} (x_{i} - \Hat\mu) (x_{i} - \Hat\mu)}

.. function:: fn lag1_autocorrelation_mean (const double data[], const size_t stride, const size_t n, const double mean) f64

   This function computes the lag-1 autocorrelation of the dataset
   :data:`data` using the given value of the mean :data:`mean`.

.. index::
   single: covariance, of two datasets

Covariance
==========

.. function:: fn covariance (const double data1[], const size_t stride1, const double data2[], const size_t stride2, const size_t n) f64

   This function computes the covariance of the datasets :data:`data1` and
   :data:`data2` which must both be of the same length :data:`n`.

   .. only:: not texinfo

      .. math:: covar = {1 \over (n - 1)} \sum_{i = 1}^{n} (x_{i} - \Hat x) (y_{i} - \Hat y)

   .. only:: texinfo

      ::

         covar = (1/(n - 1)) \sum_{i = 1}^{n} (x_i - \Hat x) (y_i - \Hat y)

.. function:: fn covariance_mean (const double data1[], const size_t stride1, const double data2[], const size_t stride2, const size_t n, const double mean1, const double mean2) f64

   This function computes the covariance of the datasets :data:`data1` and
   :data:`data2` using the given values of the means, :data:`mean1` and
   :data:`mean2`.  This is useful if you have already computed the means of
   :data:`data1` and :data:`data2` and want to avoid recomputing them.

.. index::
   single: correlation, of two datasets

Maximum and Minimum values
==========================

The following functions find the maximum and minimum values of a
dataset (or their indices).  If the data contains :code:`NaN`-s then a
:code:`NaN` will be returned, since the maximum or minimum value is
undefined.  For functions which return an index, the location of the
first :code:`NaN` in the array is returned.

.. function:: fn max (data []f64) f64

   This function returns the maximum value in :data:`data`, a dataset of
   length :data:`n`.  The maximum value is defined
   as the value of the element :math:`x_i` which satisfies :math:`x_i \ge x_j`
   for all :math:`j`.

   If you want instead to find the element with the largest absolute
   magnitude you will need to apply :func:`fabs` or :func:`abs` to your data
   before calling this function.

.. function:: fn min (data []f64) f64

   This function returns the minimum value in :data:`data`, a dataset of
   length :data:`n`.  The minimum value is defined
   as the value of the element :math:`x_i` which satisfies :math:`x_i \le x_j`
   for all :math:`j`.

   If you want instead to find the element with the smallest absolute
   magnitude you will need to apply :func:`fabs` or :func:`abs` to your data
   before calling this function.

.. function:: fn minmax (data []f64) (f64, f64)

   This function finds both the minimum and maximum values :data:`min`,
   :data:`max` in :data:`data` in a single pass.

.. function:: size_t max_index (data []f64)

   This function returns the index of the maximum value in :data:`data`, a
   dataset of length :data:`n`.  The maximum value is
   defined as the value of the element :math:`x_i` which satisfies
   :math:`x_i \ge x_j`
   for all :math:`j`.  When there are several equal maximum
   elements then the first one is chosen.

.. function:: size_t min_index (data []f64)

   This function returns the index of the minimum value in :data:`data`, a
   dataset of length :data:`n`.  The minimum value
   is defined as the value of the element :math:`x_i` which satisfies
   :math:`x_i \ge x_j`
   for all :math:`j`.  When there are several equal
   minimum elements then the first one is chosen.

.. function:: minmax_index (data []f64) (int, int)

   This function returns the indexes :data:`min_index`, :data:`max_index` of
   the minimum and maximum values in :data:`data` in a single pass.

Median and Percentiles
======================

The median and percentile functions described in this section operate on
sorted data.  For convenience we use *quantiles*, measured on a scale
of 0 to 1, instead of percentiles (which use a scale of 0 to 100).

.. function:: fn median_from_sorted_data (sorted_data []f64) f64

   This function returns the median value of :data:`sorted_data`, a dataset
   of length :data:`n`.  The elements of the array
   must be in ascending numerical order.  There are no checks to see
   whether the data are sorted, so the function :func:`cml_sort` should
   always be used first.

   When the dataset has an odd number of elements the median is the value
   of element :math:`(n-1)/2`.  When the dataset has an even number of
   elements the median is the mean of the two nearest middle values,
   elements :math:`(n-1)/2` and :math:`n/2`.  Since the algorithm for
   computing the median involves interpolation this function always returns
   a floating-point number, even for integer data types.

.. function:: fn quantile_from_sorted_data (sorted_data []f64, f) f64

   This function returns a quantile value of :data:`sorted_data`, a
   double-precision array of length :data:`n`.  The
   elements of the array must be in ascending numerical order.  The
   quantile is determined by the :data:`f`, a fraction between 0 and 1.  For
   example, to compute the value of the 75th percentile :data:`f` should have
   the value 0.75.

   There are no checks to see whether the data are sorted, so the function
   :func:`cml_sort` should always be used first.

   The quantile is found by interpolation, using the formula

   .. only:: not texinfo

      .. math:: \hbox{quantile} = (1 - \delta) x_i + \delta x_{i+1}

   .. only:: texinfo

      ::

         quantile = (1 - \delta) x_i + \delta x_{i+1}

   where :math:`i` is :code:`floor((n - 1)f)` and :math:`\delta` is
   :math:`(n-1)f - i`.

   Thus the minimum value of the array (:code:`data[0*stride]`) is given by
   :data:`f` equal to zero, the maximum value (:code:`data[(n-1)*stride]`) is
   given by :data:`f` equal to one and the median value is given by :data:`f`
   equal to 0.5.  Since the algorithm for computing quantiles involves
   interpolation this function always returns a floating-point number, even
   for integer data types.

References and Further Reading
==============================

The standard reference for almost any topic in statistics is the
multi-volume *Advanced Theory of Statistics* by Kendall and Stuart.

* Maurice Kendall, Alan Stuart, and J. Keith Ord.
  *The Advanced Theory of Statistics* (multiple volumes)
  reprinted as *Kendall's Advanced Theory of Statistics*.
  Wiley, ISBN 047023380X.

Many statistical concepts can be more easily understood by a Bayesian
approach.  The following book by Gelman, Carlin, Stern and Rubin gives a
comprehensive coverage of the subject.

* Andrew Gelman, John B. Carlin, Hal S. Stern, Donald B. Rubin.
  *Bayesian Data Analysis*.
  Chapman & Hall, ISBN 0412039915.
