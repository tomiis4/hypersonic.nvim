<h1 align="center"> My Plans For Explaining </h1>

- [ ] Take regex from current line.
- [ ] Spit to specified format.
- [ ] Explain that regex.
- [ ] Return result in floating window.


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

##### special table: 
```lua
local special_table = {
    ["Newline"]                      = "n",
    ["Carriage return"]              = "r",
    ["Tab"]                          = "t",
    ["Any whitespace character"]     = "s",
    ["Any non-whitespace character"] = "S"
    -- more in characters.txt
}
```

- create new table `main={}`, variable `depth=0`, `special=false`
- loop for each char
    - `(`, `[`
        - `depth++`
        - create new table at `depth`
    - `)`, `]`
        - `depth--`
    - `\`
        - `special=true`
        - if `special` will be `true` and next char. is in special table
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
        - if char will start with `\`, get info from `special_table`
- merge that tables, so it's nice output

- to fix
    - `.`, any character
    - `|`, or
    - `?`, zero or one x?
    - `*`, 0 or more x*
    - `+`, 1 or more x+
    - `-`, from-to
    - `$`, end of string
    - `^`, start of string

# Goals
- Explain
- Preview
- Snippets
