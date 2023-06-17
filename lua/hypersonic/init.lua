local config = require('hypersonic.config')

---@return table
local function get_content()
    return {}
end

---@param content table
---@param opts table
local function create_window(content, opts)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local width = 40
    local height = #content + 2

    local win_top = math.max(1, row - math.floor(height / 2))
    local win_left = math.max(0, col - math.floor(width / 2))

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, content)

    local win = vim.api.nvim_open_win(buf, true, {
            relative = "cursor",
            row = win_top,
            col = win_left,
            width = width,
            height = height,
            style = "minimal",
            border = opts.border,
            title = 'TITLE',
            title_pos = 'center',
            focusable = true
        })

    vim.api.nvim_set_current_win(win)
end

local function setup(opts)
    opts = opts or config

    local content = {'Testing str'}
    create_window(content, opts)
end

return {
    setup = setup
}
