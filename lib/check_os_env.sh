#!/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本实现了OS环境的检查功能
#  - 检查操作系统是否符合要求
# 本脚本可在其他脚本中引用:
#  source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/check_os_env.sh)
# 
# 作者:waylon@waylon.wang
#*************************************************************************************
# 如环境变量GIT_RAW_SH未设置则默认设为github地址
[ -z ${GIT_RAW_SH} ] && GIT_RAW_SH="https://raw.githubusercontent.com/waylonwang/sh-scripts/master"
# 变量GIT_RAW_SH设置完成

# 字体颜色
[ -z $REF_CONFLICT_FLAG ] && source <(curl -s ${GIT_RAW_SH}/lib/public_const.sh)

# 获取当前操作系统名称
# 输入: 无
# 输出: 操作系统名称 debian|ubuntu|devuan|centos|fedora|rhel|raspbian
function get_os()
{
  source /etc/os-release
  echo $ID
}

# 检查操作系统
# 输入:
#       -t 包含目标系统名称的字符串，以逗号分隔
#       -p 显示提示信息
# 输出: 是否匹配 0-匹配 1-不匹配
# 示例: check_os -t "centos,ubuntu" -p 
function check_os()
{
  local targets=() prompt=1 ret=1
  local OPTIND OPTARG arg_all
  while getopts "t:p" arg_all; do
    case $arg_all in
      t)
				targets=(${OPTARG//,/ }) ;;
      p)
        prompt=0 ;;
	  	?)
      	[ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
	    	exit 1 ;;
	  esac
  done
  shift $((OPTIND-1))

  for i in ${!targets[@]}; do
    if [ "$(get_os)" = "${targets[i]}" ]; then
      ret=0
      break
    fi
  done

  [ "$ret" != 0 -a "${prompt}" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} This script not supports $(get_os)."

  return $ret
}
