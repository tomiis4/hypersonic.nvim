---@class Options
---@field border 'none'|'single'|'double'|'rounded'|'solid'|'shadow'
---@field winblend number 0-100
---@field add_padding boolean default true
---@field hl_group string default 'Keyword'
---@field wrapping string default "
---@field enable_cmdline boolean default true

---@class HighlightData
---@field[1] string line
---@field[2] string max_range
---@alias Highlights HighlightData[]

local Merge = require('hypersonic.merge').merge
local Explain = require('hypersonic.explain').explain
local Split = require('hypersonic.split').split_regex
local U = require('hypersonic.utils')
local M = {}

---@type Options
local cfg = require('hypersonic.config')

---@type number|nil
local active_window = nil
---@type number|nil
local active_buffer = nil

local api = vim.api
local namespace = api.nvim_create_namespace('hypersonic')


---@return string|nil
local function get_selected()
    local char_start = vim.fn.getpos("'<")[3]
    local char_end = vim.fn.getpos("'>")[3]

    local line = vim.fn.getline('.')
    local input = line:sub(char_start, char_end)

    if input == '' then
        return nil
    end

    return input
end

---@param regex string
---@return table, Highlights
local function get_informations(regex)
    local formatted = {}
    ---@type Highlights
    local highlight = {}

    local split_tbl = Split(regex)
    local expl_tbl = Explain(split_tbl, {})
    local merged = Merge(expl_tbl, {}, false)

    -- format 3-dimension table to 1-dimension
    for _, merged_v in pairs(merged) do
        local calc_padd = U.get_longest_key(merged) - #merged_v[1]
        local padding = cfg.add_padding and (' '):rep(calc_padd) or ''
        local wrapping = cfg.wrapping

        local key = U.wrap(merged_v[1], wrapping) .. ': ' .. padding

        table.insert(formatted, key .. merged_v[2])
        table.insert(highlight, { #formatted - 1, #key })

        -- if it have another values stored in temp3
        for temp_i, temp_v in pairs(merged_v[3]) do
            local separated = U.split(temp_v, '<br>')

            for sep_i, sep in pairs(separated) do
                -- if is it first element, add number else does not add it
                local sep_number = sep_i == 1 and (' '):rep(3) .. temp_i .. ') '
                    or (' '):rep(3 + 3)

                table.insert(formatted, sep_number .. sep)
            end
        end
    end

    return formatted, highlight
end

local function delete_window()
    if active_window and api.nvim_win_is_valid(active_window) then
        api.nvim_win_close(active_window, true)
        active_window = nil
    end

    if active_buffer and api.nvim_buf_is_valid(active_buffer) then
        api.nvim_buf_delete(active_buffer, { force = true })
        active_buffer = nil
    end
end

---@param title string
---@param content table<string>
---@param highlights Highlights
---@param position 'cursor'|'editor'
local function display_window(title, content, highlights, position)
    delete_window()


    -- setup buffer
    local buf = api.nvim_create_buf(false, true)
    active_buffer = buf
    api.nvim_buf_set_lines(buf, 0, -1, true, content)


    -- add highlights
    for _, hl in ipairs(highlights) do
        local hl_group = cfg.hl_group
        api.nvim_buf_add_highlight(buf, namespace, hl_group, hl[1], 0, hl[2])
    end


    -- create window
    local width = U.get_longest(content) + 1
    local height = #content
    local win_opts = {
        relative = position,
        width = width,
        height = height,
        row = position == 'cursor' and 1 or math.floor(((vim.o.lines - height) / 2)),
        col = position == 'cursor' and 0 or math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = cfg.border,
        title = title,
        title_pos = 'left',
        focusable = false,
    }
    local win = api.nvim_open_win(buf, false, win_opts)
    active_window = win


    -- configure window
    api.nvim_win_set_option(win, "winblend", cfg.winblend)
    api.nvim_buf_set_name(buf, 'Hypersonic')
    api.nvim_buf_set_option(buf, 'modifiable', false)
    api.nvim_buf_set_option(buf, 'buflisted', false)


    -- autocommands for exiting window
    local old_cursor = api.nvim_win_get_cursor(0)
    api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        callback = function()
            local cursor = api.nvim_win_get_cursor(0)
            local char_start = vim.fn.getpos("'<")[3]

            -- cursor moved, not including when Insert mode to Normal
            if old_cursor[1] ~= cursor[1] or (old_cursor[2] ~= cursor[2] and char_start == cursor[2]) then
                delete_window()
            end
            old_cursor = cursor
        end
    })

    api.nvim_create_autocmd({ 'WinScrolled' }, {
        callback = function()
            delete_window()
        end
    })
end


---@param opts table
function M.setup(opts)
    for k, v in pairs(opts) do
        cfg[k] = v
    end

    if cfg.enable_cmdline then
        api.nvim_create_autocmd('CmdlineChanged', {
            callback = function()
                local cmdline = vim.fn.getcmdline()
                local cmdtype = vim.fn.getcmdtype()

                if cmdtype == '/' or cmdtype == '?' then
                    -- stimulating params
                    M.explain({ fargs = { cmdline } })
                end
            end
        })

        api.nvim_create_autocmd('CmdlineLeave', {
            callback = function()
                delete_window()
            end
        })
    end
end

---@param param table
function M.explain(param)
    local regex_title = param.fargs[1] or get_selected()
    if regex_title == nil then
        vim.print('Please select correct RegExp')
        return
    end

    local content, highlights = get_informations(regex_title)
    local position = param.fargs[1] and 'editor' or 'cursor'

    display_window(regex_title, content, highlights, position)
end

return M
