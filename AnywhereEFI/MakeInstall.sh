#!/bin/sh
makedir="/Users/$USER/Desktop/EFI"
origindir="$( dirname "${BASH_SOURCE[0]}" )"
efidir="/Volumes/efi"

#起始块
function start()
{
clear
echo "通用EFI自动安装脚本 by 澎湖冰洲"
choose
}

#第一选择块
function choose()
{

cat << EOF

请选择要执行的操作：
(1) 自动安装
(2) 退出

EOF

read -p "输入你的选择[1~2]: " input
case $input in
1) instinit
;;
2) end
;;
*)
echo "输入有误，请重新输入"
choose
esac
}

#安装初始化块
function instinit()
{
clear
cat << EOF
自动安装要求：
1、UEFI模式
2、设置的四叶草引导路径为/EFI/CLOVER/CLOVERX64.efi
3、将待安装的EFI文件夹放置在桌面
4、mount_efi.sh与本安装脚本放置在一块
EOF

read -p "如您确认以上四点无误，请输入y回车，否则按任意键返回！！！！" input
if [[ $input == y ]];then
install
else
start
fi
}


#安装块
function install()
{

if [[ -f $efidir/mount.efi.sh ]];then
read -p "未检测到EFI挂载脚本（mount_efi.sh)！按任意键返回。"
start
fi

if [[ -d $efidir/mount.efi.sh ]];then
read -p "未检测到EFI挂载脚本（mount_efi.sh)！按任意键返回。"
start
fi

echo "正在挂载EFI……"
efidir=`$origindir/mount_efi.sh`
echo "正在备份原有EFI，原EFI将被备份到桌面下的EFIREC下"

cp -rf $efidir /Users/$USER/Desktop/EFIREC
if [[ ! -d /Users/$USER/Desktop/EFIREC ]];then
read -p "备份原有EFI失败，安装将在无备份的条件下进行！输入y继续安装，否则按任意键返回。" input

if [[ ！$input == y ]];then
start
fi

else
echo "备份完成，正在准备安装新EFI……"
fi

if [[ ! -d $makedir ]];then
read -p "待安装的EFI文件夹不存在，请将安装文件夹放在桌面！按任意键返回。"
start
fi

rm -rf $efidir/EFI
cp -rf $makedir $efidir

if [[ -d $efidir ]];then
rm -rf $makedir
say 从现在起开启全新的Y7000之旅
read -p "自动安装成功，重启生效！按任意键返回。"
start
else
read -p "自动安装失败，按任意键返回。"
start
fi
}

#结束块
function end()
{
echo "正在退出,欢迎下次使用!"
exit 0
}


start
