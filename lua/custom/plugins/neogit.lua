return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('neogit').setup {
      integrations = {
        diffview = true,
        telescope = true,
      },
    }

    vim.keymap.set('n', '<leader>gg', '<cmd>Neogit<CR>', { desc = 'Open Neo[g]it' })
  end,
}
