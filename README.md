<h1 align="center"> Hypersonic - NeoVim Plugin for Regex Writing and Testing </h1>

<p align="center">
    A powerful NeoVim plugin created to increase your regular expression (RegExp) writing and testing experience.
    Whether you're a newbie or professional developer, Hypersonic is here to make your life easier and boost your productivity.
</p>


<hr>

<h3 align="center"> <img src='https://media.discordapp.net/attachments/892804952664203264/1218597241024024586/image-35.png?ex=66a3cf1e&is=66a27d9e&hm=c41d47a8734620a1590a4c12e19ef2abd5eb77c8021558b8b68c1e8e3b68a881&=&format=webp&quality=lossless&width=1177&height=662'> </h3>
<h6 align="center"> Colorscheme: Rose-Pine; Font: JetBrainsMono NF </h6>

<hr>


## Features

- **Interactive RegExp Testing**:  Hypersonic provides an interactive testing environment right within NeoVim. You can easily write your RegExp patterns and instantly see the matches highlighted in real-time.

- **Pattern Explanation**: Understanding complex RegExp patterns can be challenging. Hypersonic comes with an integrated pattern explanation feature that provides detailed explanations for your RegExp patterns, helping you grasp their meaning and behavior.


## Currently accessible
- Simple **RegExp** *explanation*
- Simple **error** handling techniques
- **CommandLine** *live* *explanation*
- Language support for **LUA**, **PHP**

## Known issues
- Does not work in `v0.8.3` (only tested one)
- Nested groups do not display correctly
- Advanced regex is not working (e.g. `(?:)`)
    - [ ] named capturing group (`(?:<name>)`)
    - [ ] non-capturing group (`(?:)`)
    - [ ] look-around (`(?=)`, `(?!)`, `(?<=)`, `(?<!)`)

## Usage
1. selecting
    - select RegExp then enter command `:Hypersonic`
    - <details>
        <summary> preview </summary>
        <img src='https://media.discordapp.net/attachments/892804952664203264/1218597241434935377/image-45.png?ex=66a3cf1e&is=66a27d9e&hm=79faf7c8fbb92777b185977a94c56394cd50cca36bf572becc576983d53aefd8&=&format=webp&quality=lossless&width=1177&height=662'>
    </details>
2. command
    - enter command: `:Hypersonic your-regex`
    - <details>
        <summary> preview </summary>
        <img src='https://media.discordapp.net/attachments/892804952664203264/1218597241024024586/image-35.png?ex=66a3cf1e&is=66a27d9e&hm=c41d47a8734620a1590a4c12e19ef2abd5eb77c8021558b8b68c1e8e3b68a881&=&format=webp&quality=lossless&width=1177&height=662'>
    </details>
3. command-line search
    - in cmd search `/your-regex` or `?your-regex`
    - <details>
        <summary> preview </summary>
        <img src='https://media.discordapp.net/attachments/892804952664203264/1218597240612978688/image-41.png?ex=66a3cf1e&is=66a27d9e&hm=8591cd0e3813b7ed06150261ced00df39423051685e79cf9ce13e1f5aa6fee65&=&format=webp&quality=lossless&width=1177&height=662'>
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
{
    'tomiis4/Hypersonic.nvim',
    event = "CmdlineEnter",
    cmd = "Hypersonic",
    config = function()
        require('hypersonic').setup({
            -- config
        })
    end
},
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
        testing_file.lua
```

<details>
<summary> How does it work </summary>

## How does it work?

### Process
- Take regex from current line.
- Spit to specified format.
- Explain that regex.
- Merge it for better readability.
- Return result in floating window.


### Split

<details>
<summary> input </summary>

```
gr[ae]y
```

</details>

<details>
<summary> output </summary>

```lua
{
    {
        type = "character",
        value = "g"
    },
    {
        type = "character",
        value = "r"
    },
    {
        type = "class",
        value = "ae"
    },
    {
        type = "character",
        value = "y"
    }
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

<details>
<summary> Node </summary>

```lua
{
    type = 'character'|'escaped'|'class'|'group'|'quantifier',
    value = '',
    children = Node|{},
    quantifiers = ''
}
```

</details>

- create new table `main={}` (type: _Node[]_)
- loop for each char
    - `\`
        - add future char to `main`
        - skip that char
    - `[`
        - get closing `]`
        - add content between `[]` to `main`
        - skip to closing `]`
    - `(`
        - get closing `)`
        - add split content between `()` to `children`
        - skip to closing `)`
    - `?`|`+`|`*`
        - add char to previous `Node.quantifiers`
    - other
        - create Node with that char

### Explain

<details>
<summary> input </summary>

```js
{
    {
        type = "character",
        value = "g"
    },
    {
        type = "character",
        value = "r"
    },
    {
        type = "class",
        value = "ae"
    },
    {
        type = "character",
        value = "y"
    }
}
```

</details>

<details>
<summary> output </summary>

```lua
{
    {
        explanation = "Match g",
        value = "g"
    },
    {
        explanation = "Match r",
        value = "r"
    },
    {
        children = { "a", "e" },
        explanation = "Match either",
        value = "[ae]"
    },
    {
        explanation = "Match y",
        value = "y"
    }
}
```

</details>

- create new table `main={}` (type: _Explained[]_)
- loop for each Node
    - `type == escaped | character`
        - explain character
        - check if is in any table
            - return that value
    - `type == class`
        - call `explain_class`
    - `type == group`
        - call `explain`

### Merge

<details>
<summary> input </summary>

```js
{
    {
        explanation = "Match g",
        value = "g"
    },
    {
        explanation = "Match r",
        value = "r"
    },
    {
        children = { "a", "e" },
        explanation = "Match either",
        value = "[ae]"
    },
    {
        explanation = "Match y",
        value = "y"
    }
}
```

</details>

<details>
<summary> output </summary>

```lua
{ 
    {
        explanation = "Match gr",
        value = "gr"
    }, 
    {
        explanation = "Match either",
        children = { "a or e" },
        value = "[ae]"
    }, 
    {
        explanation = "Match y",
        value = "y"
    }
}
```

</details>

<details>
<summary> NeoVim output </summary>

```
+-gr[ae]y------------------------------+
| "gr":   Match gr                     |
| "[ae]": Match either                 |
|    1) a or e                         |
| "y":    Match y                      |
+--------------------------------------+
```

</details>

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
            <td align="center" valign="top" width="14.28%">
                <a href="https://github.com/leekool">
                <img src="https://avatars.githubusercontent.com/u/88203649?v=4" width="50px;" alt="leekool"/><br />
                <sub><b> leekool </b></sub><br />
                <sup> spelling specialist </sup>
                </a><br/>
            </td>
        </tr>
    </tbody>
</table>
