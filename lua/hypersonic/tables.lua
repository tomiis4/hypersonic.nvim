local T = {}

T.test_inputs = {
    '^hello',
    '(\\/)(.*)(\\/)',
    '\\d*',
    'gr[ae]y',
    '^[a-zA-Z|]+$',
    '^\\S+$',
    'x(y(\\d+))'
}

T.char_table = {
    ['^'] = 'Start of strig',
    ['$'] = 'End of strig',
    ['.'] = 'Every single character',
}

T.special_table = {
    ['|'] = 'or',
    ['-'] = 'to',
    ['?'] = 'Matches 0 or 1 times',
    ['*'] = 'Matches 0 or more times',
    ['+'] = 'Matches 1 or more'
}

T.meta_table = {
    ['n'] = 'Newline',
    ['r'] = 'Carriage return',
    ['t'] = 'Tab',
    ['s'] = 'Any whitespace character',
    ['S'] = 'Any non-whitespace character',
    ['d'] = 'Any digit',
    ['D'] = 'Any non-digit',
    ['w'] = 'Any word character',
    ['W'] = 'Any non-word character',
    ['b'] = 'A word boundary',
    ['B'] = 'Non-word boundary',
    ['0'] = 'Null character',
    ['X'] = 'Any Unicode sequences, linebreaks included',
    ['C'] = 'Match one data unit',
    ['R'] = 'Unicode newlines',
    ['N'] = 'Match anything but a newline',
    ['v'] = 'Vertical whitespace character',
    ['h'] = 'Horizontal whitespace character',
    ['G'] = 'Start of match',
    ['A'] = 'Start of string',
    ['Z'] = 'End of string',
    ['z'] = 'Absolute end of string'
}

return T
