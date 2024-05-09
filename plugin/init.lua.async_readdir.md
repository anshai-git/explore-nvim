local UV = vim.uv

local P = function(it)
  print(vim.inspect(it))
end

local defer = function(cb)
  vim.schedule(cb())
end

function nexplore()
  local current_path = vim.fn.getcwd()

  vim.api.nvim_command('botright new')
  local buffer_id = vim.fn.bufnr()

  vim.api.nvim_buf_set_option(buffer_id, 'buftype', 'nofile')
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
            vim.schedule(function ()
              vim.api.nvim_buf_set_lines(buffer_id, index, -1, false, {entry.type .. " :: " .. entry.name})
            end)
          end
          read(index + 1)
        else
          UV.fs_closedir(dir)
        end
      end)
    end
    read(0)
  end)
end

vim.keymap.set('n', '<leader>n', "<CMD>lua nexplore()<CR>")
