local M = {}
M.dir_items = {}

local UV = vim.uv

local P = function(it)
  print(vim.inspect(it))
end

local defer = function(cb)
  vim.schedule(cb())
end

on_key_pressed = function()
  print("SELECT")
end

print_current_line = function()
  local current_line = vim.fn.getline('.')
  local file_path = vim.fn.expand('%:p:h') .. '/' .. current_line
  vim.cmd('q')
  vim.cmd('wincmd p')
  vim.api.nvim_command('edit ' .. file_path)
end

function nexplore()
  local current_path = vim.fn.getcwd()

  vim.api.nvim_command('botright new | horizontal resize 10')

  local buffer_id = vim.fn.bufnr()

  vim.api.nvim_buf_set_option(buffer_id, 'buftype', 'nofile')
  vim.api.nvim_buf_set_keymap(buffer_id, 'n', '<CR>', '<CMD>lua print_current_line(vim.fn.bufnr("%"))<CR>',
    { noremap = true })
  vim.api.nvim_buf_set_keymap(buffer_id, 'n', '<Esc>', '<CMD>q<CR>', { noremap = true })
  vim.api.nvim_buf_set_lines(buffer_id, 0, -1, false, { "../" })

  UV.fs_opendir(current_path, function(opendir_err, dir)
    if opendir_err then
      print(opendir_err)
      return
    end

    local read
    read = function(index)
      UV.fs_readdir(dir, function(readdir_err, entries)
        if readdir_err then
          UV.fs_closedir(dir)
          return
        end
        if entries then
          for _, entry in ipairs(entries) do
            table.insert(M.dir_items, entry)
            vim.schedule(function()
              vim.api.nvim_buf_set_lines(buffer_id, index, -1, false, { entry.name })
            end)
          end
          read(index + 1)
        else
          UV.fs_closedir(dir)
          local print_val = ""
          for _, i in ipairs(M.dir_items) do
            for _, ii in pairs(i) do
              print_val = print_val .. " " .. ii
            end
          end
          P(print_val)
        end
      end)
    end
    read(1)
  end)

end


vim.keymap.set('n', '<leader>n', "<CMD>lua nexplore()<CR>")
