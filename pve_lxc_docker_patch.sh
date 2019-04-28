#!/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本在PVE中解除apparmor限制，允许LXC容器中拉取docker镜像
#  - 不解除apparmor限制，在LXC容器中拉取docker镜像，会导致权限错误：failed to register layer: ApplyLayer exit status 1 stdout: stderr: permission denied
#  - LXC容器中写入解除apparmor限制的配置项
#  - 将非特权模式改为特权模式
# 本脚本使用方法:
#  wget --no-check-certificate https://raw.githubusercontent.com/waylonwang/sh-scripts/master/ubuntu_replace_aliyun_apt_repository.sh && chmod +x ubuntu_replace_aliyun_apt_repository.sh && ./ubuntu_replace_aliyun_apt_repository.sh
#
# 作者:waylon@waylon.wang
#*************************************************************************************
