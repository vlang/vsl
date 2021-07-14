module ml

import vsl.errors

const punctuation = (
	',.[]()[]-=_*;:+><\'\\"`´~^!?@#$%¨&/|'.split('')
)

// tokenize_ does the same as tokenize, but does not emit a warning.
pub fn tokenize_(x string) []string {
	new_x := x.replace_each(['\n', ' ', '\t', ' ', '\v', ' ', '\r', ' '])
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
			tokens << current_piece
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

	return tokens
}

// tokenize will warn about the lack of complexity of the implementation
// and will return an array of tokens from the string `x`.
pub fn tokenize(x string) []string {
	print(
		'vsl: Warning: vsl.ml.tokenize is still in development. It is not ' +
		'very advanced as of now, performing only simple things such as ' +
		'splitting by spaces and punctuation. To get rid of this message, ' +
		'run tokenize_(your_string) instead.'
	)
	return tokenize_(x)
}
