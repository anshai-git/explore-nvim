local UV = vim.loop

P = function(v)
  print(vim.inspect(v))
end

local M = {
  files_list = {},
}

function M.table_to_string(tbl)
    local result = "{"
    local isFirst = true

    for k, v in pairs(tbl) do
        if not isFirst then
            result = result .. ", "
        end
        if type(k) == "string" then
            result = result .. '"' .. k .. '": '
        else
            result = result .. "[" .. tostring(k) .. "]: "
        end
        if type(v) == "table" then
            result = result .. M.table_to_string(v)
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '"'
        else
            result = result .. tostring(v)
        end
        isFirst = false
    end

    result = result .. "}"
    return result
end

function M.dict_to_multiline_string(dict)
    local str = ""
    for key, value in pairs(dict) do
        str = str .. key .. ": " .. ""
    end
    return str
end

-- Function to create a scratch buffer
function M.create_scratch_buffer()
  -- Create a new scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set options for the scratch buffer
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'lua')

  -- Return the buffer number
  return buf
end

-- Function to print text to the scratch buffer
function M.print_to_scratch_buffer(text)
  -- Get the current buffer
  local buf = vim.api.nvim_get_current_buf()

  -- Append text to the scratch buffer
    for index, value in pairs(text) do
        vim.api.nvim_buf_set_lines(buf, index, index, true, {index .. ": " .. M.table_to_string(value)})
    end
end

function M.ls()
  -- Get the current directory path
  local cwd = vim.fn.expand('%:p:h')

  -- Current Working Directiry as uv.dir
  local uv_cwd = UV.fs_opendir(cwd, nil);

  local files_list = UV.fs_readdir(uv_cwd, nil);

  print("Files in directory:")
  -- Create a scratch buffer
  local scratch_buf = M.create_scratch_buffer()

  -- Print some text to the scratch buffer
  -- local printable = M.dict_to_multiline_string(files_list)

  -- Open the scratch buffer in a vertical split at the bottom
  vim.api.nvim_command("vsplit")
  vim.api.nvim_command("wincmd J")
  vim.api.nvim_command("buffer " .. scratch_buf)

  M.print_to_scratch_buffer(files_list)

end

function M.setup(opts)
  -- Set options here
  opts = opts or {}

  vim.keymap.set("n", "<Leader>e", function()
    M.ls()
  end)
end

return M


