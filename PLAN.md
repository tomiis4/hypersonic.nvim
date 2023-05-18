<h1 align="center"> My Plans For Explaining </h1>



# Split

##### input: 
```
gr[ae]y
```

##### output: 
```js
{
    "g",
    "r",
    {
        "#CLASS", // #CLASS or #GROUP
        "a",
        "e",
    },
    "y",
}
```

##### meta characters table: 
```lua
local meta_table = {
    ['n'] = 'Newline',
    ['r'] = 'Carriage return',
    ['t'] = 'Tab',
    ['s'] = 'Any whitespace character',
    ['S'] = 'Any non-whitespace character',
    ['d'] = 'Any digit',
    -- more in characters.txt
}
```

- create new table `main={}`, variable `depth=0`, `escape_char=false`
- loop for each char
    - `(`, `[`
        - `depth++`
        - create new table at `depth`
    - `)`, `]`
        - `depth--`
    - `\`
        - `escape_char=true`
        - if `escape_char` will be `true` and next char. is in meta characters table
            - put `\<char>`, else put only char


# Explain

##### input: 
```js
{
    "g",
    "r",
    {
        "#CLASS", // #CLASS or #GROUP
        "a",
        "e",
    },
    "y",
}
```

##### output: 
```c
+-------------------------------------------+
| Regex: gr[ae]y                            |
|-------------------------------------------+
| gr:   Begins with "gr"                    |
| [ae]: Followed by either "a" or "e"       |
| y:    Ends with "y"                       |
+-------------------------------------------+
```

- create `result` table
    - idx 1 = title (format: `Regex: <regex>`)
- recursively loop trough `input`
    - non groups
        - if char will start with `\`, get info from `meta_table`
        - else put char in table

## TODO
- to fix
    - `.`, any character
    - `|`, or
    - `?`, zero or one x?
    - `*`, 0 or more x*
    - `+`, 1 or more x+
    - `-`, from-to
    - `$`, end of string
    - `^`, start of string


# Merge
- merge that tables, so it's nice output


# Goals
- Explain
- Preview
- Snippets
