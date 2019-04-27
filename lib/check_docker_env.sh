#!/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本实现了一些基础和常用的脚本功能
#  - 检查操作系统是否符合要求
#  - 检查docker是否已经安装及运行
#  - 检查docker-compose是否已经安装
# 本脚本可在其他脚本中引用:
#  source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/check_docker_env.sh)
# 
# 作者:waylon@waylon.wang
#*************************************************************************************

# 字体颜色
[ -z $REF_CONFLICT_FLAG ] && source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/public_const.sh)

# 获取当前操作系统名称
# 输入: 无
# 输出: 操作系统名称 debian|ubuntu|devuan|centos|fedora|rhel|raspbian
function get_os()
{
  source /etc/os-release
  echo $ID
}

# 判断是否已经安装docker
# 输入: 无
# 输出: 0-已安装 1-未安装
function is_docker_install()
{
  [ -x "$(command -v docker)" ] && return 0 || return 1
}

# 判断是否已经安装docker-compose
# 输入: 无
# 输出: 0-已安装 1-未安装
function is_compose_install()
{
  [ -x "$(command -v docker-compose)" ] && return 0 || return 1
}

# 判断是否已经在运行docker
# 输入: 无
# 输出: 0-已运行 1-未运行
function is_docker_active()
{
  local status=`systemctl is-active docker`
  [ "$status" -a "$status" = "active" ] && return 0 || return 1
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

# 检查docker是否运行
# 输入:
#       -s docker未运行时尝试启动docker
#       -p 显示提示信息
# 输出: 是否匹配 0-已运行 1-未运行
# 示例: check_docker_active -u -p 
function check_docker_active()
{
	local up=1 prompt=1 ret=1
  local OPTIND OPTARG arg_all
  while getopts "ps" arg_all; do
    case $arg_all in
      p)
        prompt=0 ;;
      s)
				start=0 ;;
	  	?)
      	[ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
	    	exit 1 ;;
	  esac
  done
  shift $((OPTIND-1))

  is_docker_install ; local is_install=$?
  [ "$is_install" != 0 -a "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} startup docker error, docker not install."

  is_docker_active ; local is_active=$?
  [ "$is_active" != 0 -a "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Docker is inactive.${CLR_NO}"
  [ "$is_active" != 0 -a "$start" = 0 -a "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Starting up docker.${CLR_NO}"
  [ "$is_active" != 0 -a "$start" = 0 ] && systemctl start docker

  if is_docker_active ; then
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} docker is running."
    ret=0
  else
    [ "$start" = 0  -a "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} docker startup failed."
  fi

  return $ret
}

# 检查docker是否安装
# 输入:
#       -a docker加入自启动服务
#       -i docker未安装时尝试安装docker
#       -p 显示提示信息
#       -s docker未运行时尝试启动docker
#       -v 显示docker版本信息
# 输出: 是否匹配 0-已安装 1-未安装
# 示例: check_docker_install -a -i -p -s -v
function check_docker_install()
{
	local enable=1 install=1 prompt=1 start=1 version=1 ret=1
  local OPTIND OPTARG arg_all
  while getopts "aipsv" arg_all; do
    case $arg_all in
      a)
				autorun=0 ;;
      i)
				install=0 ;;
      p)
        prompt=0 ;;
      s)
        start=0 ;;
      v)
        version=0 ;;
	  	?)
      	[ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
	    	exit 1 ;;
	  esac
  done
  shift $((OPTIND-1))

  is_docker_install ; local is_install=$?
  [ "$is_install" != 0 -a "$install" = 0 -a "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Installing docker.${CLR_NO}"
  if [ "$(get_os)" == "centos" ]; then
  	[ "$is_install" != 0 -a "$install" = 0 ] && yum -y install docker
  else
  	[ "$is_install" != 0 -a "$install" = 0 ] && apt-get install -y docker
  fi

  if [ "$is_install" != 0 -a "$install" = 0 ]; then 
  	is_docker_install ; is_install=$? 
  fi

  [ "$is_install" != 0 -a "$version" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} get version error, docker not install."
  [ "$is_install" = 0 -a "$version" = 0 ] && echo -e "${CLR_FG_PU}`docker --version`${CLR_NO}"
  [ "$is_install" = 0 -a "$start" = 0 -a "$prompt" = 0 ] && check_docker_active -s -p
  [ "$is_install" = 0 -a "$start" = 0 -a "$prompt" != 0 ] && check_docker_active -s
  [ "$is_install" = 0 -a "$autorun" = 0 ] && systemctl enable docker
  [ "$is_install" = 0 -a "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} docker has been installed."
  [ "$is_install" = 0 ] && ret=0

  return $ret
}

# 检查docker-compose是否安装
# 输入:
#       -i docker-compose未安装时尝试安装docker-compose
#       -p 显示提示信息
#       -v 显示docker-compose版本信息
# 输出: 是否匹配 0-已安装 1-未安装
# 示例: check_compose_install -i -p -v
function check_compose_install()
{
	local install=1 prompt=1 version=1 ret=1
  local OPTIND OPTARG arg_all
  while getopts "ipv" arg_all; do
    case $arg_all in
      i)
				install=0 ;;
      p)
        prompt=0 ;;
      v)
        version=0 ;;
	  	?)
      	[ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
	    	exit 1 ;;
	  esac
  done
  shift $((OPTIND-1))

  is_compose_install ; local is_install=$?
  [ "$is_install" != 0 -a "$install" = 0 -a "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Installing docker-compose.${CLR_NO}"
  [ "$is_install" != 0 -a "$install" = 0 ] && curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
  [ "$is_install" != 0 -a "$install" = 0 ] && chmod +x /usr/bin/docker-compose

  if [ "$is_install" != 0 -a "$install" = 0 ]; then 
  	is_docker_install ; is_install=$? 
  fi

  [ "$is_install" != 0 -a "$version" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} get version error, docker-compose not install."
  [ "$is_install" = 0 -a "$version" = 0 ] && echo -e "${CLR_FG_PU}`docker-compose --version`${CLR_NO}"
  [ "$is_install" = 0 -a "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} docker has been installed."
  [ "$is_install" = 0 ] && ret=0
  
  return $ret
}
