return {
   'nvim-telescope/telescope.nvim', tag = '0.1.8',
   dependencies = { 'nvim-lua/plenary.nvim' },
   opts = {
     defaults = {
       -- always show hidden files
       file_ignore_patterns = { ".git/" }, -- keep ignoring .git folder
     },
     pickers = {
       find_files = {
         hidden = true,
       },
     },
   },
}

