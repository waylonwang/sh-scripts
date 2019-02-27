#!/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本实现了数据库相关的脚本功能
#  - 检查mysql挂载卷是否符已存在
#  - 检查phpmyadmin挂载卷是否符已存在
# 本脚本可在其他脚本中引用:
#  source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/check_db_volumes.sh)
# 
# 作者:waylon@waylon.wang
#*************************************************************************************

source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/check_docker_env.sh)

# 检查mysql挂载卷
# 输入:
#       -c 不存在时自动创建
#       -d 指定配置文件所在目录
#       -p 显示提示信息
# 输出: 是否存在 0-已存在 1-未存在
# 示例: check_mysql_volumes -c -d "./mysql" -p 
function check_mysql_volumes()
{
  local create=1 dir="./mysql/mariadb10" prompt=1 ret=1
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

  if [ ! -d $dir"/conf" -a "$create" = 0 ]; then
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Creating mysql configuration files.${CLR_NO}"

    local password
    read -p $'Input the ${CLR_FG_CY}password${CLR_NO} of the root: ' password

    local file_env=$dir"/conf/mysql.env"
    local file_conf=$dir"/conf/my.cnf"

    env="MYSQL_ROOT_PASSWORD=${password}"
    conf="
      [mysqld]\n
      \n
      # 数据库默认字符集,主流字符集支持一些特殊表情符号（特殊表情符占用4个字节\n
      character-set-server = utf8mb4\n
      \n
      # 数据库字符集对应一些排序等规则，注意要和character-set-server对应\n
      collaticonfon-server = utf8mb4_general_ci\n
      \n
      # 修正 OperationalError: (2006, 'MySQL server has gone away') 错误\n
      wait_timeout=100000\n
      \n
      # 日志文件名\n
      log-bin = /var/log/mysql/mysql-bin\n
      \n
      # 主数据库端ID号\n
      server-id = 10\n
      \n
      # 日志保留时间\n
      expire_logs_days = 10\n
      \n
      # 控制binlog的写入频率。每执行多少次事务写入一次\n
      # 这个参数性能消耗很大，但可减小MySQL崩溃造成的损失\n
      sync_binlog = 5\n
      \n
      # 支持xa两段式事务提交\n
      #innodb_support_xa = true\n
      \n
      # 日志格式，建议mixed\n
      # statement 保存SQL语句\n
      # row 保存影响记录数据\n
      # mixed 前面两种的结合\n
      binlog_format = mixed\n
      "

    mkdir -p $dir"/conf"
    mkdir -p $dir"/log"
    mkdir -p $dir"/data"
    echo -e $env > $file_env
    echo -e $conf > $file_conf

    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} mysql configuration folder is ready."
  fi
}

# 检查phpmyadmin挂载卷
# 输入:
#       -c 不存在时自动创建
#       -d 指定配置文件所在目录
#       -p 显示提示信息
# 输出: 是否存在 0-已存在 1-未存在
# 示例: check_phpmyadmin_volumes -c -d "./phpmyadmin" -p 
function check_phpmyadmin_volumes()
{
  local create=1 dir="./phpmyadmin" prompt=1 ret=1
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

  if [ ! -d $dir"/conf" -a "$create" = 0 ]; then
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_YL}Creating phpmyadmin configuration files.${CLR_NO}"

    local password
    read -p $'Input the ${CLR_FG_CY}password${CLR_NO} of the root: ' password

    local file_env=$dir"/conf/phpmyadmin.env"

    env="
      PMA_ARBITRARY=1
      PMA_HOST=mysql
      PMA_VERBOSE=db
      PMA_PORT=3306
      PMA_USER=root
      PMA_PASSWORD=${password}
    "
    
    mkdir -p $dir"/conf"
    mkdir -p $dir"/theme"
    echo -e $env > $file_env

    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} phpmyadmin configuration folder is ready."
  fi
}
