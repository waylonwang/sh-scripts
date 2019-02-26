#!/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License
#
#*************************************************************************************
# 本脚本实现了一些基础常量
#  - 字体颜色
# 本脚本可在其他脚本中引用:
#  source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/public_const.sh)
# 
# 作者:waylon@waylon.wang
#*************************************************************************************

# 字体颜色
# 示例: ${readonly CLR_FG_RD}This is a example${readonly CLR_NO}
#
# 标准前景字体
readonly CLR_FG_BK="\033[30m"
readonly CLR_FG_RD="\033[31m"
readonly CLR_FG_GR="\033[32m"
readonly CLR_FG_YL="\033[33m"
readonly CLR_FG_BU="\033[34m"
readonly CLR_FG_PU="\033[35m"
readonly CLR_FG_CY="\033[36m"
readonly CLR_FG_WH="\033[37m"
# 粗体前景字体
readonly CLR_FG_BBK="\033[1;30m"
readonly CLR_FG_BRD="\033[1;31m"
readonly CLR_FG_BGR="\033[1;32m"
readonly CLR_FG_BYL="\033[1;33m"
readonly CLR_FG_BBU="\033[1;34m"
readonly CLR_FG_BPU="\033[1;35m"
readonly CLR_FG_BCY="\033[1;36m"
readonly CLR_FG_BWH="\033[1;37m"
# 标准背景字体
readonly CLR_BG_BK="\033[40m"
readonly CLR_BG_RD="\033[41m"
readonly CLR_BG_GR="\033[42m"
readonly CLR_BG_YL="\033[43m"
readonly CLR_BG_BU="\033[44m"
readonly CLR_BG_PU="\033[45m"
readonly CLR_BG_CY="\033[46m"
readonly CLR_BG_WH="\033[47m"
# 粗体背景字体
readonly CLR_BG_BBK="\033[1;40m"
readonly CLR_BG_BRD="\033[1;41m"
readonly CLR_BG_BGR="\033[1;42m"
readonly CLR_BG_BYL="\033[1;43m"
readonly CLR_BG_BBU="\033[1;44m"
readonly CLR_BG_BPU="\033[1;45m"
readonly CLR_BG_BCY="\033[1;46m"
readonly CLR_BG_BWH="\033[1;47m"
# 正常字体
readonly CLR_NO="\033[0m"
