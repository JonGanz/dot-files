#! /bin/bash
mkdir -p "$HOME/.fonts"
wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip" -P ./
unzip ./JetBrainsMono.zip -d "$HOME/.fonts"
rm ./JetBrainsMono.zip
fc-cache -fv

