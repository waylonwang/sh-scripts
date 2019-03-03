# !/bin/bash

[ -z $REF_CONFLICT_FLAG ] && source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/public_const.sh)

function init_config_folder()
{
  [ ! -d "docker" ] && mkdir docker

  cd docker

  source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/check_base_volumes.sh)
  check_portainer_volumes -c -p
  check_nginx_volumes -c -p

  [ ! -e "./nginx/conf/portainer.conf" ] && add_nginx_conf -d "./nginx" -n "portainer" -p
}

function download_compose_file()
{
  echo -e "${CLR_FG_YL}Downloading the latest compose files and scripts.${CLR_NO}"
  curl -O -s https://raw.githubusercontent.com/waylonwang/docker-compose/master/base.yml
  curl -O -s https://raw.githubusercontent.com/waylonwang/docker-compose/master/compose_base.sh
  echo -e "${CLR_FG_GR}[OK]${CLR_NO} compose files and scripts has downloaded."
}

function compose_all_file()
{
  echo -e "${CLR_FG_YL}Composing the base services.${CLR_NO}"
  chmod +x compose_base.sh
  ./compose_base.sh
  echo -e "${CLR_FG_GR}[OK]${CLR_NO} all base services is up."
}

# master process
function main(){
  source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/check_docker_env.sh)
  echo -e "${CLR_FG_PU}Start deploying docker Service${CLR_NO}"

  check_os -t "centos" -p
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
