# for Neovim build
sudo apt-get install ninja-build gettext cmake unzip curl

# for Telescope.nvim functionality
sudo apt-get install ripgrep

# for building treesitter-yaml
sudo apt-get install g++

# for the tsserver lsp
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
    sudo apt-get install -y nodejs

