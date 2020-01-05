#!/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本在PVE中解除apparmor限制，允许LXC容器中拉取docker镜像
#  - 不解除apparmor限制，在LXC容器中拉取docker镜像，会导致权限错误：failed to register layer: ApplyLayer exit status 1 stdout: stderr: permission denied
#  - LXC容器中写入解除apparmor限制的配置项
#  - 将非特权模式改为特权模式
# 本脚本使用方法:
#  curl -L https://raw.githubusercontent.com/waylonwang/sh-scripts/master/pve_lxc_docker_patch.sh -o pve_lxc_docker_patch.sh && chmod +x pve_lxc_docker_patch.sh && ./pve_lxc_docker_patch.sh
#
# 作者:waylon@waylon.wang
#*************************************************************************************
# 如环境变量GIT_RAW_SH未设置则默认设为github地址
[ -z ${GIT_RAW_SH} ] && GIT_RAW_SH="https://raw.githubusercontent.com/waylonwang/sh-scripts/master"
# 变量GIT_RAW_SH设置完成

source <(curl -s ${GIT_RAW_SH}/lib/check_os_env.sh)

check_os -t "debian" -p

echo -e "${CLR_FG_GR}Patch start${CLR_NO}"
read -p $"Input PVE Host's ID (such as 103 or 104): " host

if [[ `pct status $host | sed -n -r '1,1 s/.*status:\s*(\S*)/\1/p'` != "stopped" ]] ; then
  echo -e "${CLR_FG_YL}Shutdown the HOST [$host]${CLR_NO}"
  pct shutdown $host
fi

file="/var/lib/lxc/$host/config"

echo -e "${CLR_FG_YL}Patch file: $file${CLR_NO}"
chmod ugo+w $file

sed -i '/^lxc\.apparmor/'d $file
sed -i '1a\lxc.cap.drop =' $file
sed -i '1a\lxc.cgroup.devices.allow = a' $file
sed -i '1a\lxc.apparmor.profile = unconfined' $file

lxc-update-config -c $file

file="/etc/pve/lxc/$host.conf"

echo -e "${CLR_FG_YL}Patch file: $file${CLR_NO}"

sudo sed -i '/^unprivileged/'d $file
sudo sed -i '1a\lxc.hook.post-stop =' $file
sudo sed -i '1a\lxc.hook.mount =' $file

read -p $"Do you need start the Host [$host] (Y/n)" answer

case ${answer:0:1} in
    n|N ) ;;
    * )
      echo -e "${CLR_FG_YL}Start the HOST [$host]${CLR_NO}"
      pct start $host
    ;;
esac
echo -e "${CLR_FG_GR}Patch done ${CLR_NO}"
