pacstrap /mnt git firefox htop ranger tree thunar rofi zathura zathura-pdf-mupdf  \
    xorg-xmodmap xorg-xbacklight python-pipx unzip lxappearance-gtk3 sysstat \
    ueberzug unclutter xorg xorg-xinit openssh ttf-fira-code bc libinput openssh \
    base-devel alsa-utils pulseaudio acpilight xf86-input-synaptics ripgrep neovim

echo ".cfg" > /mnt/home/kro/.gitignore
arch-chroot /mnt git clone --bare git@github.com:keithroger/dotfiles.git $HOME/.cfg

arch-chroot /mnt cp /home/kro/.config/X11/xorg.conf.d/30-touchpad.conf
