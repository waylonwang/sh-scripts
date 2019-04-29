#!/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本在PVE中解除apparmor限制，允许LXC容器中拉取docker镜像
#  - 不解除apparmor限制，在LXC容器中拉取docker镜像，会导致权限错误：failed to register layer: ApplyLayer exit status 1 stdout: stderr: permission denied
#  - LXC容器中写入解除apparmor限制的配置项
#  - 将非特权模式改为特权模式
# 本脚本使用方法:
#  wget --no-check-certificate https://raw.githubusercontent.com/waylonwang/sh-scripts/master/pve_lxc_docker_patch.sh && chmod +x pve_lxc_docker_patch.sh && ./pve_lxc_docker_patch.sh
#
# 作者:waylon@waylon.wang
#*************************************************************************************
source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/check_os_env.sh)

check_os -t "debian" -p

read -p $"Input PVE Host's ID (such as 103 or 104): " host

if [[ `pct status $host | sed -n -r '1,1 s/.*status:\s*(\S*)/\1/p'` != "stopped" ]] ; then
  echo -e "${CLR_FG_YL}Shutdown the HOST [$host]${CLR_NO}"
  pct shutdown $host
fi

file="/var/lib/lxc/$host/config"

echo -e "${CLR_FG_YL}Patch file: $file${CLR_NO}"
chmod ugo+w $file

sed '/^lxc\.apparmor/'d $file
sed -i '20a\lxc.cap.drop =' $file
sed -i '20a\lxc.cgroup.devices.allow = a' $file
sed -i '20a\lxc.apparmor.profile = unconfined' $file

file="/etc/pve/lxc/$host.conf"

echo -e "${CLR_FG_YL}Patch file: $file${CLR_NO}"
# chown root:root $file
# chmod ugo+w $file
# chown root:www-data $file

sudo sed '/^unprivileged/'d $file
sudo sed -i '20a\lxc.hook.post-stop =' $file
sudo sed -i '20a\lxc.hook.mount =' $file

read -p $"Do you need start the Host [$host] (Y/n)" answer

case ${answer:0:1} in
    n|N ) ;;
    * )
      echo -e "${CLR_FG_YL}Start the HOST [$host]${CLR_NO}"
      pct start $host
    ;;
esac
echo -e "${CLR_FG_GR}$Patch done ${CLR_NO}"
