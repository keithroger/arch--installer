#!/user/bin/env

#TODO use sed to change echo commands to colored output

DISK="/dev/nvme0n1"
EFI="/dev/nvme0n1p1"
LFS="/dev/nvme0n1p2"
microcode="intel-ucode"

echo "Starting Arch Linux install."

echo "Enter a hostname: "
read -r hostname

echo "Enter a username: "
read -r username

echo "Enter a password: "
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

echo "Changing root to /mnt"
arch-chroot /mnt

echo "Adding host"
echo "$hostname" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF

echo "Setup local timezone."
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

export LANG=en_US.UTF-8

ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc 

echo "Setup users."
echo "$password" | passwd
useradd -m -G wheel $username
echo $password | passwd $username
echo '%wheel ALL=(ALL:ALL) ALL' | sudo EDITOR='tee -a' visudo

echo "Setting up GRUB"
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck --removable
grub-mkconfig -o /boot/grub/grub.cfg

echo "Enabling Network Manager"
systemctl enable NetworkManager

