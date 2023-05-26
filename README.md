<h1 align="center"> Hypersonic - NeoVim Plugin for Regex Writing and Testing (Under Development) </h1>

<p align="center">
<b>
Note: Hypersonic is currently under development and is not ready for immediate use. Please stay tuned for future updates and releases.
</b>
</p>

<p align="center">
    A powerful NeoVim plugin created to increase your regular expression (RegExp) writing and testing experience. 
    Whether you're a newbie or profesional developer, Hypersonic is here to make your life easier and boost your productivity
</p>



<hr>

<h3 align="center"> image preview </h3>

<hr>


## Features

- **Interactive RegExp Testing**:  Hypersonic provides an interactive testing environment right within NeoVim. You can easily write your RegExp patterns and instantly see the matches highlighted in real-time.

- **Pattern Explanation**: Understanding complex RegExp patterns can be challenging. Hypersonic comes with an integrated pattern explanation feature that provides detailed explanations for your RegExp patterns, helping you grasp their meaning and behavior.

- **Snippet Integration**: Save time and effort with Hypersonic's snippet integration. Easily access and insert commonly used RegExp patterns with just a few keystrokes.


## Language support
- [ ] JavaScript
- [ ] Lua


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
        require('hypersonic')
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
require('hypersonic').setup {
    ---@type 'round'|'bold'|'double'|'none'
    border = 'round',
}
```

</details>


## File order
```
|   LICENSE
|   README.md
|
+---lua
|   |
|   \---hypersonic
|           characters.txt
|           config.lua
|           explain.lua
|           split.lua
|           utils.lua
|
+---plugin
|       hypersonic.lua
|
\---test
        testing_file.txt

```

<details open>
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
    -- more in characters.txt
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
<summary> output </summary>

```lua
{
    { "Regex", "gr[ae]y" },
    { "g",     "Match g" },
    { "r",     "Match r" },
    {
        { "class #CLASS", "#CLASS" },
        { "a",            "Match a", },
        { "",             "or", },
        { "e",            "Match e", },
    },
    { "y", "Match y", }
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

<details open>
<summary> input </summary>

```js
{
    { "Regex", "gr[ae]y" },
    { "g",     "Match g" },
    { "r",     "Match r" },
    {
        { "class #CLASS", "#CLASS" },
        { "a",            "Match a", },
        { "",             "or", },
        { "e",            "Match e", },
    },
    { "y", "Match y", }
}
```

</details>

<details open>
<summary> output </summary>

```lua
{
    {'Regex',  'gr[ae]y'},
    {'gr',     'Begins with "gr"'},
    {'[ae]',   '<space>Followed by either "a" or "e"'},
    {'y',      'Ends with "y"'}
}
```

</details>

<details>
<summary> NeoVim output </summary>

```c
+-------------------------------------------+
| Regex: gr[ae]y                            |
|-------------------------------------------+
| gr:   Begins with "gr"                    |
| [ae]: Followed by either "a" or "e"       |
| y:    Ends with "y"                       |
+-------------------------------------------+
```

</details>

---
- TODO
    - [ ] Figure out what to do with classes
---
- recursively loop trough `input`, not including `idx=1`
- make empty string `temp_expl`
- if is normal letter/number (starts with "Match ")
    - `temp_expl` is empty
        - add `"Match " + "x"`
    - is not empty
        - remove last element (if is `"`), add letter, add `"`
- if is `temp_expl` not empty and char. is some special e.g. `|`
    - in `temp_expl` remove "Match" and add "Match either"
- if is some special explanation (does not start with "Match ")
    - if is `temp_expl` not empty, push it to new explanation
    - make it empty and push special explanation
- if is recursively, `depth++`

</details>


## Contributors

<table>
    <tbody>
        <tr>
            <td align="center" valign="top" width="14.28%">
                <a href="https://github.com/tomiis4">
                <img src="https://avatars.githubusercontent.com/u/87276646?v=4" width="50px;" alt="tomiis4"/><br /><sub><b>tomiis4</b></sub>
                </a><br/>
            </td>
        </tr>
    </tbody>
</table>
