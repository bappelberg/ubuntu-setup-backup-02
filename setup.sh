#!/bin/bash

start_time=$(date +%s)

# Exit on error
set -e

# Set debug
set -x


# Update the package list
echo "Updating package list..."
sudo apt update -y

# Upgrade existing packages
echo "Upgrading existing packages..."
sudo apt upgrade -y

echo "Installing git"
sudo apt install git -y

echo "Setting up git name and email"
git config --global user.name "bappelberg"
git config --global user.email "benjamin.w.appelberg@gmail.com"


echo "Installing OpenSSH-server"
sudo apt install openssh-server -y

echo "Installing OpenSSH-client"
sudo apt install openssh-client -y

if [[ -d ~/.ssh ]]; then
    echo "Removing ~/.ssh directory"
    sudo rm -rf ~/.ssh
fi

echo "Creating ~/.ssh directory and configure correct permissions"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "Generating ssh key-value pair"
ssh-keygen -t ed25519 -C "benjamin.w.appelberg@gmail.com" -f ~/.ssh/id_ed25519 -N ""

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub
echo "go to https://github.com/settings/keys and add your ./~/.ssh/id_ed25519.pub SSH key" 

echo "Installing cURL"
sudo apt install curl -y

echo "Installing neovim"
if [[ -d /opt/nvim-linux64 ]]; then
    sudo rm -rf /opt/nvim-linux64
fi

echo "Attempting to cURL latest neovim"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo tar -C /opt -xzf nvim-linux64.tar.gz
sudo rm nvim-linux64.tar.gz


echo "Installing build-essential"
sudo apt install -y build-essential


if [[ -d /usr/local/go ]]; then
    sudo rm -rf /usr/local/go 
fi

curl -LO https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
sudo rm go1.22.5.linux-amd64.tar.gz

echo "Installing JetBrains Mono font"
sudo rm -rf ~/.local/share/fonts
mkdir -p ~/.local/share/fonts
rsync -av ./fonts/JetBrainsMonoNerdFont ~/.local/share/fonts/

fc-cache -fv

echo "Installing lazy"

rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim

mkdir -p ~/.config/nvim/lua/config
mkdir -p ~/.config/nvim/lua/plugins

echo 'require("config.lazy")
-- Set up tabs and spaces
vim.opt.expandtab = true  -- Use spaces instead of tabs
vim.opt.shiftwidth = 4    -- Number of spaces to use for indentation
vim.opt.tabstop = 4       -- Number of spaces a tab counts for
vim.opt.softtabstop = 4   -- Number of spaces for editing

-- Other useful settings for code style
vim.opt.autoindent = true -- Copy indent from current line when starting a new line
vim.opt.smartindent = true -- Smart autoindenting for code
' > ~/.config/nvim/init.lua


echo '-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.editor.telescope" },
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})' > ~/.config/nvim/lua/config/lazy.lua

echo 'return {
  -- add symbols-outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    opts = {
      -- add your options that should be passed to the setup() function here
      position = "right",
    },
  },
}' > ~/.config/nvim/lua/plugins/lsp.lua

if [[ -f ~/.bashrc ]]; then
    rm ~/.bashrc
    cp /etc/skel/.bashrc ~/.bashrc
fi


echo "# ==== ==== ==== ==== My settings ==== ==== ==== ====" >> ~/.bashrc
echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
echo 'export PATH="$PATH:/usr/local/go/bin"' >> ~/.bashrc
echo "Setting up alias" 

echo 'alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."' >> ~/.bashrc

echo "Cleaning system"
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean -y


source ~/.bashrc

end_time=$(date +%s)

elapsed_time=$((end_time - start_time))
echo "Setup is done. Elapsed time: $elapsed_time seconds"


