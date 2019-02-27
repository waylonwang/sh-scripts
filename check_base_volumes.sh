#! /bin/bash

source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/check_docker_env.sh)

function check_portainer_volumes()
{
  local create=1 dir="./portaine" prompt=1 ret=1
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

    local domain ip port
    read -p $'Input the ${CLR_FG_CY}domain name${CLR_NO} of the server: ' domain
    read -p $'Input the ${CLR_FG_CY}local IP${CLR_NO} of the server: ' ip
    read -p $'Input the ${CLR_FG_CY}local port${CLR_NO} of the portainer service: ' port

    local file_conf=$dir"/conf/"$domain".conf"

    conf="
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

    mkdir -p $dir"/conf"
    mkdir -p $dir"/log"
    echo -e $conf > $file_conf

    ret=0
    [ "$prompt" = 0 ] && echo -e "${CLR_FG_GR}[OK]${CLR_NO} nginx configuration folder is ready."
  fi

  return $ret
}
