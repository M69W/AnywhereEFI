#!/bin/sh
makedir="/Users/$USER/Desktop/EFI"
origindir="$( dirname "${BASH_SOURCE[0]}" )"
efidir="/Volumes/efi"

#Start Module
function start()
{
    clear
    echo "AnywhereEFI written by penghubingzhou"
    choose
}

#1st choices  Module
function choose()
{

cat << EOF

Please choose an option：
(1) Auto  Install
(2) Exit

EOF

read -p "Input your choice[1~2]: " input
case $input in
1) instinit
;;
2) end
;;
*)
echo "Your input is incorrect, please try again. Any key for return."
choose
esac
}

#Install Init Module
function instinit()
{
clear
cat << EOF
Auto Install needs：
1、UEFI mode
2、Set Clover boot into /EFI/CLOVER/CLOVERX64.efi
3、Put your EFI dictionary into Desktop
4、mount_efi.sh with it
EOF

read -p "If you can ensure all of these are done，please enter y to continue, or any other key to return！！！！" input
if [[ $input == y ]];then
install
else
start
fi
}


#Install Module
function install()
{

if [[ -f $efidir/mount.efi.sh ]];then
read -p "mount_efi.sh is lost! Any key to return。"
start
fi

echo "Mounting EFI..."
efidir=`$origindir/mount_efi.sh`
echo "Copying original EFI to /desktop/EFIREC..."

cp -rf $efidir /Users/$USER/Desktop/EFIREC
if [[ ! -d /Users/$USER/Desktop/EFIREC ]];then
read -p "Backup EFI file failed，and install will continue without  backup ! enter y to continue, or any other key to return." input

if [[ ！$input == y ]];then
start
fi

else
echo "Backup EFI succeed. Installing……"
fi

if [[ ! -d $makedir ]];then
read -p "EFI dictionary for  install is not found, please put it into desktop! Any key to return."
start
fi

rm -rf $efidir/EFI
cp -rf $makedir $efidir

if [[ -d $efidir ]];then
rm -rf $makedir
read -p "Auto install succeed, please restart to enjoy! Any key for return."
start
else
read -p "Auto install failed! Any key for return."
start
fi
}

#结束块
function end()
{
echo "Exiting, good bye!"
exit 0
}


start
