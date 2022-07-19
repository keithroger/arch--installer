#!/user/bin/env

# TODO use sed to change echo commands to colored output

# TODO use the arch-chroot one line implimentation
# TODO put chroot items all in one script

PURP='\033[0;35m'
ENDCOLOR='\033[0m'

DISK="/dev/nvme0n1"
EFI="/dev/nvme0n1p1"
LFS="/dev/nvme0n1p2"
microcode="intel-ucode"

function output { echo -e "${PURP}$1${ENDCOLOR}";}

output "Starting Arch Linux install."

output "Enter a hostname: "
read -r hostname

output "Enter a username: "
read -r username

output "Enter a password: "
read -r -s password

echo "Partitioning $DISK."
parted -s "$DISK" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    mkpart LFS ext4 513MiB 100% \
    set 1 esp on

echo "Updating kernel with changes."
partprobe "$DISK"

echo "Partitions created:"
lsblk

echo "Formating partitions"
mkfs.fat -F 32 "$EFI"
mkfs.ext4 "$LFS"
mount "$LFS" /mnt

echo "Installing packages"
pacstrap /mnt base linux linux-headers $microcode linux-firmware grub \
    efibootmgr kitty networkmanager dosfstools os-prober mtools

echo "Generating fstab"
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

echo "Adding host"
echo "$hostname" > /mnt/etc/hostname
cat > /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF

echo "Setup local timezone."
echo "en_US.UTF-8 UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

# export LANG=en_US.UTF-8

arch-chroot /mnt ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
arch-chroot /mnt hwclock --systohc 

echo "Setup users."
echo "root:$password" | arch-chroot /mnt chpasswd 
arch-chroot /mnt useradd -m -G wheel $username
echo "$username:$password" | arch-chroot /mnt chpasswd
# TODO maybe add sudo?
# echo '%wheel ALL=(ALL:ALL) ALL' | arch-chroot /mnt EDITOR='tee -a' visudo
echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers

echo "Setting up GRUB"
arch-chroot /mnt mkdir /boot/efi
arch-chroot /mnt mount $EFI /boot/efi
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck --removable
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "Enabling Network Manager"
arch-chroot /mnt systemctl enable NetworkManager

