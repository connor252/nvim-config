-- ====== 基本設定 ======
vim.g.mapleader = " "          -- <Leader> をスペースに
vim.opt.number = true          -- 行番号表示
vim.opt.relativenumber = false -- 相対行番号
vim.opt.termguicolors = true   -- GUIカラーON
vim.opt.clipboard = "unnamedplus" -- y で外部にコピペ

vim.cmd("colorscheme default")   -- ← 全体の色を戻す

-- ====== Lazy.nvim セットアップ ======
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ====== プラグイン読み込み ======
require("lazy").setup({

  -- 1) ディレクトリ表示（ファイルツリー）
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
    end,
  },

  -- 2) 補完（バッファ＋パス）
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"]   = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"]    = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- 3) タブバー（複数ファイルをタブ表示）
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          always_show_bufferline = true,
          separator_style = "none",
          indicator = {
            style = "none",
          },
          show_buffer_close_icons = false,
          show_close_icon = false,
          show_tab_indicators = false,
          modified_icon = "",
          buffer_close_icon = "",
          close_icon = "",
        },
        highlights = {
          buffer_selected = {
            fg = "#ff79c6",
            bold = true,
            underline = true,
          },
        },
      })

      vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { silent = true })
      vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { silent = true })
    end,
  },

  -- 4) Markdown をいい感じに表示する（:Glow）
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    config = true,
  },

  -- 5) ターミナル管理（toggleterm）★ ここが追加された
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<leader>t]], -- Space + t で開閉
        direction = "tab",            -- タブで開く
        persist_mode = true,
        persist_size = true,
        close_on_exit = true,
      })
    end,
  },

})
-- ====== キーマップ ======


-- ====== :Gpaste – クリップボードをMarkdownタブとして開く ======

local function google_ai_paste()
  local text = vim.fn.getreg("+")  -- システムクリップボード
  if text == nil or text == "" then
    print("クリップボードが空です")
    return
  end

  vim.cmd("tabnew")          -- 新しいタブを開く

  local lines = vim.split(text, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd("setfiletype markdown")
  vim.cmd("syntax enable")
  vim.cmd("syntax on")
end

vim.api.nvim_create_user_command("Gpaste", google_ai_paste, {})
vim.keymap.set("n", "<leader>gp", google_ai_paste, { silent = true, desc = "Clipboard -> Markdown tab" })
