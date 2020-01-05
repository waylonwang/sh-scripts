# !/bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本实现了在VPS中部署各种PHP服务
# 本脚本使用方法:
#  curl -L https://raw.githubusercontent.com/waylonwang/sh-scripts/master/vps_deploy_php.sh -o vps_deploy_php.sh && chmod +x vps_deploy_php.sh && ./vps_deploy_php.sh
#
# 作者:waylon@waylon.wang
#*************************************************************************************
# 如环境变量GIT_RAW_SH和GIT_RAW_DOCKER未设置则默认设为github地址
[ -z ${GIT_RAW_SH} ] && GIT_RAW_SH="https://raw.githubusercontent.com/waylonwang/sh-scripts/master"
[ -z ${GIT_RAW_DOCKER} ] && GIT_RAW_DOCKER="https://raw.githubusercontent.com/waylonwang/docker-compose/master"
# 变量GIT_RAW_SH和GIT_RAW_DOCKER设置完成
[ -z ${REF_CONFLICT_FLAG} ] && source <(curl -s ${GIT_RAW_SH}/lib/public_const.sh)

function init_config_folder()
{
  [ ! -d "docker" ] && mkdir docker

  cd docker

  source <(curl -s ${GIT_RAW_SH}/lib/check_base_volumes.sh)
  check_php_volumes -c -p

  [ ! -e "./nginx/conf/portainer.conf" ] && add_nginx_conf -d "./nginx" -n "portainer" -p
}

function download_compose_file()
{
  echo -e "${CLR_FG_YL}Downloading the latest compose files and scripts.${CLR_NO}"
  if [ "$(get_os)" = "raspbian" ]; then
    curl -O -s ${GIT_RAW_DOCKER}/php_raspbian.yml
    curl -O -s ${GIT_RAW_DOCKER}/compose_php.sh
  else
    curl -O -s ${GIT_RAW_DOCKER}/php.yml
    curl -O -s ${GIT_RAW_DOCKER}/compose_php.sh
  fi
  echo -e "${CLR_FG_GR}[OK]${CLR_NO} compose files and scripts has downloaded."
}

function compose_all_file()
{
  echo -e "${CLR_FG_YL}Composing the base services.${CLR_NO}"
  chmod +x compose_php.sh
  ./compose_php.sh
  echo -e "${CLR_FG_GR}[OK]${CLR_NO} all base services is up."
}

# master process
function main(){
  source <(curl -s ${GIT_RAW_SH}/lib/check_docker_env.sh)
  echo -e "${CLR_FG_PU}Start deploying docker Service${CLR_NO}"

  check_os -t "centos,raspbian" -p
  if [ $? -eq 0 ]; then
    check_docker_install -a -i -p -s -v
    check_compose_install -i -p -v
    check_docker_active -s

    if [ $? != 0 ]; then
      echo -e "${CLR_FG_RD}[Fault]${CLR_NO} docker failed to startup."
    else
      init_config_folder
      download_compose_file
      compose_all_file
      
      echo -e "${CLR_FG_GR}[OK]${CLR_NO} docker Service deployment has been completed."
    fi
  fi
}

main
