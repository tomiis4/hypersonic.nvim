local T = {}

T.test_inputs = {
    '^hello',
    '(\\/)(.*)(\\/)',
    '\\d*',
    'gr[ae]y',
    '^[a-zA-Z|]+$',
    '^\\S+$',
    'x(y(\\d+)\\()',
    'ac|\\x\\(',
    'ab\\(\\xxyz',
    'ah(oj)'
}

T.char_table = {
    ['^'] = 'start of string',
    ['$'] = 'end of string',
}

T.quantifiers = {
    '?',
    '*',
    '+',
}

T.lookahead = {
    ['?='] = 'Positive lookahead',
    ['!='] = 'Negative lookahead',
    ['?<='] = 'Positive lookbehind',
    ['?<!'] = 'Negative lookbehind',
}

T.special_table = {
    ['|'] = 'or',
    ['?'] = '(optional)',
    ['*'] = '0 or more times',
    ['+'] = '1 or more times',
    ['.'] = 'Match every character',
}

T.php_meta_table = {
    ['n'] = 'Match newline',
    ['r'] = 'Match carriage return',
    ['t'] = 'Match tab',
    ['s'] = 'Match any whitespace character',
    ['S'] = 'Match any non-whitespace character',
    ['d'] = 'Match any digit',
    ['D'] = 'Match any non-digit',
    ['w'] = 'Match any word character',
    ['W'] = 'Match any non-word character',
    ['b'] = 'Match a word boundary',
    ['B'] = 'Match non-word boundary',
    ['0'] = 'Match null character',
    ['X'] = 'Match any Unicode sequences, linebreaks included',
    ['C'] = 'Match match one data unit',
    ['R'] = 'Match unicode newlines',
    ['N'] = 'Match match anything but a newline',
    ['v'] = 'Match vertical whitespace character',
    ['h'] = 'Match horizontal whitespace character',
    ['G'] = 'Match start of match',
    ['A'] = 'Match start of string',
    ['Z'] = 'Match end of string',
    ['z'] = 'Match absolute end of string'
}

T.lua_meta_table = {
    ['a'] = 'Match any letters',
    ['A'] = 'Match all non-letter characters',
    ['c'] = 'Match any control characters',
    ['C'] = 'Match all non-control characters',
    ['d'] = 'Match any digits',
    ['D'] = 'Match all non-digit characters',
    ['l'] = 'Match any lowercase letters',
    ['L'] = 'Match all non-lowercase letters',
    ['p'] = 'Match any punctuation characters',
    ['P'] = 'Match all non-punctuation characters',
    ['s'] = 'Match any whitespace characters',
    ['S'] = 'Match all non-whitespace characters',
    ['u'] = 'Match any uppercase letters',
    ['U'] = 'Match all non-uppercase letters',
    ['w'] = 'Match any alphanumeric characters',
    ['W'] = 'Match all non-alphanumeric characters',
    ['x'] = 'Match any hexadecimal digits',
    ['X'] = 'Match all non-hexadecimal digits',
    ['z'] = 'Match the null character',
    ['Z'] = 'Match all non-null characters',
    ['b'] = 'Match balanced character pairs',
    ['B'] = 'Match all non-balanced character pairs',
    ['f'] = 'Match frontier'
}

T.meta_table = T.php_meta_table

return T
