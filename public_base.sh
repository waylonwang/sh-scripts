#!/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License
#
#*************************************************************************************
# 本脚本实现了一些基础和常用的脚本功能，可通过source命令嵌入外部脚本中
# 
# 作者:waylon@waylon.wang
#*************************************************************************************

# 字体颜色
# 示例: ${CLR_FG_RD}This is a example${CLR_NO}
#
# 标准前景字体
CLR_FG_BK="\033[30m"
CLR_FG_RD="\033[31m"
CLR_FG_GR="\033[32m"
CLR_FG_YL="\033[33m"
CLR_FG_BU="\033[34m"
CLR_FG_PU="\033[35m"
CLR_FG_CY="\033[36m"
CLR_FG_WH="\033[37m"
# 粗体前景字体
CLR_FG_BBK="\033[1;30m"
CLR_FG_BRD="\033[1;31m"
CLR_FG_BGR="\033[1;32m"
CLR_FG_BYL="\033[1;33m"
CLR_FG_BBU="\033[1;34m"
CLR_FG_BPU="\033[1;35m"
CLR_FG_BCY="\033[1;36m"
CLR_FG_BWH="\033[1;37m"
# 标准背景字体
CLR_BG_BK="\033[40m"
CLR_BG_RD="\033[41m"
CLR_BG_GR="\033[42m"
CLR_BG_YL="\033[43m"
CLR_BG_BU="\033[44m"
CLR_BG_PU="\033[45m"
CLR_BG_CY="\033[46m"
CLR_BG_WH="\033[47m"
# 粗体背景字体
CLR_BG_BBK="\033[1;40m"
CLR_BG_BRD="\033[1;41m"
CLR_BG_BGR="\033[1;42m"
CLR_BG_BYL="\033[1;43m"
CLR_BG_BBU="\033[1;44m"
CLR_BG_BPU="\033[1;45m"
CLR_BG_BCY="\033[1;46m"
CLR_BG_BWH="\033[1;47m"
# 正常字体
CLR_NO="\033[0m"

# 获取当前操作系统名称
# 输入: 无
# 输出: 操作系统名称 debian|ubuntu|devuan|centos|fedora|rhel
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
  if [ -x "$(command -v docker)" ]; then
    return 0
  else
    return 1
  fi	
}

# 判断是否已经安装docker-compose
# 输入: 无
# 输出: 0-已安装 1-未安装
function is_compose_install()
{
  if [ -x "$(command -v docker-compose)" ]; then
    return 0
  else
    return 1
  fi
}

# 判断是否已经在运行docker
# 输入: 无
# 输出: 0-已运行 1-未运行
function is_docker_active()
{
  local status=`systemctl is-active docker`
  if [ "$status" -a "$status" = "active" ]; then
      return 0
    else
      return 1
  fi
}

# 检查操作系统
# 输入:
#       -t 包含目标系统名称的字符串，以逗号分隔
#       -p 出现错误时给出提示
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
    if [ "${get_os}" = "${targets[i]}" ]; then
      ret=0
      break
    fi
  done

  [ "$ret" != 0 -a "${prompt}" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} This script not supports ${get_os}."

  return $ret
}

function check_docker_install()
{
	local enable=1 install=1 prompt=1 start=1 version=1 ret=1
  local OPTIND OPTARG arg_all
  while getopts "eipsv" arg_all; do
    case $arg_all in
      e)
				enable=0 ;;
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

  if [ "${is_docker_install}" ]; then
    [ "$version" = 0 ] && echo -e "${CLR_FG_PU}`docker --version`${CLR_NO}"
    echo -e "${CLR_FG_GR}[OK] docker has been installed.${CLR_NO}"
    ret=0
  else
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Installing docker.${CLR_NO}"
    [ "$install" = 0 ] && yum -y install docker
    [ "$version" = 0 ] && echo -e "${CLR_FG_PU}`docker --version`${CLR_NO}"
    [ "$start" = 0 ] && systemctl start docker
    [ "$enable" = 0 ] && systemctl enable docker
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} docker has been installed."
  fi

  return $ret
}

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

  if [ "${is_compose_install}" ]; then
    [ "$version" = 0 ] && echo -e "${CLR_FG_PU}`docker-compose --version`${CLR_NO}"
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK] docker-compose has been installed.${CLR_NO}"
    ret=0
  else
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Installing docker-compose.${CLR_NO}"
    [ "$install" = 0 ] && curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
    [ "$install" = 0 ] && chmod +x /usr/bin/docker-compose
    [ "$version" = 0 ] && echo -e "${CLR_FG_PU}`docker-compose --version`${CLR_NO}"
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} docker-compose has been installed."
  fi

  return $ret
}

function check_docker_active()
{
	local up=1 prompt=1 ret=1
  local OPTIND OPTARG arg_all
  while getopts "up" arg_all; do
    case $arg_all in
      u)
				up=0 ;;
      p)
        prompt=0 ;;
	  	?)
      	[ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
	    	exit 1 ;;
	  esac
  done
  shift $((OPTIND-1))

  local is_active=`${is_docker_active}` times=0
  if [ "$is_active" != 0 ]; then
	  [ "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Docker is inactive.${CLR_NO}"
	  [ "$up" = 0 -a "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Starting up docker.${CLR_NO}"
	  while [ "${is_docker_active}" -a "$up" = 0 -a "$times" -lt 3]; do
	  	systemctl start docker
	  	times=$((times+1))
	  	sleep 1
	  done
	 fi

  if [ "${is_docker_active}" ]; then
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} docker is running."
    ret=0
  else
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} docker startup failed."
  fi

  return $ret
}

function test_check_os{}
{
	echo 'check_os -t "centos,dsm" -p'
	check_os -t "centos,dsm" -p 

	echo 'check_os -t "centos,dsm"'
	check_os -t "centos,dsm"
	 
	echo 'check_os -t "centos,ubuntu,dsm" -p'
	check_os -t "centos,ubuntu,dsm" -p 

	echo 'check_os -t "centos,ubuntu,dsm"'
	check_os -t "centos,ubuntu,dsm"	
}

function test_check_docker_install{}
{
	echo 'check_docker_install'
	check_docker_install

	echo 'check_docker_install -p'
	check_docker_install -p 

	echo 'check_docker_install -p -v'
	check_docker_install -p -v 

	echo 'check_docker_install -p -i -v'
	check_docker_install -p -i -v 

	echo 'check_docker_install -p -i -e -v'
	check_docker_install -p -i -e -v 
}

function test_check_compose_install{}
{
	echo 'check_compose_install'
	check_compose_install

	echo 'check_compose_install -p'
	check_compose_install -p 

	echo 'check_compose_install -p -v'
	check_compose_install -p -v 

	echo 'check_compose_install -p -i -v'
	check_compose_install -p -i -v 
}

function test_check_docker_active{}
{
	echo 'check_docker_active'
	check_docker_active

	echo 'check_docker_active -p'
	check_docker_active -p 

	echo 'check_docker_active -p -u'
	check_docker_active -p -u
}

test_check_os
