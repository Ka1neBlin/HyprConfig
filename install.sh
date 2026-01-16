cp -r {hypr,kitty,mako,nvim,rofi,waybar} ~/.config
cp -r simple-sddm /usr/share/sddm/themes
cp .zshrc ~
mkdir -p ~/Pictures/Background
cp background.png ~/Pictures/Background

sudo pacman -S mako neovim rofi waybar swaybg amberol nautilus hyprshot obsidian
