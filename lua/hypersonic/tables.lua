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
    'ab\\(\\x',
    'ahoj'
}

T.char_table = {
    ['^'] = 'Start of string',
    ['$'] = 'End of string',
    ['.'] = 'Every single character',
}

T.quantifiers = {
    '?',
    '*',
    '+'
}

T.special_table = {
    ['|'] = 'or',
    ['-'] = 'to',
    ['?'] = '0 or 1 times',
    ['*'] = '0 or more times',
    ['+'] = '1 or more times'
}

T.meta_table = {
    ['n'] = 'Match Newline',
    ['r'] = 'Match Carriage return',
    ['t'] = 'Match Tab',
    ['s'] = 'Match Any whitespace character',
    ['S'] = 'Match Any non-whitespace character',
    ['d'] = 'Match Any digit',
    ['D'] = 'Match Any non-digit',
    ['w'] = 'Match Any word character',
    ['W'] = 'Match Any non-word character',
    ['b'] = 'Match A word boundary',
    ['B'] = 'Match Non-word boundary',
    ['0'] = 'Match Null character',
    ['X'] = 'Match Any Unicode sequences, linebreaks included',
    ['C'] = 'Match Match one data unit',
    ['R'] = 'Match Unicode newlines',
    ['N'] = 'Match Match anything but a newline',
    ['v'] = 'Match Vertical whitespace character',
    ['h'] = 'Match Horizontal whitespace character',
    ['G'] = 'Match Start of match',
    ['A'] = 'Match Start of string',
    ['Z'] = 'Match End of string',
    ['z'] = 'Match Absolute end of string'
}

return T
