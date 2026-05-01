<LeftMouse>-- 行番号を表示
vim.opt.number = true
-- カーソルのある行を強調
vim.opt.cursorline = true
-- タブ幅の設定
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
-- クリップボードをシステムと共有
vim.opt.clipboard = "unnamedplus"
-- 色付けを有効にする
vim.cmd("syntax on")
-- 24bitカラーを有効にする（WezTermなら必須！）
vim.opt.termguicolors = truei
