module main

import vsl.ml.nlp
import vsl.ml

const dataset = [
	['I think apples are good.', 'positive'],
	['Good people do good things.', 'positive'],
	['The pie tastes bad and bitter.', 'negative'],
	['I hate you so much!', 'negative'],
	['I am very happy for you!', 'positive'],
	['You are a bad person.', 'negative'],
]

// Arbitrary values. Since nlp.KNN only takes floats, we must represent
// our classes (positive or negative) as floats.
class := {
	'positive': 1.0
	'negative': -1.0
}

class_inverse := {
	'1.0':  'positive'
	'-1.0': 'negative'
}

// Now we want to convert our dataset to a numeric representation.
// We can do this in two ways: using bag of words (count vectorizer)
// or with TF-IDF. We must, however, prepare our data first.

// Some words such as "do", "am", "are" are useless in our context,
// and they are included in VSL's default stopword list. We must remove
// those stopwords because they don't mean anything for us when trying
// to analyze sentiments. Punctuation is also not needed, so we will be
// using nlp.remove_punctuation and set everything to lowercase. However,
// we must first tokenize our sentence (divide it into single words).
// It is not complicated at all, see below. Let's also convert our classes
// to the numerical representation.
mut tokens := [][]string{}
mut labels := []f64{}
for row in dataset {
	tokenized := nlp.tokenize(nlp.remove_punctuation(row[0]).to_lower())

	// To specify custom stopwords for your language, run:
	// nlp.remove_stopwords(tokens []string, stopwords []string, ignore_case bool).
	tokens << nlp.remove_stopwords_en(tokenized, true) // Last parameter is a flag to set everything to lowercase. If set to false, case is kept.
	labels << class[row[1]]
}

// After that, an important step will be stemming. What does that do?
// Well, stemming is keeping the radicals of words so that terms such
// as "try", "tried" and "trying" are considered the same token: "try".
// Let's create a stemmer:
mut lancaster := nlp.new_lancaster_stemmer(true) // Parameter is strip_prefix. If true, "kilogram" becomes "gram", for example.

// List of sentences as ngrams, read the comments
// below to understand.
mut ngrams := [][][]string{}

mut all_ngrams := [][]string{} // Will be used later.
for i in 0 .. dataset.len {
	// The map function is an array operation.
	// Refer to https://github.com/vlang/v/blob/master/doc/docs.md#array-operations
	mut stemmed := []string{}
	for token in tokens[i] {
		// There is an option/result below because the LancasterStemmer
		// accepts custom rules (which we will not be getting into), and
		// it makes sure they are valid. For this example, the code below
		// should NOT throw errors.
		stemmed << lancaster.stem(token)?
	}

	// Now we need to extract ngrams. Since VSL provides ngram support,
	// it is important that we only use ngrams (even if n = 1) due to V
	// limitations. If you don't know it already, ngrams are groups of
	// n tokens. Here is an example:
	// 2grams from ['hello', 'my', 'friend'] = [['hello', 'my'], ['my', 'friend']]
	// Since in our dataset the previous token doesn't matter ('good' and
	// 'bad' are the only decisive factors), our n is going to be 1.
	// For the example above, 1grams would be [['hello'], ['my'], ['friend']].
	// The option/result below is in case you pass negative values to nlp.ngrams.
	ng := nlp.ngrams(stemmed, 1)? // [][]string
	ngrams << ng // appends [][]string to ngrams ([][][]string)
	all_ngrams << ng // extends all_ngrams([][]string) by [][]string
}

// Now we must choose a method for sentiment analysis: bag of words or TF-IDF.
// We will be working with both for a more indepth example! First, let's do
// bag of words. It is implemented using nlp.most_frequent_ngrams and nlp.count_vectorize.
// We need to specify a number of features (that is, how many ngrams will be
// returned by nlp.most_frequent_ngrams). Since in this case the decisive tokens
// in our dataset are "good" and "bad", lets go for a low number: 5. This number
// should be higher if you use ngrams > 1 and have more data.
n_features := 5
mut most_freq := nlp.most_frequent_ngrams(all_ngrams, n_features)? // [][]string

// Now, for each sentence, we will get the array of number of occurrences
// for each ngram in it. Sounds confusing? Well, here's an example:
// Say your most frequent 1grams are [['good'], ['bad']] and the number of
// features is two. The count_vectorize of the sentence (as 1grams):
// [['you'], ['are'], ['a'], ['good'], ['person'], ['and'], ['good'], ['looking']]
// would be [2, 0] because there are 2 instances of ['good'] and 0 of ['bad'].
mut vectorized := [][]f64{}
for i in 0 .. dataset.len {
	// We have to use array.map() to cast all values from int (original
	// return type of nlp.count_vectorize) to f64, to feed to our KNN model
	// in the next steps.
	vectorized << nlp.count_vectorize(ngrams[i], most_freq).map(f64(it))
}

// Amazing! We have all we need to train a sentiment analysis model with
// bag of words. Check it out:
mut training_data := ml.data_from_raw_xy_sep(vectorized, labels)?
mut bow_knn := ml.new_knn(mut training_data, 'BagOfWordsKNN')?

sentence1 := 'I think today is a good day' // should be positive
sentence2 := 'I hate grape juice, it tastes bad.' // should be negative

// In order to predict them, we have to do the same we did for all
// our training samples: tokenize, stem and ngramize (does that term
// even exist?)
bow := fn (sent string, mut lan nlp.LancasterStemmer, mf [][]string) ?[]f64 {
	sent_tokenized := nlp.remove_stopwords_en(nlp.tokenize(nlp.remove_punctuation(sent).to_lower()),
		true)
	mut sent_stemmed := []string{}
	for tok in sent_tokenized {
		sent_stemmed << lan.stem(tok)?
	}
	sent_ngrams := nlp.ngrams(sent_stemmed, 1)?
	return nlp.count_vectorize(sent_ngrams, mf).map(f64(it))
}

bow_prediction1 := bow_knn.predict(
	k: 2
	// low value due to small dataset
	to_pred: bow(sentence1, mut lancaster, most_freq)?
)?
bow_prediction2 := bow_knn.predict(
	k: 2
	// low value due to small dataset
	to_pred: bow(sentence2, mut lancaster, most_freq)?
)?

// Convert from numeric representation to text:
// 1.0: positive, -1.0: negative.
bow_label1 := class_inverse[bow_prediction1.str()]
bow_label2 := class_inverse[bow_prediction2.str()]

println('"${sentence1}" predicted as "${bow_label1}" using bag of words.')
println('"${sentence2}" predicted as "${bow_label2}" using bag of words.')

// Now let's use TF-IDF and see if we get something different.
// It takes a document (an array of sentences, which by itself is an array
// of ngrams, so [][][]string), which in this case is the variable `ngrams`.
mut unique_ngrams := [][]string{}
for ng in all_ngrams {
	if ng !in unique_ngrams {
		unique_ngrams << ng
	}
}

// Number of features will be the number of unique ngrams, just
// for the sake it. You can truncate and pad to a fixed length
// if you want to, but let's do it this other way to have somewhat
// complete sentence information.
mut tf_idf_rows := [][]f64{}

// Remember, `ngrams` is the ngram representation of each sentence
// in our dataset.
for sent in ngrams {
	mut tf_idf_sentence := []f64{}
	for u_ng in unique_ngrams {
		tf_idf_sentence << nlp.tf_idf(u_ng, sent, ngrams)?
	}
	tf_idf_rows << tf_idf_sentence
}

training_data = ml.data_from_raw_xy_sep(tf_idf_rows, labels)?
mut tf_idf_knn := ml.new_knn(mut training_data, 'TfIdfKNN')?

tfidf := fn (sent string, mut lan nlp.LancasterStemmer, document [][][]string, unique [][]string) ?[]f64 {
	sent_tokenized := nlp.remove_stopwords_en(nlp.tokenize(nlp.remove_punctuation(sent).to_lower()),
		true)
	mut sent_stemmed := []string{}
	for tok in sent_tokenized {
		sent_stemmed << lan.stem(tok)?
	}
	mut sent_ng := nlp.ngrams(sent_stemmed, 1)?
	mut tf_idf_sentence := []f64{}
	for u_ng in unique {
		tf_idf_sentence << nlp.tf_idf(u_ng, sent_ng, document)?
	}
	return tf_idf_sentence
}

tf_idf_prediction1 := tf_idf_knn.predict(
	k: 2
	// low value due to small dataset
	to_pred: tfidf(sentence1, mut lancaster, ngrams, unique_ngrams)?
)?

tf_idf_prediction2 := tf_idf_knn.predict(
	k: 2
	// low value due to small dataset
	to_pred: tfidf(sentence2, mut lancaster, ngrams, unique_ngrams)?
)?

tf_idf_label1 := class_inverse[tf_idf_prediction1.str()]
tf_idf_label2 := class_inverse[tf_idf_prediction2.str()]

println('"${sentence1}" predicted as "${tf_idf_label1}" using TF-IDF.')
println('"${sentence2}" predicted as "${tf_idf_label2}" using TF-IDF.')
