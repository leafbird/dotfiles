local mapkey = require("utils.keyMapper").mapKey

-- Neotree toggle
mapkey("<leader>e", ":Neotree toggle<CR>")

-- pane navigation
mapkey("<C-h>", "<C-w>h") -- move to the pane on the left
mapkey("<C-j>", "<C-w>j") -- move to the pane below
mapkey("<C-k>", "<C-w>k") -- move to the pane above
mapkey("<C-l>", "<C-w>l") -- move to the pane on the right

-- clear search highlights
mapkey("<leader>h", ":nohlsearch<CR>")
