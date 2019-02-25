#!/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License
#
#*************************************************************************************
# 本脚本实现了一些基础和常用的脚本功能，可通过source命令嵌入外部脚本中
# 
# 作者:waylon@waylon.wang
#*************************************************************************************

# 颜色
CLR_FG_BK="\033[30m"
CLR_FG_RD="\033[31m"
CLR_FG_GR="\033[32m"
CLR_FG_YL="\033[33m"
CLR_FG_BU="\033[34m"
CLR_FG_PU="\033[35m"
CLR_FG_CY="\033[36m"
CLR_FG_WH="\033[37m"
CLR_FG_BBK="\033[1;30m"
CLR_FG_BRD="\033[1;31m"
CLR_FG_BGR="\033[1;32m"
CLR_FG_BYL="\033[1;33m"
CLR_FG_BBU="\033[1;34m"
CLR_FG_BPU="\033[1;35m"
CLR_FG_BCY="\033[1;36m"
CLR_FG_BWH="\033[1;37m"
CLR_BG_BK="\033[40m"
CLR_BG_RD="\033[41m"
CLR_BG_GR="\033[42m"
CLR_BG_YL="\033[43m"
CLR_BG_BU="\033[44m"
CLR_BG_PU="\033[45m"
CLR_BG_CY="\033[46m"
CLR_BG_WH="\033[47m"
CLR_BG_BBK="\033[1;40m"
CLR_BG_BRD="\033[1;41m"
CLR_BG_BGR="\033[1;42m"
CLR_BG_BYL="\033[1;43m"
CLR_BG_BBU="\033[1;44m"
CLR_BG_BPU="\033[1;45m"
CLR_BG_BCY="\033[1;46m"
CLR_BG_BWH="\033[1;47m"
CLR_NO="\033[0m"

# 获取当前操作系统名称
# 输入: 无
# 输出: 操作系统名称 debian|ubuntu|devuan|centos|fedora|rhel
function get_os()
{
  source /etc/os-release
  echo $ID
}

# 检查操作系统
# 输入:
#       -t 包含目标系统名称的字符串，以逗号分隔
#       -p 出现错误时给出提示
# 输出: 是否匹配 0-匹配 1-不匹配
# 示例: check_os -t "centos,ubuntu" -p 
function check_os()
{
  local targets=() prompt=1 ret=1 os=`get_os`
  local OPTIND OPTARG arg_all
  while getopts "t:p" arg_all; do
    case $arg_all in
      t)
		targets=(${OPTARG//,/ }) ;;
      p)
        prompt=0 ;;
	  ?)
        if [ "$prompt" = 0 ]; then
	    	echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
	    fi
	    exit 1 ;;
	  esac
  done
  shift $((OPTIND-1))

  for i in ${!targets[@]}; do
    if [ "$os" = "${targets[i]}" ]; then
      ret=0
      break
    fi
  done

  if [ "$ret" != 0 -a "${prompt}" = 0 ]; then
    local os=`get_os`
    echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} This script not supports $os."
  fi

  return $ret
}
