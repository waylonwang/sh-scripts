#! /bin/bash
# Copyright (c) 2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本实现了在VPS中部署各种VPN类服务
# 本脚本使用方法:
#  curl -L https://raw.githubusercontent.com/waylonwang/sh-scripts/master/vps_deploy_vpn.sh -o vps_deploy_vpn.sh && chmod +x vps_deploy_vpn.sh && ./vps_deploy_vpn.sh
#
# 作者:waylon@waylon.wang
#*************************************************************************************
# 如环境变量GIT_RAW_SH和GIT_RAW_DOCKER未设置则默认设为github地址
[ -z ${GIT_RAW_SH} ] && GIT_RAW_SH="https://raw.githubusercontent.com/waylonwang/sh-scripts/master"
[ -z ${GIT_RAW_DOCKER} ] && GIT_RAW_DOCKER="https://raw.githubusercontent.com/waylonwang/docker-compose/master"
# 变量GIT_RAW_SH和GIT_RAW_DOCKER设置完成

check_docker_installed()
{
  if [ -x "$(command -v docker)" ]; then
    echo -e "\033[35m`docker --version`\033[0m"
    echo -e "\033[32m[OK] docker has been installed.\033[0m"
  else
    echo -e "\033[33mInstalling docker.\033[0m"
    yum -y install docker
    echo -e "\033[35m`docker --version`\033[0m"
    systemctl start docker
    systemctl enable docker
    echo -e "\033[32m[OK] docker has been installed.\033[0m"
  fi
}

check_compose_installed()
{
  if [ -x "$(command -v docker-compose)" ]; then
    echo -e "\033[35m`docker-compose --version`\033[0m"
    echo -e "\033[32m[OK] docker-compose has been installed.\033[0m"
  else
    echo -e "\033[33mInstalling docker-compose.\033[0m"
    curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
    chmod +x /usr/bin/docker-compose
    echo -e "\033[35m`docker-compose --version`\033[0m"
    echo -e "\033[32m[OK] docker-compose has been installed.\033[0m"
  fi
}

check_docker_actived()
{
  local status=`systemctl is-active docker`
  if [ $status ]; then
    if [ $status == "active" ]; then
      echo -e "\033[32m[OK] docker is running.\033[0m"
    else
      echo -e "\033[33mStarting docker.\033[0m"
      systemctl start docker
      status=`systemctl is-active docker`
      if [ $status ]; then
        if [ $status == "active" ]; then
          echo -e "\033[32m[OK] docker is running.\033[0m"
        else
          error_status="on"
        fi
      else
        error_status="on"
      fi
    fi
  else
    error_status="on"
  fi
}

create_nginx_conf()
{
  local domain
  local ip="127.0.0.1"
  local port
  read -p $'Input the \e[36mdomain name\e[0m of the server: ' domain
  #read -p $'Input the \e[36mlocal IP\e[0m of the server: ' ip
  read -p $'Input the \e[36mlocal port\e[0m of the portainer service: ' port
  local file_name="nginx/conf/"$domain".conf"
  
  if [ ! $port ]; then
    port="9000"
  fi
  
  echo "server {" >> $file_name
  echo "        listen          80;" >> $file_name
  echo "        server_name     "$domain";" >> $file_name
  echo "        access_log      /var/log/nginx/"$domain"_docker_access.log;" >> $file_name
  echo "        error_log       /var/log/nginx/"$domain"_docker_error.log info;" >> $file_name
  echo " " >> $file_name
  echo "        location / {" >> $file_name
  echo "                proxy_pass              http://"$ip":"$port"/;" >> $file_name
  echo "                proxy_read_timeout      300;" >> $file_name
  echo "                proxy_connect_timeout   300;" >> $file_name
  echo "                proxy_redirect          off;" >> $file_name
  echo " " >> $file_name
  echo "                proxy_set_header        X-Forwarded-Proto \$scheme;" >> $file_name
  echo "                proxy_set_header        Host              \$http_host;" >> $file_name
  echo "                proxy_set_header        X-Real-IP         \$remote_addr;" >> $file_name
  echo "        }" >> $file_name
  echo "}" >> $file_name
}

create_shadowsocks_conf()
{
  local file_name="shadowsocks/conf/config.json"
  local port
  local password
  read -p $'Input the \e[36mport\e[0m of the shadowsocks service: ' port
  read -p $'Input the \e[36mpassword\e[0m of the shadowsocks service: ' password

  echo "{" >> $file_name
  echo "    \"server\":\"0.0.0.0\"," >> $file_name
  echo "    \"server_port\":"$port"," >> $file_name
  echo "    \"password\":\""$password"\"," >> $file_name
  echo "    \"timeout\":300," >> $file_name
  echo "    \"method\":\"aes-256-cfb\"," >> $file_name
  echo "    \"fast_open\":true," >> $file_name
  echo "    \"nameserver\":\"8.8.8.8\"," >> $file_name
  echo "    \"mode\":\"tcp_and_udp\"" >> $file_name 
  echo "}" >> $file_name
}

create_shadowsocksr_conf()
{
  local file_name="shadowsocks-r/conf/config.json"
  local port
  local password
  read -p $'Input the \e[36mport\e[0m of the shadowsocks-r service: ' port
  read -p $'Input the \e[36mpassword\e[0m of the shadowsocks-r service: ' password

  echo "{" >> $file_name
  echo "    \"server\":\"0.0.0.0\"," >> $file_name
  echo "    \"server_ipv6\":\"::\"," >> $file_name
  echo "    \"server_port\":"$port"," >> $file_name
  echo "    \"local_address\":\"127.0.0.1\"," >> $file_name
  echo "    \"local_port\":1080," >> $file_name
  echo "    \"password\":\""$password"\"," >> $file_name
  echo "    \"timeout\":120," >> $file_name
  echo "    \"method\":\"aes-256-cfb\"," >> $file_name
  echo "    \"protocol\":\"origin\"," >> $file_name 
  echo "    \"protocol_param\":\"\"," >> $file_name 
  echo "    \"obfs\":\"plain\"," >> $file_name 
  echo "    \"obfs_param\":\"\"," >> $file_name 
  echo "    \"redirect\":\"\"," >> $file_name 
  echo "    \"dns_ipv6\":false," >> $file_name 
  echo "    \"fast_open\":true," >> $file_name
  echo "    \"workers\":1" >> $file_name
  echo "}" >> $file_name
}

create_l2tp_conf()
{
  local file_name="l2tp/conf/l2tp.env"
  local user
  local password
  local psk
  read -p $'Input the \e[36musername\e[0m of the l2tp service: ' user
  read -p $'Input the \e[36mpassword\e[0m of the l2tp service: ' password
  read -p $'Input the \e[36mpsk\e[0m of the l2tp service: ' psk

  echo "VPN_IPSEC_PSK="$psk >> $file_name
  echo "VPN_USER="$user >> $file_name
  echo "VPN_PASSWORD="$password >> $file_name
  echo "VPN_PUBLIC_IP=" >> $file_name
  echo "VPN_L2TP_NET=" >> $file_name
  echo "VPN_L2TP_LOCAL=" >> $file_name
  echo "VPN_L2TP_REMOTE=" >> $file_name
  echo "VPN_XAUTH_NET=" >> $file_name
  echo "VPN_XAUTH_REMOTE=" >> $file_name
  echo "VPN_DNS1=" >> $file_name
  echo "VPN_DNS2=" >> $file_name
}

create_ocserv_conf()
{
  local file_name="ocserv/conf/ocserv.env"
  local domain
  local org
  read -p $'Input the \e[36mcert domain name\e[0m of the ocserv service: ' domain
  read -p $'Input the \e[36mcert org name\e[0m of the ocserv service: ' org
  read -p $'Input the \e[36musername\e[0m add to ocserv service: ' ocserv_user

  ocserv_init="on"

  echo "CA_CN="$domain" CA" >> $file_name
  echo "CA_ORG="$org >> $file_name
  echo "CA_DAYS=9999" >> $file_name
  echo "SRV_CN="$domain >> $file_name
  echo "SRV_ORG="$org >> $file_name
  echo "SRV_DAYS=9999" >> $file_name
  echo "NO_TEST_USER=1" >> $file_name
}

init_config_folder()
{
  if [ ! -d "docker" ]; then
    echo -e "\033[33mNot yet initialized, creating Docker folder.\033[0m"
    mkdir docker
  fi

  cd docker

  if [ ! -d "docker" ]; then
    echo -e "\033[33mCreating portainer configuration files.\033[0m"
    mkdir docker
    mkdir docker/portainer
    mkdir docker/portainer/data
    echo -e "\033[32m[OK] portainer configuration folder is ready.\033[0m"
  fi

  if [ ! -d "nginx" ]; then
    echo -e "\033[33mCreating nginx configuration folder.\033[0m"
    mkdir nginx
    mkdir nginx/conf
    mkdir nginx/log
    create_nginx_conf
    echo -e "\033[32m[OK] nginx configuration folder is ready.\033[0m"
  fi

  if [ ! -d "shadowsocks" ]; then
    echo -e "\033[33mCreating shadowsocks configuration folder.\033[0m"
    mkdir shadowsocks
    mkdir shadowsocks/conf
    create_shadowsocks_conf
    echo -e "\033[32m[OK] shadowsocks configuration folder is ready.\033[0m"
  fi

  if [ ! -d "shadowsocks-r" ]; then
    echo -e "\033[33mCreating shadowsocks-r configuration folder.\033[0m"
    mkdir shadowsocks-r
    mkdir shadowsocks-r/conf
    create_shadowsocksr_conf
    echo -e "\033[32m[OK] shadowsocks-r configuration folder is ready.\033[0m"
  fi

  if [ ! -d "l2tp" ]; then
    echo -e "\033[33mCreating l2tp configuration folder.\033[0m"
    mkdir l2tp
    mkdir l2tp/conf
    mkdir l2tp/modules
    create_l2tp_conf
    echo -e "\033[32m[OK] l2tp configuration folder is ready.\033[0m"
  fi

  if [ ! -d "ocserv" ]; then
    echo -e "\033[33mCreating ocserv configuration folder.\033[0m"
    mkdir ocserv
    mkdir ocserv/conf
    mkdir ocserv/data
    create_ocserv_conf
    echo -e "\033[32m[OK] ocserv configuration folder is ready.\033[0m"
  fi
}

download_compose_file()
{
  echo -e "\033[33mDownloading the latest compose files and scripts.\033[0m"
  curl -O ${GIT_RAW_DOCKER}/base.yml
  curl -O ${GIT_RAW_DOCKER}/vpn.yml
  curl -O ${GIT_RAW_DOCKER}/compose_base.sh
  curl -O ${GIT_RAW_DOCKER}/compose_vpn.sh
  echo -e "\033[32m[OK] compose files and scripts has downloaded.\033[0m"
}

compose_all_file()
{
  echo -e "\033[33mComposing the base services.\033[0m"
  chmod 777 compose_base.sh
  ./compose_base.sh
  echo -e "\033[32m[OK] all base services is up.\033[0m"
  echo -e "\033[33mComposing the VPN services.\033[0m"
  chmod 777 compose_vpn.sh
  ./compose_vpn.sh
  echo -e "\033[32m[OK] all VPN services is up.\033[0m"
}

ocserv_add_users()
{
  echo -e "\033[33mOcserv adding user: $ocserv_user \033[0m"
  docker exec -ti ocserv ocpasswd -c /etc/ocserv/ocpasswd -g "Route,All" "$ocserv_user"
  echo -e "\033[32m[OK] ocserv user has added.\033[0m"
}

# master process

echo -e "\033[35mStart deploying VPN\033[0m"

source /etc/os-release

error_status="off"
ocserv_init="off"

if [ $ID == "centos" ]; then
  check_docker_installed

  check_compose_installed

  check_docker_actived

  if [ $error_status == "on" ]; then
    echo -e "\033[31m[Fault] docker failed to startup.\033[0m"
  else
    init_config_folder

    download_compose_file

    compose_all_file

    if [ $ocserv_init == "on" ]; then
      ocserv_add_users
    fi

    echo -e "\033[32m[OK] VPN deployment has been completed.\033[0m"
  fi
else
  echo -e "\033[31m[Fault] This script only supports CentOS.\033[0m"
fi
