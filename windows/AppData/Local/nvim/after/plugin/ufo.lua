vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
require("ufo").setup({
    keys = {
        { "zR", function() require("ufo").openAllFolds() end },
        { "zM", function() require("ufo").closeAllFolds() end },
        { "K", function()
                   local winid = require('ufo').peekFoldedLinesUnderCursor()
                   if not winid then
                   vim.lsp.buf.hover()
                   end
               end 
            }
    },
	close_fold_kinds = { "imports" },
})