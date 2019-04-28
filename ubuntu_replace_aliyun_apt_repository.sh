#! /bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本实现了ubuntu的apt源更改为阿里云镜像的脚本功能
# 本脚本使用方法:
#  wget --no-check-certificate https://raw.githubusercontent.com/waylonwang/sh-scripts/master/ubuntu_replace_aliyun_apt_repository.sh && chmod +x ubuntu_replace_aliyun_apt_repository.sh && ./ubuntu_replace_aliyun_apt_repository.sh
# 
# 作者:waylon@waylon.wang
#*************************************************************************************
codename=`sudo lsb_release -c | sed -n -r '1,1 s/.*Codename:\s*(\S*)/\1/p'`

sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak

echo "deb http://mirrors.aliyun.com/ubuntu/ $codename main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ $codename main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ $codename-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ $codename-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ $codename-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ $codename-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ $codename-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ $codename-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ $codename-proposed main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ $codename-proposed main restricted universe multiverse" >> /etc/apt/sources.list

apt-get update
