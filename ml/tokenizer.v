module ml

import vsl.errors

const punctuation = (
	',.[]()[]-=_*;:+><\\"`´~^!?@#$%¨&/|'.split('')
)

// remove_punctuation will remove the following characters from the string:
// `,.[]()[]-=_*;:+><\\"`´~^!?@#$%¨&/|'`
pub fn remove_punctuation(x string) string {
	mut new_x := x
	for punct in (punctuation.join('') + '\'').split('') {
		new_x = new_x.replace(punct, '')
	}
	return new_x
}

// tokenize will return an array of tokens from the string `x`.
pub fn tokenize(x string) []string {
	mut new_x := x
	for punct in '\n\t\v\r'.split('') {
		new_x = new_x.replace(punct, '')
	}
	mut tokens := []string{}

	mut current_piece := ''
	mut i := 0
	for i < new_x.len {
		current_char := [new_x[i]].bytestr()
		if current_piece.len == 0 && current_char == ' ' {
			i++
			continue
		}

		if current_char == ' ' {
			if current_piece.len > 0 {
				tokens << current_piece
			}
			current_piece = ''
			i++
			continue
		}

		if current_char in punctuation {
			tokens << current_piece
			tokens << current_char
			current_piece = ''
			i += 2
			continue
		}

		current_piece += current_char
		i++
	}

	if current_piece.len > 0 {
		tokens << current_piece
	}

	return tokens
}

// remove_stopwords will remove all tokens included in `stopwords`.
// If `ignore_case` is true, "THIS" will be considered as "this".
pub fn remove_stopwords(tokens []string, stopwords []string, ignore_case bool) []string {
	mut result := []string{}
	for tok_ in tokens {
		mut tok := tok_
		if ignore_case {
			tok = tok.to_lower()
		}
		if tok !in stopwords {
			result << tok
		}
	}
	return result
}

// remove_stopwords_en is a wrapper for `remove_stopwords`, passing
// a default array of some English stopwords.
pub fn remove_stopwords_en(tokens []string, ignore_case bool) []string {
	return remove_stopwords(tokens, [
		'a', 'about', 'above', 'after', 'again', 'against', 'ain',
		'ain\'t', 'all', 'am', 'an', 'and', 'any', 'are', 'aren',
		'aren\'t', 'as', 'at', 'be', 'because', 'been', 'before',
		'being', 'below', 'between', 'both', 'but', 'by', 'can',
		'couldn', 'couldn\'t', 'd', 'did', 'didn', 'didn\'t', 'do',
		'does', 'doesn', 'doesn\'t', 'doing', 'don', 'don\'t',
		'down', 'during', 'each', 'few', 'for', 'from', 'further',
		'had', 'hadn', 'hadn\'t', 'has', 'hasn', 'hasn\'t', 'have',
		'haven', 'haven\'t', 'having', 'he', 'her', 'here', 'hers',
		'herself', 'him', 'himself', 'his', 'how', 'i', 'if', 'in',
		'into', 'is', 'isn', 'isn\'t', 'it', 'it\'s', 'its', 'itself',
		'just', 'll', 'm', 'ma', 'me', 'mightn', 'mightn\'t', 'more',
		'most', 'mustn', 'mustn\'t', 'my', 'myself', 'needn', 'needn\'t',
		'now', 'o', 'of', 'off', 'on', 'once', 'only', 'or', 'other',
		'our', 'ours', 'ourselves', 'out', 'over', 'own', 're', 's',
		'same', 'shan', 'shan\'t', 'she', 'she\'s', 'should', 'should\'ve',
		'shouldn', 'shouldn\'t', 'so', 'some', 'such', 't', 'than', 'that',
		'that\'ll', 'the', 'their', 'theirs', 'them', 'themselves', 'then',
		'there', 'these', 'they', 'this', 'those', 'through', 'to', 'too',
		'under', 'until', 'up', 've', 'very', 'was', 'wasn', 'wasn\'t', 'we',
		'were', 'weren', 'weren\'t', 'what', 'when', 'where', 'which',
		'while', 'who', 'whom', 'why', 'will', 'with', 'won', 'won\'t',
		'wouldn', 'wouldn\'t', 'y', 'you', 'you\'d', 'you\'ll', 'you\'re',
		'you\'ve', 'your', 'yours', 'yourself', 'yourselves', 'could',
		'he\'d', 'he\'ll', 'he\'s', 'here\'s', 'how\'s', 'i\'d', 'i\'ll',
		'i\'m', 'i\'ve', 'let\'s', 'ought', 'she\'d', 'she\'ll', 'that\'s',
		'there\'s', 'they\'d', 'they\'ll', 'they\'re', 'they\'ve', 'we\'d',
		'we\'ll', 'we\'re', 'we\'ve', 'what\'s', 'when\'s', 'where\'s',
		'who\'s', 'why\'s', 'would'
	], ignore_case)
}

// ngrams will return an array of grams containing `n` elements
// from `tokens`. Example: `ngrams('the apple is red'.split(' '), 3)`
// will return [['the', 'apple', 'is'], ['apple', 'is', 'red']]
pub fn ngrams(tokens []string, n int) [][]string {
	mut grams := [][]string{}
	if tokens.len == 0 {
		return grams
	}
	if n > tokens.len {
		return [tokens]
	}
	if n <= 0 {
		errors.vsl_panic(
			'ml.ngrams expects n to be in the inclusive range [0, tokens.len].',
			.einval
		)
	}
	for i in 0..(tokens.len - n + 1) {
		grams << tokens[i..(i + n)]
	}
	return grams
}
