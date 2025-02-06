local keyMapper = function(form, to, mode, opts)
    local options = { noremap = true, silent = true }
    mode = mode or "n"

    if opts then
        options = vim.tbl_extend("force", options, opts)
    end

    vim.keymap.set(mode, form, to, options)
end

return { mapKey = keyMapper }