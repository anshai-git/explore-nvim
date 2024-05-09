# Neovim plugin development

## listdir function from oil.nvim
```rust

M.listdir = function(dir, cb)
  ---@diagnostic disable-next-line: param-type-mismatch

  uv.fs_opendir(dir, function(open_err, fd)

    if open_err then
      return cb(open_err)
    end

    local read_next

    read_next = function()
      uv.fs_readdir(fd, function(err, entries)
        if err then
          uv.fs_closedir(fd, function()
            cb(err)
          end)
          return
        elseif entries then
          ---@diagnostic disable-next-line: param-type-mismatch
          cb(nil, entries)
          read_next()
        else
          uv.fs_closedir(fd, function(close_err)
            if close_err then
              cb(close_err)
            else
              cb()
            end
          end)
        end
      end)
    end
    read_next()
    ---@diagnostic disable-next-line: param-type-mismatch
  end, 10000)
end

```
