module ml

import vsl.errors

// most_frequent_ngrams returns an array with up to `n_features` elements
// denoting the most frequent ngrams in `ngrams`.
// Since V does not support map of arrays, the ngrams are joined by
// "NGRAMSEP". If `n_features` is <= 0, it will be set to ngrams.len.
pub fn most_frequent_ngrams(ngrams [][]string, n_features int) ?[][]string {
	if ngrams.len == 0 {
		return errors.error('ngram_frequency_map expects a non-empty array of ngrams.',
			.einval)
	}
	mut n_features_ := n_features
	if n_features <= 0 {
		n_features_ = ngrams.len
	} else if n_features > ngrams.len {
		return errors.error('n_features cannot be greater than the amount of ngrams.',
			.einval)
	}
	mut freq_map := map[string]int{}
	mut joined := ngrams.map(it.join(ngram_sep))
	// ngrams are joined by `ngram_sep` due to maps
	// not supporting []string keys yet.
	for ngram in joined {
		if ngram !in freq_map {
			freq_map[ngram] = 0
		}
		freq_map[ngram]++
	}
	mut result := [][]string{}
	for _ in 0 .. n_features_ {
		keys := freq_map.keys()
		if keys.len == 0 {
			break
		}
		mut most_frequent := keys[0]
		for ngram in keys {
			if freq_map[ngram] > freq_map[most_frequent] {
				most_frequent = ngram
			}
		}
		result << most_frequent.split(ngram_sep)
		freq_map.delete(most_frequent)
	}
	return result
}

// count_vectorize will give you an array of occurrences of each
// ngram from `ngrams` in `most_frequent`. Assume
// `ng := [['hello'], ['hello'], ['hi']]`.
// `ml.count_vectorize(ng, ml.most_frequent_ngrams(ng, 0))`
// should return `[2, 1]`. See `most_frequent_ngrams for more`
// details on how it works.
pub fn count_vectorize(ngrams [][]string, most_frequent [][]string) []int {
	mut result := []int{len: most_frequent.len, init: 0}
	for ngram in ngrams {
		for i, m_f in most_frequent {
			if ngram == m_f {
				result[i]++
			}
		}
	}
	return result
}
