local UV = vim.loop

local M = {
  files_list = {},
}

function M.ls()
  -- Get the current directory path
  local cwd = vim.fn.expand('%:p:h')

  local files_list = UV.fs_readdir(cwd, nil);

  print("Files in directory:")
  print(files_list);

  -- for _, file in ipairs(files_list) do
  --   print(file)
  -- end
end

function M.setup(opts)
  -- Set options here
  opts = opts or {}

  vim.keymap.set("n", "<Leader>e", function()
    M.ls()
  end)
end

return M
