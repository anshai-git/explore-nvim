local UV = vim.uv
local P = function(it)
  print(vim.inspect(it))
end

local M = {}
M._dir_items = {}
M._buf_id = -1
M._path = ''


-- Read the directory under @path and for each item in the directory
-- append a line (containing the items name) to the buffer under @buf_id
local read_dir = function(path, buf_id)
  M._dir_items = {}

  local read
  read = function(dir, index)
    UV.fs_readdir(dir, function(readdir_err, entries)
      if readdir_err then
        UV.fs_closedir(dir)
        return
      end
      if entries then
        for _, entry in ipairs(entries) do
          table.insert(M._dir_items, entry)
          local entry_path = M._path .. "/" .. entry.name
          vim.schedule(function()
            local permissions = vim.fn.getfperm(entry_path)
            local owner = string.gsub(vim.fn.system("stat -c '%U' " .. entry_path), '\n', '')
            local size = string.format("%-4s", vim.fn.getfsize(entry_path))
            local time = vim.fn.strftime("%b %d %H:%M", vim.fn.getftime(entry_path))
            vim.api.nvim_buf_set_lines(buf_id, index, -1, false, { permissions .. " " .. owner .. " " .. size .. " ".. time .. " " .. entry.name })
          end)
        end
        read(dir, index + 1)
      else
        UV.fs_closedir(dir)
        local print_val = ""
        for _, i in ipairs(M._dir_items) do
          for _, ii in pairs(i) do
            print_val = print_val .. " " .. ii
          end
        end
      end
    end)
  end

  UV.fs_opendir(path, function(opendir_err, dir)
    if opendir_err then
      print(opendir_err)
      return
    end
    read(dir, 1)
  end)
end

function select_item()
  local current_line = vim.fn.getline('.')
  if (current_line == "../") then
    M._path = vim.fn.fnamemodify(M._path, ':h')
    read_dir(M._path, M._buf_id)
  else
    local file_path = M._path .. '/' .. current_line
    local file_type = vim.fn.getftype(file_path)
    if (file_type == 'dir') then
      M._path = file_path
      read_dir(M._path, M._buf_id)
    end
    if (file_type == 'file') then
      -- local permissions = vim.fn.getfperm(file_path)
      -- P(permissions)
      vim.cmd([[
        q
        wincmd p
      ]])
      vim.api.nvim_command('edit ' .. file_path)
    end
  end
end

function nexplore()
  if (M._path == '') then
    M._path = vim.fn.getcwd()
  end

  vim.api.nvim_command('botright new | horizontal resize 10')
  M._buf_id = vim.fn.bufnr()

  vim.api.nvim_buf_set_option(M._buf_id, 'buftype', 'nofile')
  vim.api.nvim_buf_set_keymap(M._buf_id, 'n', '<CR>', '<CMD>lua select_item()<CR>', { noremap = true })
  vim.api.nvim_buf_set_keymap(M._buf_id, 'n', '<Esc>', '<CMD>q<CR>', { noremap = true })
  vim.api.nvim_buf_set_keymap(M._buf_id, 'n', '<leader>t', '<CMD>echo "test" <CR>', { noremap = true })
  vim.api.nvim_buf_set_lines(M._buf_id, 0, -1, false, { "../" })

  read_dir(M._path, M._buf_id)
  -- P(M)
end

vim.keymap.set('n', '<leader>n', "<CMD>lua nexplore()<CR>")
