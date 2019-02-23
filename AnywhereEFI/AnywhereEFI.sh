#!/bin/sh
makedir="/Users/$USER/Desktop/EFI"
origindir="$( dirname "${BASH_SOURCE[0]}" )"
tmpdir="/Users/$USER/Desktop/Temp0"
cloverfile="/Users/$USER/Desktop/Clovernew.pkg"
extractdir="/Users/$USER/Desktop/extractdir"
efitemp="/Users/$USER/Desktop/efitemp"
driverdir="/Users/$USER/Desktop/EFI/CLOVER/drivers64UEFI"

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
(1) Auto Update Clover
(2) Auto  Install
(3) Exit

EOF

    read -p "Input your choice[1~3]: " input
    case $input in
    1) extract
    ;;
    2) instinit
    ;;
    3) end
    ;;
    *)

    echo "Your input is incorrect, please try again. Any key for return."
    choose
    esac
}

#Download Module
function download()
{
    #Analysis the URL of the latest verison of Clover
    if [ ! -d $tmpdir ]; then
        mkdir $tmpdir
    fi
    echo "Analysising the URL of the latest version of Clover"
    cd $tmpdir
    curl --progress-bar -o $tmpdir/resource https://api.github.com/repos/Dids/clover-builder/releases

    if [ ! -f $tmpdir/resource ]; then

    for ((i=1;i<=2 && ! -f $tmpdir/resource;i++));
    do
        echo "Analysising failed，Retrying"
        curl --progress-bar -o $tmpdir/resource https://api.github.com/repos/Dids/clover-builder/releases
    done

        if [ ! -f $tmpdir/resource ]; then
            read -p "Analysising failed, any key to return!"
            start
        fi
    fi


    #Get URL and download it by curl
    downlink=`cat $tmpdir/resource |  grep 'browser_download_url' | sed -n 3p | awk -F " " '{print $2}' | tr -d '"'`
    echo "Downloading the latest version of Clover"
    cd /Users/$USER/Desktop
    curl --progress-bar -L -o $cloverfile $downlink
    if [ ! -f $cloverfile ]; then
        for ((i=1;i<=2 && ! -f $cloverfile;i++));
        do
            echo "Analysising failed，Retrying"
            curl --progress-bar -L -o /Users/$USER/Desktop/Clover.pkg $downlink
        done

        if [ ! -f $cloverfile ]; then
            read -p "Analysising failed, any key to return!"
            start
        fi
    fi

    rm -f $tmpdir/resource
}

#Extract Module
function extract()
{
    clear
    download

    #extract new Clover files
    xar -xf $cloverfile -C $tmpdir
    rm -rf $tmpdir/Resources

    if [ ! -d $extractdir ]; then
        mkdir $extractdir
    fi

    dirlist=$(ls $tmpdir)
    cd $extractdir

    for name in ${dirlist[*]}
    do
        cat $tmpdir/$name/Payload | cpio -i
    done
    rm -rf $tmpdir

    #Put file needed to update into efitemp
    echo "Generating new files"
    mkdir $efitemp
    mkdir $efitemp/CLOVER
    mkdir $efitemp/CLOVER/drivers64UEFI
    cp $extractdir/EFI/CLOVER/CLOVERX64.efi $efitemp/CLOVER
    cp -rf $extractdir/EFI/CLOVER/tools $efitemp/CLOVER
    cp -rf $extractdir/EFI/BOOT $efitemp

    dirlist=$(ls $driverdir)

    for name in ${dirlist[*]}
    do
    #Because original EFI file may have some efi files that can't be found in Clover Pkg (like VirtualSMC.efi), here we needs to know if Clover Pkg has this file and just merge the new file in Clover Pkg into origin files.
    if [ -f $extractdir/$name ]; then
        cp -f $extractdir/$name $efitemp/CLOVER/drivers64UEFI && stty -echo
    fi
    done

    rm -rf $extractdir

    #Start Updating
    if [[ ! -d $makedir ]];then
        read -p "mount_efi.sh is lost! Any key to return."
        start
    fi
    echo "Updating"
    rm -rf $makedir/CLOVER/drivers64UEFI
    rm -f $makedir/CLOVER/CLOVERX64.efi
    rm -rf $makedir/CLOVER/tools
    rm -rf $makedir/BOOT

    cp -rf $efitemp/CLOVER/drivers64UEFI $makedir/CLOVER
    cp -f $efitemp/CLOVER/CLOVERX64.efi $makedir/CLOVER
    cp -rf $efitemp/CLOVER/tools $makedir/CLOVER
    cp -rf $efitemp/BOOT $makedir/BOOT

    #End Work
    rm -rf $efitemp
    rm -f $cloverfile
    read -p "Updated Clover sucessfully, enter any key to return."
    m=1
    start
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
        if [[ ! $m == 1 ]];then
            read -p "To ensure the EFI can support the latest version, recommand you update your Clover version!!! Enter y to return for updating, or ant other key to continue." input
            if [[ $input == y ]];then
                start
            fi
        fi
        install
    else
        start
    fi
}


#Install Module
function install()
{
#detect the  EFI mount script
    if [[ ! -f $origindir/mount.efi.sh ]];then
        read -p "mount_efi.sh is lost! Any key to return."
        start
    fi
#mount efi partition，script  written by hieplpvip
    echo "Mounting EFI..."
    efidir=`$origindir/mount_efi.sh`

#detect the  windows  EFI files，will  set  haswin to yes  if  has windows EFI.
    if [[ -d $efidir/Microsoft ]];then
        haswin="yes"
    fi

#backup original EFI files
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

#detect install file
    if [[ ! -d $makedir ]];then
        read -p "EFI dictionary for  install is not found, please put it into desktop! Any key to return."
        start
    fi

#install
    rm -rf $efidir/EFI
    cp -rf $makedir $efidir

#restore windows EFI files if needed
    if [[ $haswin == yes ]];then
        echo "Restoring your Windows EFI files to EFI partition..."
        cp -rf /Users/$USER/Desktop/EFIREC/EFI/Microsoft $efidir/EFI
        if [[ -d $efidir/EFI/Microsoft ]];then
            rm -rf $makedir
            echo "Restoring Windows EFI succeed."
        else
            read -p "Restoring Windows EFI failed. Any key to return."
            start
        fi
    fi

#finishing the  installation
    if [[ -d $efidir ]];then
        rm -rf $makedir
        read -p "Auto install succeed, please restart to enjoy! Any key for return."
    else
        read -p "Auto install failed! Any key for return."
        fi
    start
}

#End Module
function end()
{
echo "Exiting, good bye!"
exit 0
}


start
