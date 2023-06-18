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

    api.nvim_buf_set_lines(buf, 0, -1, true, content)

    -- create window
    local win = api.nvim_open_win(buf, false, {
            relative = 'cursor',
            row = 1,
            col = 0,
            width = 45,
            height = 3,
            style = "minimal",
            border = opts.border,
            title = 'TESTOVÁNÍ',
            title_pos = 'center',
            focusable = true,
        })

    -- configure
    api.nvim_win_set_option(win, "winblend", opts.winblend)
    api.nvim_buf_set_name(buf, 'Hypersonic')
    api.nvim_buf_set_option(buf, 'modifiable', false)

    local group = 'hypersonic_window'
    local group_id = api.nvim_create_augroup(group, {})
    local old_cursor = api.nvim_win_get_cursor(0)

    -- close window when moved
    api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = group_id,
        callback = function()
            local cursor = api.nvim_win_get_cursor(0)
            if (old_cursor[1] ~= cursor[1] or old_cursor[2] ~= cursor[2]) then
                api.nvim_create_augroup(group, {})
                if api.nvim_win_is_valid(win) then
                    api.nvim_win_close(win, true)
                end
                if api.nvim_buf_is_valid(buf) then
                    api.nvim_buf_delete(buf, { force = true, unload = true })
                end
            end
            old_cursor = cursor
        end,
    })

    -- clear autogroup
    api.nvim_create_autocmd('WinClosed', {
        pattern = tostring(win),
        group = group_id,
        callback = function()
            api.nvim_create_augroup(group, {})

            if api.nvim_buf_is_valid(buf) then
                api.nvim_buf_delete(buf, { force = true, unload = true })
            end
        end,
    })
end

local function setup(opts)
    opts = opts or config

    local content = { 'Testování', 'testování floating okna' }
    create_window(content, opts)
end

return {
    setup = setup
}
