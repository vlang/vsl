module ml

import vsl.vmath as math
import vsl.errors

// TODO: Optimize the code below, if possible.

// term_frequencies will return the frequency of each term in a sentence.
// However, since in VSL NLP tools we deal with ngrams instead of regular
// "words" (1gram tokens), our sentence is actually a collection of ngrams
// and our words/terms are the ngrams themselves. Keep in mind that, since
// V does NOT support maps of arrays, ngrams are joined by the constant
// `ngram_sep`, which can be found in `ml/tokenizer.v`. This is why it
// returns a `map[string]f64` and not a `map[[]string]f64`.
pub fn term_frequencies(ngrams_sentence [][]string) ?map[string]f64 {
	if ngrams_sentence.len == 0 {
		return errors.error('expects ngrams_sentence to have at least 1 ngram.', .einval)
	}
	mut tf := map[string]f64{}
	joined := ngrams_sentence.map(it.join(ngram_sep))
	mut freq_map := map[string]int{}
	for ngram in joined {
		if ngram !in freq_map {
			freq_map[ngram] = 0
		}
		freq_map[ngram]++
	}
	for ngram in joined {
		tf[ngram] = freq_map[ngram] / f64(ngrams_sentence.len)
	}
	return tf
}

// inverse_document_frequencies will return the IDF of each term by calling
// `term_idf` on each unique ngram. Check `term_idf` for more details about
// the parameter `document`.
pub fn inverse_document_frequencies(document [][][]string) ?map[string]f64 {
	if document.len == 0 {
		return errors.error('expects at least one sentence.', .einval)
	}

	mut idf := map[string]f64{}

	mut unique_ngrams := []string{}
	for sentence in document {
		for ngram in sentence.map(it.join(ngram_sep)) {
			if ngram !in unique_ngrams {
				unique_ngrams << ngram
			}
		}
	}

	for ngram in unique_ngrams {
		idf[ngram] = term_idf(ngram.split(ngram_sep), document) ?
	}
	return idf
}

// term_idf will return the IDF of a single term term.  However, since in
// VSL NLP tools we deal with ngrams instead of regular "words" (1gram
// tokens), our document is actually a collection of ngrams and our
// words/terms are the ngrams themselves. This means that a document (a
// collection of sentences) is actually a `[][][]string` (array of sentences,
// which by themselves are arrays of ngrams, which are arrays of string).
// Keep in mind that, since V does NOT support maps of arrays, ngrams are
// joined by the constant `ngram_sep`, which can be found in `ml/tokenizer.v`.
// This is why it returns a `map[string]f64` and not a `map[[]string]f64`.
pub fn term_idf(term []string, document [][][]string) ?f64 {
	if document.len == 0 {
		return errors.error('expects at least one sentence.', .einval)
	}
	if term.len == 0 {
		return errors.error('expects at least one ngram.', .einval)
	}

	ngram := term.join(ngram_sep)

	mut n_sentences_with_ngram := 0
	for sentence in document {
		if ngram in sentence.map(it.join(ngram_sep)) {
			n_sentences_with_ngram++
		}
	}

	// log base doesnt really matter, as long as it is indeed a logarithm.
	// I chose 2 because it seems to be the most common log base for computer
	// science in general.
	return math.log2(f64(document.len) / f64(n_sentences_with_ngram))
}

// tf_idf will return the TF * IDF for any given ngram, in a sentence, in a
// document.
pub fn tf_idf(ngram []string, sentence [][]string, document [][][]string) ?f64 {
	tfs := term_frequencies(sentence) ?
	tf := tfs[ngram.join(ngram_sep)]
	idf := term_idf(ngram, document) ?
	return tf * idf
}
