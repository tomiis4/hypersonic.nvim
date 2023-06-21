vim.api.nvim_create_user_command(
    'Hypersonic',
    require('hypersonic').explain,
    { range = true, nargs='?' }
)
