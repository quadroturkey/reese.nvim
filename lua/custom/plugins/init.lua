-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local function find_and_replace()
  -- Prompt for the old pattern
  vim.ui.input({ prompt = 'Old pattern: ' }, function(old_pattern)
    if not old_pattern or old_pattern == '' then
      print 'Cancelled'
      return
    end

    -- Prompt for the new pattern
    vim.ui.input({ prompt = 'New pattern: ' }, function(new_pattern)
      if not new_pattern or new_pattern == '' then
        print 'Cancelled'
        return
      end

      vim.ui.input({ prompt = 'Case Sensative? (Y)es / (N)o ' }, function(case_sensitive)
        if case_sensitive == 'y' or case_sensitive == 'Y' then
          Case_flag = 'I'
        else
          Case_flag = ''
        end

        -- Escape forward slashes in patterns
        Safe_old = old_pattern:gsub('/', '\\/')
        Safe_new = new_pattern:gsub('/', '\\/')
      end)

      -- Apply the substitution to all files in the quickfix list
      vim.cmd('cfdo %s/' .. Safe_old .. '/' .. Safe_new .. '/gc' .. Case_flag .. ' | update')
    end)
  end)
end

-- Custom function to add selections to the quickfix list
local function add_to_qflist_from_picker(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  if not picker then
    vim.notify('No active Telescope picker found!', vim.log.levels.ERROR)
    return
  end

  -- Add selected entries to the quickfix list
  actions.smart_send_to_qflist(prompt_bufnr)
  -- Open the quickfix list
  vim.cmd 'copen'
end

-- Keymap to trigger the function
vim.keymap.set('n', '<C-g>', function()
  local prompt_bufnr = vim.api.nvim_get_current_buf()
  add_to_qflist_from_picker(prompt_bufnr)
end, {
  desc = 'Add selections to Quickfix list',
})

-- Keymap for insert mode (optional)
vim.keymap.set('i', '<C-g>', function()
  local prompt_bufnr = vim.api.nvim_get_current_buf()
  add_to_qflist_from_picker(prompt_bufnr)
end, {
  desc = 'Add selections to Quickfix list and open it',
})
--
-- Keybinding to trigger the find_and_replace function
vim.keymap.set('n', '<leader>fr', find_and_replace, { desc = 'Find and Replace in Quickfix List' })

-- Somewhere in your Neovim config (e.g., after plugin setup)
_G.custom_search_dirs = { vim.loop.cwd() } -- default to current working directory

function _G.update_custom_search_dirs()
  vim.ui.input({ prompt = 'Enter directory to search (comma-separated for multiple): ' }, function(input)
    if input ~= nil and input ~= '' then
      local dirs = {}
      for dir in string.gmatch(input, '([^,]+)') do
        table.insert(dirs, vim.fn.expand(dir:gsub('^%s*(.-)%s*$', '%1'))) -- trim and expand ~
      end
      _G.custom_search_dirs = dirs
      print 'Search dirs updated:'
      vim.print(_G.custom_search_dirs)
    else
      _G.custom_search_dirs = { vim.loop.cwd() } -- default to current working directory
      print 'No input. Dirs reset to cwd'
    end
  end)
end

local builtin = require 'telescope.builtin'

vim.keymap.set('n', '<leader>sf', function()
  builtin.find_files { search_dirs = _G.custom_search_dirs }
end, { desc = '[S]earch [F]iles in custom dirs' })

vim.keymap.set('n', '<leader>sg', function()
  builtin.live_grep { search_dirs = _G.custom_search_dirs }
end, { desc = '[S]earch by [G]rep in custom dirs' })

vim.keymap.set('n', '<leader>cd', _G.update_custom_search_dirs, { desc = '[S]earch [D]irs: set custom search dirs' })

return {}
