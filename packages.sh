# TODO install yay

pacman -Sy archlinux-keyring && pacman -Su

pacman -S git firefox htop ranger tree thunar rofi zathura zathura-pdf-mupdf  \
    xorg-xmodmap xorg-xbacklight python-pipx unzip lxappearance-gtk3 sysstat \
    ueberzug unclutter xorg xorg-xinit openssh ttf-fira-code bc libinput openssh \
    base-devel alsa-utils pulseaudio acpilight xf86-input-synaptics ripgrep neovim \
    acpi npm gopls xclip

echo ".cfg" > /mnt/home/kro/.gitignore
git clone --bare git@github.com:keithroger/dotfiles.git $HOME/.cfg
config config --local status.showUntrackedFiles no

cp /home/kro/.config/X11/xorg.conf.d/30-touchpad.conf

git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

npm i -g bash-language-server
