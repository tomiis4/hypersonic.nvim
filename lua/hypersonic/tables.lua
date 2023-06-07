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
    'ahoj'
}

T.char_table = {
    ['^'] = 'start of string',
    ['$'] = 'end of string',
}

T.quantifiers = {
    '?',
    '*',
    '+',
    '.'
}

T.special_table = {
    ['|'] = 'or',
    ['-'] = 'to',
    ['?'] = '0 or 1 times',
    ['*'] = '0 or more times',
    ['+'] = '1 or more times',
    ['.'] = 'Match every character',
}

T.meta_table = {
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

return T
