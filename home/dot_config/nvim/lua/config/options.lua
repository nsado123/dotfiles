---- localization ----
local o = vim.opt
local a = vim.api
local k = vim.keymap.set

---- options ----
o.number = true

o.title = true

o.autoindent = true
o.smartindent = true

o.hlsearch = true

o.expandtab = true
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.smarttab = true

o.scrolloff = 10

o.shell = "fish"

o.backupskip = { "/tmp/*", "/private/tmp/*" }

o.inccommand = "split"

o.ignorecase = true
o.smartcase = true

o.wrap = false

o.backspace = { "start", "eol", "indent" }

o.path:append({ "**" })

o.encoding = "utf-8"
o.fileencoding = "utf-8"

o.wildignore:append({ "*/node_modules/*" })

o.splitbelow = true 
o.splitright = true 

o.splitkeep = "cursor"
o.mouse = ""

o.clipboard = "unnamedplus"

o.termguicolors = true

---- commands ----
a.nvim_create_user_command("Q", "q!", {})
a.nvim_create_user_command("W", "wq", {})

---- keybinds ----
k('n', '<Tab>', ':tabnext<CR>', { silent = true })
k('n', '<S-Tab>', ':tabprevious<CR>', { silent = true })
k('n', '<A-h>', '<C-w>h', { silent = true })
k('n', '<A-j>', '<C-w>j', { silent = true })
k('n', '<A-k>', '<C-w>k', { silent = true })
k('n', '<A-l>', '<C-w>l', { silent = true })
k('n', 'ss', ':vsplit<Return>', { silent = true })
k('n', 'sh', ':split<Return>', { silent = true })
