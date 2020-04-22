#!/bin/bash

echo "Checking if there are more than 2 versions of kernel installed..."
if [ $(eselect --brief kernel list|wc -l) -lt 3 ]
then echo "2 versions are installed. No removal is needed"; exit 1
else echo "Extra version of kernel is found"
fi

cur=$(uname -r|cut -d- -f1)
old=$(eselect --brief kernel list|head -1|cut -d- -f2)
echo "Current version of kernel in use is $cur"
echo "The old version of kernel is $old"
read -p "Would you like to remove old version of kernel? " yn
case $yn in 
    [Yy]* ) ;;
    [Nn]* ) exit 1;;
    * ) echo "Please answer yes or no.";;
esac
echo "Protecting current version of kernel sources from removal"
emerge -n gentoo-sources:$cur
echo "Unprotecting old version of kernel sources from removal"
sed "/$old/d" -i /var/lib/portage/world && echo "World file has been updated"
echo "Removing old version of kernel sources"
emerge -ac
echo "Removing old kernel files, modules, boot-related files. The following folders/files will be removed:"
du -shc /usr/src/linux-$old* /lib/modules/$old* /boot/config-$old-gentoo* /boot/initramfs-genkernel-x86_64-$old-gentoo* /boot/System.map-$old-gentoo* /boot/vmlinuz-$old-gentoo*
rm -rf /usr/src/linux-$old* /lib/modules/$old* /boot/config-$old-gentoo* /boot/initramfs-genkernel-x86_64-$old-gentoo* /boot/System.map-$old-gentoo* /boot/vmlinuz-$old-gentoo*
