local M = {}

-- Helper function to create a directory if it doesn't exist
local function mkdir_if_not_exist(dir)
  local exists = vim.fn.isdirectory(dir)
  if exists == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

local function is_something_shown()
  -- Credits: https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/sessions.lua
  -- Don't autoread session if Neovim is opened to show something. That is
  -- when at least one of the following is true:
  -- - Current buffer has any lines (something opened explicitly).
  -- NOTE: Usage of `line2byte(line('$') + 1) > 0` seemed to be fine, but it
  -- doesn't work if some automated changed was made to buffer while leaving it
  -- empty (returns 2 instead of -1). This was also the reason of not being
  -- able to test with child Neovim process from 'tests/helpers'.
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then return true end

  -- - Several buffers are listed (like session with placeholder buffers). That
  --   means unlisted buffers (like from `nvim-tree`) don't affect decision.
  local listed_buffers = vim.tbl_filter(
    function(buf_id) return vim.fn.buflisted(buf_id) == 1 end,
    vim.api.nvim_list_bufs()
  )
  if #listed_buffers > 1 then return true end

  -- - There are files in arguments (like `nvim foo.txt` with new file).
  if vim.fn.argc() > 0 then return true end

  return false
end

-- Function to update session
function M.save_session()
  local session_dir = vim.fn.getcwd() .. "/.vim/sessions/"
  local session_file = session_dir .. "session.vim"

  if vim.fn.isdirectory(session_dir) == 1 then
    vim.cmd("mksession! " .. session_file)
  else
    local choice = vim.fn.input("Session does not exist. Do you want to create a new one? (y/N): ")
    if choice:lower() == 'y' then
      mkdir_if_not_exist(session_dir)
      vim.cmd("mksession! " .. session_file)
    else
      print("Session not saved.")
    end
  end
end

-- Function to manually load session
function M.load_session()
  local session_dir = vim.fn.getcwd() .. "/.vim/sessions/"
  local session_file = session_dir .. "session.vim"

  if vim.fn.filereadable(session_file) == 1 then
    -- Delay session loading by 250ms to ensure all initializations are done
    vim.defer_fn(function()
      vim.cmd("source " .. session_file)
    end, 250)
  else
    local choice = vim.fn.input("Session does not exist. Do you want to create a new one? (y/N): ")
    if choice:lower() == 'y' then
      mkdir_if_not_exist(session_dir)
      vim.cmd("mksession! " .. session_file)
    else
      print("Session not loaded.")
    end
  end
end

-- Function to manually create a new session
function M.create_session()
  M.save_session()
end

-- Setup function to bind autocommands
function M.setup()
  local session_manager_group = vim.api.nvim_create_augroup('SimpleSessionManagerGroup', { clear = true })
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      if is_something_shown() then return end
      if vim.fn.isdirectory(vim.fn.getcwd() .. "/.vim/sessions/"
          ) == 1 then
        M.load_session()
      end
    end,
    group = session_manager_group,
    pattern = '*',
  })

  vim.api.nvim_create_autocmd('VimLeave', {
    callback = function()
      if vim.v.this_session == '' then return end
      if vim.fn.isdirectory(vim.fn.getcwd() .. "/.vim/sessions/"
          ) == 1 then
        M.save_session()
      end
    end,
    group = session_manager_group,
    pattern = '*',
  })

  -- Bind commands for manual operation
  vim.api.nvim_create_user_command('SaveSession', function(_)
    M.save_session()
  end, {})

  vim.api.nvim_create_user_command('LoadSession', function(_)
    M.load_session()
  end, {})

  vim.api.nvim_create_user_command('CreateSession', function(_)
    M.create_session()
  end, {})
end

return M
