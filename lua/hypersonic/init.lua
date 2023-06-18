local config = require('hypersonic.config')
local api = vim.api

---@return table
local function get_content()
    return {}
end

---@param content table
---@param opts options
local function create_window(content, opts)
    local buf = vim.api.nvim_create_buf(false, true)

    -- configure buffer & set lines
    vim.bo[buf].modifiable = true
    api.nvim_buf_set_lines(buf, 0, -1, true, content)
    vim.bo[buf].modifiable = false

    api.nvim_buf_set_name(buf, 'test-name')

    -- create window
    api.nvim_open_win(buf, true, {
        relative = 'cursor',
        row = 1,
        col = 0,
        width = 12,
        height = 3,
        style = "minimal",
        border = opts.border,
        title = 'TITLE',
        title_pos = 'left',
        focusable = true,
    })

    -- close window
    api.nvim_buf_set_keymap(
        buf,
        'n',
        opts.close_window,
        ':lua vim.api.nvim_buf_delete(' .. buf .. ', {force=true, unload=false}) <CR>',
        { silent = true }
    )
end

local function setup(opts)
    opts = opts or config

    local content = { 'Testing str' }
    create_window(content, opts)
end

return {
    setup = setup
}
