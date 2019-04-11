#!/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本实现了基础相关的脚本功能
#  - 检查portainer挂载卷是否符已存在
#  - 检查nginx挂载卷是否符已存在
# 本脚本可在其他脚本中引用:
#  source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/check_base_volumes.sh)
# 
# 作者:waylon@waylon.wang
#*************************************************************************************

[ -z $REF_CONFLICT_FLAG ] && source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/public_const.sh)

# 检查portainer挂载卷
# 输入:
#       -c 不存在时自动创建
#       -d 指定配置文件所在目录
#       -p 显示提示信息
# 输出: 是否存在 0-已存在 1-未存在
# 示例: check_portainer_volumes -c -d "./portaine" -p 
function check_portainer_volumes()
{
  local create=1 dir="./portainer" prompt=1 ret=1
  local OPTIND OPTARG arg_all
  while getopts "cd:p" arg_all; do
    case $arg_all in
      c)
        create=0 ;;
      d)
        dir=(${OPTARG//,/ }) ;;
      p)
        prompt=0 ;;
      ?)
        [ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
        exit 1 ;;
    esac
  done
  shift $((OPTIND-1))

  [ -d $dir"/data" ] && ret=0

  if [ ! -d $dir"/data" -a "$create" = 0 ]; then
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Creating portainer configuration files.${CLR_NO}"

    mkdir -p $dir"/data"

    ret=0
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} portainer configuration folder is ready."
  fi

  return $ret
}

# 检查php挂载卷
# 输入:
#       -c 不存在时自动创建
#       -d 指定配置文件所在目录
#       -p 显示提示信息
# 输出: 是否存在 0-已存在 1-未存在
# 示例: check_php_volumes -c -d "./portaine" -p 
function check_php_volumes()
{
  local create=1 dir="./php" prompt=1 ret=1
  local OPTIND OPTARG arg_all
  while getopts "cd:p" arg_all; do
    case $arg_all in
      c)
        create=0 ;;
      d)
        dir=(${OPTARG//,/ }) ;;
      p)
        prompt=0 ;;
      ?)
        [ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
        exit 1 ;;
    esac
  done
  shift $((OPTIND-1))

  [ -d $dir"/www" ] && ret=0

  if [ ! -d $dir"/www" -a "$create" = 0 ]; then
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Creating php configuration files.${CLR_NO}"

    mkdir -p $dir"/www"

    ret=0
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} php configuration folder is ready."
  fi

  return $ret
}

# 检查nginx挂载卷
# 输入:
#       -c 不存在时自动创建
#       -d 指定配置文件所在目录
#       -p 显示提示信息
# 输出: 是否存在 0-已存在 1-未存在
# 示例: check_portainernginx_volumes -c -d "./nginx" -p 
function check_nginx_volumes()
{
  local create=1 dir="./nginx" prompt=1 ret=1
  local OPTIND OPTARG arg_all
  while getopts "cd:p" arg_all; do
    case $arg_all in
      c)
        create=0 ;;
      d)
        dir=(${OPTARG//,/ }) ;;
      p)
        prompt=0 ;;
      ?)
        [ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
        exit 1 ;;
    esac
  done
  shift $((OPTIND-1))

  [ -d $dir"/conf" ] && ret=0

  if [ ! -d $dir"/conf" -a "$create" = 0 ]; then
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Creating nginx configuration files.${CLR_NO}"

    mkdir -p $dir"/conf"
    mkdir -p $dir"/log"

    ret=0
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} nginx configuration folder is ready."
  fi

  return $ret
}

# 添加nginx配置
# 输入:
#       -a 追加模式
#       -d 指定配置文件所在目录
#       -n 服务名称
#       -p 显示提示信息
# 输出: 是否存在 0-已添加 1-未添加
# 示例: add_nginx_conf -a -d "./nginx" -n "portainer" -p 
function add_nginx_conf()
{
  local append=1 dir="./nginx" prompt=1 ret=1
  local OPTIND OPTARG arg_all
  while getopts "ad:n:p" arg_all; do
    case $arg_all in
      a)
        append=0 ;;
      d)
        dir=(${OPTARG//,/ }) ;;
      n)
        name=(${OPTARG//,/ }) ;;
      p)
        prompt=0 ;;
      ?)
        [ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
        exit 1 ;;
    esac
  done
  shift $((OPTIND-1))

  [ ! -d $dir"/conf" ] && ret=1 ; echo 

  if [ ! -d $dir"/conf" ]; then
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} add nginx config error, nginx configuration folder not exist"
    ret=1
  else
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Adding nginx configuration for ${name}.${CLR_NO}"

    local domain ip port
    read -p $"Input the domain name of the server: " domain
    read -p $"Input the local IP of the server: " ip
    read -p $"Input the local port of the ${name} service: " port

    local file_conf=$dir"/conf/"$name".conf"

    conf="
      # "${name}"\n
      server {\n
      \tlisten\t\t80;\n
      \tserver_name\t"${domain}";\n
      \taccess_log\t/var/log/nginx/"${domain}"_docker_access.log;\n
      \terror_log\t/var/log/nginx/"${domain}"_docker_error.log info;\n
      \n
      \tlocation / {\n
      \t\tproxy_pass\t\t\thttp://"${ip}":"${port}"/;\n
      \t\tproxy_read_timeout\t\t300;\n
      \t\tproxy_connect_timeout\t\t300;\n
      \t\tproxy_redirect\t\t\toff;\n
      \n
      \t\tproxy_set_header\t\tX-Forwarded-Proto\t\$scheme;\n
      \t\tproxy_set_header\t\tHost\t\t\t\$http_host;\n
      \t\tproxy_set_header\t\tX-Real-IP\t\t\$remote_addr;\n
      \t}\n
      }"

    [ "$append" != 0 ] && echo -e $conf > $file_conf
    [ "$append" = 0 ] && echo -e $conf >> $file_conf

    ret=0
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} nginx configuration for ${name} is ready."
  fi

  return $ret
}
