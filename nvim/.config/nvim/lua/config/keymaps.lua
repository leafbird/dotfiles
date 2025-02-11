local mapKey = require("utils.keyMapper").mapKey

-- Neotree toggle
mapKey("<leader>e", ":Neotree toggle<CR>")

-- pane navigation
mapKey("<C-h>", "<C-w>h") -- move to the pane on the left
mapKey("<C-j>", "<C-w>j") -- move to the pane below
mapKey("<C-k>", "<C-w>k") -- move to the pane above
mapKey("<C-l>", "<C-w>l") -- move to the pane on the right

-- clear search highlights
mapKey("<leader>h", ":nohlsearch<CR>")

-- indent
mapKey('<', '<gv', 'v')
mapKey('>', '>gv', 'v')
