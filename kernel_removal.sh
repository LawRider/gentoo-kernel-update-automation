#!/bin/bash

echo "Checking how many kernel versions are installed..."
if [ $(eselect --brief kernel list|wc -l) -lt 3 ]
then echo "Less than 3 versions are installed. No removal is needed"; exit 1
else echo "Extra version of kernel is found"
fi

cur=$(uname -r|cut -d- -f1-|sed s%-gentoo%%)
#cur=$(uname -r|cut -d- -f1)
old=$(eselect --brief kernel list|head -1|cut -d- -f2-|sed s%-gentoo%%)
#old=$(eselect --brief kernel list|head -1|cut -d- -f2)
#echo "Current version of kernel in use is $(echo $cur|sed 's/-gentoo//')"
echo "Current version of kernel in use is $(echo $cur)"
#echo "The old version of kernel is $(echo $old|sed 's/-gentoo//')"
echo "The old version of kernel is $(echo $old)"
read -p "Would you like to remove old version of kernel? " yn
case $yn in 
    [Yy]* ) ;;
    [Nn]* ) exit 1;;
    * ) echo "Please answer yes or no.";;
esac
#while read
#do
#    case $REPLY in
#    [Yy]* )  answer=yes;;
#    [Nn]* )  answer=no; break 2;;
#     * )  echo -n "Invalid Option ('$REPLY' given). Please answer 'y' or 'n'. " >&2
#          if [ $((++retries)) -ge $max_retries ]; then break 2; fi;;
#    esac
#done
echo "Protecting current version of kernel sources from removal"
emerge -n gentoo-sources:$cur
echo "Unprotecting old version of kernel sources from removal"
sed "/gentoo-sources:$old/d" -i /var/lib/portage/world && echo "World file has been updated"
echo "Removing old version of kernel sources"
emerge -C gentoo-sources-$old
echo "Removing old kernel files, modules, boot-related files. The following folders/files will be removed:"
if [[ $old == *"-r"* ]]
then old=$(echo $old|sed s%-r%-gentoo-r%)
else old="${old}-gentoo"
fi
du -shc /usr/src/linux-$old /lib/modules/$old /boot/config-$old* /boot/initramfs-$old.img* /boot/System.map-$old* /boot/vmlinuz-$old*
rm -rf /usr/src/linux-$old /lib/modules/$old /boot/config-$old* /boot/initramfs-$old.img* /boot/System.map-$old* /boot/vmlinuz-$old*
