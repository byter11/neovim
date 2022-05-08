local uv = vim.loop
local a = vim.api

a.nvim_create_user_command('Smartclosetab',
  function()
    local cur = a.nvim_get_current_buf()
    print(cur)
    vim.cmd('bp')
    vim.cmd(string.format('bd %d', cur))
  end,
  { nargs = 0 }
)

a.nvim_create_user_command('Compe',
  function(opts)
    local dir = opts.args

    -- Check if directory exists
    local stat = uv.fs_statfs(dir)

    -- Else create
    if not stat then
      local ok = uv.fs_mkdir(dir, 493)
      if not ok then
        a.nvim_err_writeln("Couldn't create directory " .. dir)
        return
      end
    end

    for _, file in pairs({'solve.cpp', 'in', 'out'}) do
      local path = string.format('%s/%s', dir, file)
      local _, err = uv.fs_stat(path)
      if err then
        local fd = uv.fs_open(path, "w", 438)
        if not fd then
          a.nvim_err_writeln("Couldn't create file " .. file)
          return
        end
        uv.fs_close(fd)
      end
    end

    a.nvim_command('NvimTreeRefresh')
    a.nvim_command('NvimTreeClose')
    a.nvim_command('only')
    a.nvim_command(string.format('edit %s/solve.cpp', dir))
    a.nvim_command(string.format('vsplit %s/in', dir))
    a.nvim_command(string.format('split %s/out', dir))

    local window = a.nvim_list_wins()[1]
    a.nvim_set_current_win(window)

  end,
  { nargs = 1 }
)
