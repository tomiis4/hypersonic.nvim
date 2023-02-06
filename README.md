# Hypersonic.nvim
## (not ready to use, use `lua filename.lua` for testing)
A simple open-source plugin which help you with writing and testing Regex.

<hr>

### TODO
- [ ] Snippets
    - [ ] Email
    - [ ] Phone
    - [ ] URL
    - [ ] Password strength
- [ ] Live preview
    - [ ] Explain
        - [x] Split to one big table
            - [x] Groups
            - [x] Characters
            - [x] Lit. characters
            - [x] Class
            - [x] Anchors
        - [x] Explan class
        - [ ] Make functions which get what each special char. doing
            - [ ] ^ | . $ 
        - [ ] Functions which get what group is doing
        - [ ] Put explanation in one big table (prob. 2D)
        - [ ] From 2D return 1D

- [ ]  Autocomplete?

<hr>

### Explaining
#### <b> Live preview</b>
- Split regex to groups
    - `\` - literal characters
    - `x` - characters
    - `()` - groups
    - `[]` - character class
    - `^` - Anchors
- Put it in one multi-dimensional table
- Recursively loop through table
- Explant one selection and put explanation in multi-dimensional table
- Loop trough explanation table and display it.

### File order
```
|   README.md
|   LICENSE
|
+---lua
|   \---hypersonic
|           explain.lua
|           init.lua
|           split.lua
|
+---plugin
|       hypersonic.vim
|
\---test
        test.txt
```

<hr>

### Contributors
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
