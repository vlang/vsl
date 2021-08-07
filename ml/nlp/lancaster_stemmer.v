module nlp

import regex
import vsl.errors

// The pieces of code for LancasterStemmer and its utilities found below
// were originally written in Python by the NLTK Project (Copyright 2001 - 2021),
// more specifically by Steven Tomcavage. This is just a translation from Python to V
// with minor changes, such as naming convention and code structure.

// The nltk library, developed by the NLTK Project (https://www.nltk.org),
// is licensed under Apache 2.0, available at <https://www.apache.org/licenses/LICENSE-2.0>.

// The original code for the LancasterStemmer, which was acquired from NLTK's `stem`
// submodule can be found at <https://www.nltk.org/_modules/nltk/stem/lancaster.html>.

// All credits go to the respective authors of NLTK's LancasterStemmer implementation.

pub struct LancasterStemmer {
mut:
	rule_map map[string][]string
pub mut:
	strip_prefix bool
	rules        []string = [
	'ai*2.',
	'a*1.',
	'bb1.',
	'city3s.',
	'ci2>',
	'cn1t>',
	'dd1.',
	'dei3y>',
	'deec2ss.',
	'dee1.',
	'de2>',
	'dooh4>',
	'e1>',
	'feil1v.',
	'fi2>',
	'gni3>',
	'gai3y.',
	'ga2>',
	'gg1.',
	'ht*2.',
	'hsiug5ct.',
	'hsi3>',
	'i*1.',
	'i1y>',
	'ji1d.',
	'juf1s.',
	'ju1d.',
	'jo1d.',
	'jeh1r.',
	'jrev1t.',
	'jsim2t.',
	'jn1d.',
	'j1s.',
	'lbaifi6.',
	'lbai4y.',
	'lba3>',
	'lbi3.',
	'lib2l>',
	'lc1.',
	'lufi4y.',
	'luf3>',
	'lu2.',
	'lai3>',
	'lau3>',
	'la2>',
	'll1.',
	'mui3.',
	'mu*2.',
	'msi3>',
	'mm1.',
	'nois4j>',
	'noix4ct.',
	'noi3>',
	'nai3>',
	'na2>',
	'nee0.',
	'ne2>',
	'nn1.',
	'pihs4>',
	'pp1.',
	're2>',
	'rae0.',
	'ra2.',
	'ro2>',
	'ru2>',
	'rr1.',
	'rt1>',
	'rei3y>',
	'sei3y>',
	'sis2.',
	'si2>',
	'ssen4>',
	'ss0.',
	'suo3>',
	'su*2.',
	's*1>',
	's0.',
	'tacilp4y.',
	'ta2>',
	'tnem4>',
	'tne3>',
	'tna3>',
	'tpir2b.',
	'tpro2b.',
	'tcud1.',
	'tpmus2.',
	'tpec2iv.',
	'tulo2v.',
	'tsis0.',
	'tsi3>',
	'tt1.',
	'uqi3.',
	'ugo1.',
	'vis3j>',
	'vie0.',
	'vi2>',
	'ylb1>',
	'yli3y>',
	'ylp0.',
	'yl2>',
	'ygo1.',
	'yhp1.',
	'ymo1.',
	'ypo1.',
	'yti3>',
	'yte3>',
	'ytl2.',
	'yrtsi5.',
	'yra3>',
	'yro3>',
	'yfi3.',
	'ycn2t>',
	'yca3>',
	'zi2>',
	'zy1s.',
]
}

// new_lancaster_stemmer returns a LancasterStemmer struct with a
// predefined set of stemming rules.
pub fn new_lancaster_stemmer(strip_prefix bool) LancasterStemmer {
	return LancasterStemmer{
		strip_prefix: strip_prefix
	}
}

// parse_rules makes sure all rules provided are allowed by the following
// regex: `^[a-z]+\*?\d[a-z]*[>\.]?$`.
fn (mut stemmer LancasterStemmer) parse_rules(rules []string) ? {
	mut valid_rule := regex.regex_opt('^[a-z]+\\*?\\d[a-z]*[>\\.]?$') or {
		return errors.error('regex error in LancasterStemmer, this should never happen. File an issue if you see this error',
			.efailed)
	}
	for rule in rules {
		regex_match, _ := valid_rule.match_string(rule)
		if regex_match == -1 {
			return errors.error('invalid LancasterStemmer rule "$rule"', .einval)
		}
		// Indexing a string returns a byte. Turn it into an array of bytes
		// and call bytestr() to turn it into a string.
		first_letter := [rule[0]].bytestr()
		if first_letter in stemmer.rule_map {
			stemmer.rule_map[first_letter] << rule
		} else {
			stemmer.rule_map[first_letter] = [rule]
		}
	}
}

// set_rules redefines the rules of stemmer and parses it.
pub fn (mut stemmer LancasterStemmer) set_rules(rules []string) ? {
	if rules.len == 0 {
		return errors.error('no LancasterStemmer rules provided.', .einval)
	}
	stemmer.rule_map = map[string][]string{}
	stemmer.rules = rules
	// I know this is ugly and could simply be stemmer.parse_rules()
	// but I decided to keep it like this just in case the user wants
	// to parse some set of rules and not assign it to their stemmer
	// just yet.
	return stemmer.parse_rules(rules)
}

// stem serves as a wrapper for do_stemming, which is private.
pub fn (mut stemmer LancasterStemmer) stem(word string) ?string {
	mut lowercase := word.to_lower()
	strip := fn (w string) string {
		for prefix in ['kilo', 'micro', 'milli', 'intra', 'ultra', 'mega', 'nano', 'pico', 'pseudo'] {
			if w.starts_with(prefix) {
				return w.substr(prefix.len, w.len)
			}
		}
		return w
	}
	if stemmer.strip_prefix {
		lowercase = strip(lowercase)
	}
	mut intact_word := lowercase
	if stemmer.rule_map.len == 0 {
		stemmer.parse_rules(stemmer.rules) or { return err }
	}
	return stemmer.do_stemming(lowercase, intact_word)
}

// do_stemming performs the actual stemming based on the set of rules
// and the regex `^([a-z]+)(\*?)(\d)([a-z]*)([>\.]?)$`.
fn (stemmer LancasterStemmer) do_stemming(word_ string, intact_word string) string {
	mut word := word_
	mut valid_rule := regex.regex_opt('^([a-z]+)(\\*?)(\\d)([a-z]*)([>\\.]?)$') or {
		errors.vsl_panic('regex error in LancasterStemmer, this should never happen. File an issue if you see this error',
			.efailed)
		return word
	}
	mut proceed := true
	for proceed {
		mut last_letter_position := -1
		for char_idx, character in word {
			if 'abcdefghijklmnopqrstuvwxyz'.contains([character].bytestr()) {
				last_letter_position = char_idx
			} else {
				break
			}
		}
		if last_letter_position == -1 || [word[last_letter_position]].bytestr() !in stemmer.rule_map {
			proceed = false
		} else {
			mut rule_was_applied := false
			for rule in stemmer.rule_map[[word[last_letter_position]].bytestr()] {
				regex_match, _ := valid_rule.match_string(rule)
				if regex_match >= 0 {
					ending_string := valid_rule.get_group_by_id(rule, 0)
					intact_flag := valid_rule.get_group_by_id(rule, 1)
					remove_total := valid_rule.get_group_by_id(rule, 2).int()
					append_string := valid_rule.get_group_by_id(rule, 3)
					cont_flag := valid_rule.get_group_by_id(rule, 4)

					is_acceptable := fn (w string, r int) bool {
						if 'aeiouy'.contains([w[0]].bytestr()) {
							if w.len - r >= 2 {
								return true
							}
						} else if w.len - r >= 3 {
							if 'aeiouy'.contains([w[1]].bytestr())
								|| 'aeiouy'.contains([w[2]].bytestr()) {
								return true
							}
						}
						return false
					}

					apply_rule := fn (w_ string, r int, a string) string {
						mut w := w_
						new_word_length := w.len - r
						w = w.substr(0, new_word_length)
						if a.len > 0 {
							w += a
						}
						return w
					}

					if word.ends_with(ending_string.reverse()) {
						if intact_flag.len > 0 {
							if word == intact_word && is_acceptable(word, remove_total) {
								word = apply_rule(word, remove_total, append_string)
								rule_was_applied = true
								if cont_flag == '.' {
									proceed = true
								}
								break
							}
						} else if is_acceptable(word, remove_total) {
							word = apply_rule(word, remove_total, append_string)
							rule_was_applied = true
							if cont_flag == '.' {
								proceed = false
							}
							break
						}
					}
				}
			}
			if !rule_was_applied {
				proceed = false
			}
		}
	}
	return word
}
