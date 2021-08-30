#!/bin/bash

cur=$(uname -r)
last=$(eselect --brief kernel list|tail -1|cut -d- -f2-)
selected=$(eselect kernel list|grep '*'|awk '{print$2}'|cut -d- -f2-)
echo "Checking if the last version of kernel is already in use..."
echo "Current version of kernel in use is $(echo $cur|sed 's/-gentoo//')"
echo "The last version of kernel is $(echo $last|sed 's/-gentoo//')"
echo "The selected version of kernel is $(echo $selected|sed 's/-gentoo//')"

if [ $last == $cur ]
then
    echo "The last version of kernel is already in use, no actions are needed"
    exit
else
    if [ $last == $selected ]    
    then
        echo "The last version of kernel is already selected"
    else
        eselect kernel set $last
        echo "New version of kernel has been selected"
    fi
fi

cd /usr/src/linux/
echo "Checking current kernel config before using for new kernel..."
zcat /proc/config.gz > .config
make oldconfig

retries=0
max_retries=100
answer=no
echo -n "Do you wish to make manual adjustments to kernel config? "
while read
do
    case $REPLY in
    [Yy]* )  answer=yes; make menuconfig; break 2;;
    [Nn]* )  answer=no; break 2;;
     * )  echo -n "Invalid Option ('$REPLY' given). Please answer 'y' or 'n'. " >&2
          if [ $((++retries)) -ge $max_retries ]; then break 2; fi;;
    esac
done

echo "Building kernel..."
make -j$(nproc)
echo "Installing modules..."
make modules_install
echo "Installing kernel..."
make install
echo "Backing up kernel config..."
cp .config /etc/kernels/config-$last
echo "Generating initramfs..."
genkernel initramfs
echo "Updating grub config..."
grub-mkconfig -o /boot/grub/grub.cfg
echo "Rebuilding kernel modules..."
emerge -q @module-rebuild
