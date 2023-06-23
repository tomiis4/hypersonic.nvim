<h1 align="center"> Hypersonic - NeoVim Plugin for Regex Writing and Testing </h1>

<p align="center">
    A powerful NeoVim plugin created to increase your regular expression (RegExp) writing and testing experience. 
    Whether you're a newbie or profesional developer, Hypersonic is here to make your life easier and boost your productivity
</p>


<hr>

<h3 align="center"> <img src='https://media.discordapp.net/attachments/772927831441014847/1121863260128415825/image.png?width=815&height=458'> </h3>
<h6 align="center"> Colorscheme: Rose-Pine; Font: JetBrainsMono NF </h6>

<hr>


## Features

- **Interactive RegExp Testing**:  Hypersonic provides an interactive testing environment right within NeoVim. You can easily write your RegExp patterns and instantly see the matches highlighted in real-time.

- **Pattern Explanation**: Understanding complex RegExp patterns can be challenging. Hypersonic comes with an integrated pattern explanation feature that provides detailed explanations for your RegExp patterns, helping you grasp their meaning and behavior.


## Currently accessible
- Simple RegExp explaining
- Language support for LUA
- CommandLine live explanation

## Known issues
- Does not work in v`0.8.3` (only tested one)
- Advanced regex is not working (e.g. `(?:)`)
- Works only for correctly written regex.
- Nested groups are not displaying correctly

## Usage
1. selecting
    - select RegExp then enter command `:Hypersonic`
    - <details>
        <summary> preview </summary>
        <img src='https://media.discordapp.net/attachments/772927831441014847/1121863260128415825/image.png?width=815&height=458'>
    </details>
2. command
    - enter command: `:Hypersonic your-regex`
    - <details>
        <summary> preview </summary>
        <img src='https://media.discordapp.net/attachments/772927831441014847/1121863260451393576/image.png?width=815&height=458'>
    </details>
3. command-line search
    - in cmd search `/your-regex` or `?your-regex`
    - <details>
        <summary> preview </summary>
        <img src='https://media.discordapp.net/attachments/772927831441014847/1121863260736585729/image.png?width=815&height=458'>
    </details>

## Installation

<details>
<summary> Using vim-plug </summary>

```vim
Plug 'tomiis4/Hypersonic.nvim'
```

</details>

<details>
<summary> Using packer </summary>

```lua
use 'tomiis4/Hypersonic.nvim'
```

</details>

<details>
<summary> Using lazy </summary>

```lua
return {
    'tomiis4/Hypersonic.nvim',
    cmd = "Hypersonic",
    config = function()
        require('hypersonic').setup({
            -- config
        })
    end
}
```

</details>


## Setup

```lua
require('hypersonic').setup()
```

<details>
<summary> Default configuration </summary>

```lua
require('hypersonic').setup({
    ---@type 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|table
    border = 'rounded',
    ---@type number 0-100
    winblend = 0,
    ---@type boolean
    add_padding = true,
    ---@type string
    hl_group = 'Keyword',
    ---@type string
    wrapping = '"',
    ---@type boolean
    enable_cmdline = true
})
```

</details>


## File order
```
|   LICENSE
|   README.md
|
+---lua
|   \---hypersonic
|           config.lua
|           explain.lua
|           init.lua
|           merge.lua
|           split.lua
|           tables.lua
|           utils.lua
|
+---plugin
|       hypersonic.lua
|
\---test
        testing_file.txt
```

<details>
<summary> How does it work </summary>

## How does it work?

### Process
-  Take regex from current line.
-  Spit to specified format.
-  Explain that regex.
-  Return result in floating window.


### Split

<details>
<summary> input </summary>

```
gr[ae]y
```

</details>

<details>
<summary> output </summary>

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

</details>

<details>
<summary> meta characters table </summary>

```lua
local meta_table = {
    ['n'] = 'Newline',
    ['r'] = 'Carriage return',
    ['t'] = 'Tab',
    ['s'] = 'Any whitespace character',
    ['S'] = 'Any non-whitespace character',
    ['d'] = 'Any digit',
    -- more in tables.lua
}
```

</details>

- create new table `main={}`, variable `depth=0`, `escape_char=false`
- loop for each char
    - `(`, `[`
        - `depth++`
        - create new table at `depth`
        - add `#CLASS` or `#GROUP` to new table
    - `)`, `]`
        - `depth--`
    - `\`
        - `escape_char=true`
        - if `escape_char` will be `true` and next char. is in meta characters table
            - put `\<char>`, else put only char


### Explain

<details>
<summary> input </summary>

```js
{
    'g',
    'r',
    {
        '#CLASS', // #CLASS or #GROUP
        'a',
        'e',
    },
    'y',
}
```

</details>

<details>
<summary> output </summary>

```lua
{
    { '', 'gr[ae]y' },
    { 'g',     'Match g' },
    { 'r',     'Match r' },
    {
        { 'class #CLASS', '#CLASS' },
        { 'a',            'Match a', },
        { '',             'or', },
        { 'e',            'Match e', },
    },
    { 'y', 'Match y', }
}
```

</details>

- create `result` table
    - idx 1 = title (format: `Regex: <regex>`)
- recursively loop trough `input`
    - global
        - if character `* + ?`
            - edit last character to specific type

    - non class
        - if char will start with `\`, get info from `meta_table`
        - else put char in table

    - class
        - if characters next to each-other, its `or`
        - if character `-` make range
- types
    - `.`, any character
    - `|`, or
    - `?`, zero or one x?
    - `*`, 0 or more x*
    - `+`, 1 or more x+
    - `-`, from-to
    - `$`, end of string
    - `^`, start of string


### Merge

<details>
<summary> input </summary>

```js
{
    { '', 'gr[ae]y' },
    { 'g',     "Match g' },
    { 'r',     "Match r' },
    {
        { 'class #CLASS', '#CLASS' },
        { 'a',            'Match a' },
        { '',             'gr' },
        { 'e',            'Match e' },
    },
    { 'y', 'Match y', }
}
```

</details>

<details>
<summary> output </summary>

```lua
{
    {'',  'gr[ae]y'},
    {'gr',     'Match gr'},
    {'[ae]',   'Match either', 
        {'one character from list ae'},
    },
    {'y',      'Match "y"'}
}
```

</details>

<details>
<summary> NeoVim output </summary>

```
+-gr[ae]y------------------------------+
| "gr":   Match gr                     |
| "[ae]": Match either                 |
|    1) one chacarcter from list ae    |
| "y":    Match y                      |
+--------------------------------------+
```

</details>


- `v`: 1 = key, 2 = explanation
- `temp`: 1 = key, 2 = value, 3 = second data

</details>


## Contributors

<table>
    <tbody>
        <tr>
            <td align="center" valign="top" width="14.28%">
                <a href="https://github.com/tomiis4">
                <img src="https://avatars.githubusercontent.com/u/87276646?v=4" width="50px;" alt="tomiis4"/><br />
                <sub><b> tomiis4 </b></sub><br />
                <sup> founder </sup>
                </a><br/>
            </td>
            <td align="center" valign="top" width="14.28%">
                <a href="https://github.com/NormTurtle">
                <img src="https://avatars.githubusercontent.com/u/108952834?v=4" width="50px;" alt="NormTurtle"/><br />
                <sub><b> NormTurtle </b></sub><br />
                <sup> command-line preview idea </sup>
                </a><br/>
            </td>
        </tr>
    </tbody>
</table>
