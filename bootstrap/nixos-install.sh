#!/run/current-system/sw/bin/bash

# NOTE: This expects to run on the nixos installer image.
# ANOTHER NOTE: Your setup might vary depending on your device, e.g. I use an nvme drive.
# ANOTHER ANOTHER NOTE: Expects to be run as root

parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart primary 512MiB -8GiB
parted /dev/nvme0n1 -- mkpart primary linux-swap -8GiB 100%
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 3 esp on
mkfs.ext4 -L nixos /dev/nvme0n1p1
mkswap -L swap /dev/nvme0n1p2
mkfs.fat -F 32 -n boot /dev/nvme0n1p3
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/nvme0n1p2
nixos-generate-config --root /mnt
nixos-install
reboot
