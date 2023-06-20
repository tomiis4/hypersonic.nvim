local merge = require('hypersonic.merge').merge
local explain_regex = require('hypersonic.explain').explain
local split_regex = require('hypersonic.split').split_regex
local U = require('hypersonic.utils')

local config = require('hypersonic.config')
local api = vim.api
local ns = api.nvim_create_namespace('hypersonic')

---@class options
---@field border 'none'|'single'|'double'|'rounded'|'solid'|'shadow'
---@field winblend number 0-100
---@field add_padding boolean default true
---@field hl_group string default 'Keyword'

---@param opts options
---@return string|nil, table, table
local function get_regex_data(opts)
    local res = {}
    local highlights = {}

    -- get regex
    local char_start = vim.fn.getpos("'<")[3]
    local char_end = vim.fn.getpos("'>")[3]

    local line = vim.fn.getline('.')
    local input = line:sub(char_start, char_end)

    if input == '' then
        return nil, {}, {}
    end

    -- edit content
    local split_tbl = split_regex(input)
    local expl_tbl = explain_regex(split_tbl, {})
    local merged = merge(expl_tbl, { expl_tbl[1] }, false)

    -- format text to buffer format
    for m_idx = 2, #merged do
        local v = merged[m_idx]
        local longest_name = U.get_longest_name(merged)
        local padding = opts.add_padding == false and '' or (' '):rep(longest_name - #v[1])
        local name = '"' .. v[1] .. '": '

        table.insert(res, name .. padding .. v[2])
        table.insert(highlights, { #res - 1, #name })

        -- if it have another values stored in temp3
        if #v[3] > 0 then
            for t_idx, temp in pairs(v[3]) do
                local separated_txt = U.split(temp, '<br>')

                for sep_idx, sep in pairs(separated_txt) do
                    local sep_number = sep_idx == 1 and (' '):rep(3) .. t_idx .. ') '
                        or (' '):rep(3 + 3)

                    table.insert(res, sep_number .. sep)
                end
            end
        end
    end

    return merged[1][2], res, highlights
end

---@param title string
---@param content table
---@param opts options
---@param highlights table
local function create_window(title, content, opts, highlights)
    local buf = vim.api.nvim_create_buf(false, true)

    api.nvim_buf_set_lines(buf, 0, -1, true, content)

    -- add highlights
    for _, hl in ipairs(highlights) do
        local hl_group = opts.hl_group or config.hl_group
        api.nvim_buf_add_highlight(buf, ns, hl_group, hl[1], 0, hl[2])
    end

    -- create window
    local win = api.nvim_open_win(buf, false, {
            relative = 'cursor',
            row = 1,
            col = 0,
            width = U.get_longest(content) + 1,
            height = #content,
            style = "minimal",
            border = opts.border or config.border,
            title = title,
            title_pos = 'left',
            focusable = true,
        })

    -- configure
    api.nvim_win_set_option(win, "winblend", opts.winblend or config.winblend)
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

local cfg = {}

local function setup(opts)
    cfg = opts
end

local function explain()
    local title, content, highlights = get_regex_data(cfg)

    if title == nil then
        print('Please select correct RegExp')
        return
    end

    create_window(title, content, cfg, highlights)
end

return {
    setup = setup,
    explain = explain
}
