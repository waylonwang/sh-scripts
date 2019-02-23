#! /bin/bash

check_docker_installed()
{
  if [ -x "$(command -v docker)" ]; then
      echo -e "\033[35m`docker --version`\033[0m"
      echo -e "\033[32m[OK] docker has been installed.\033[0m"
  else
      echo -e "\033[33m\Installing docker.\033[0m"
      yum -y install docker
      echo -e "\033[35m`docker --version`\033[0m"
      systemctl start docker
      systemctl enable docker
      echo -e "\033[32m[OK] docker has been installed.\033[0m"
  fi
}

check_docker_actived()
{
  local status=`systemctl show --property ActiveState docker | sed -n -r '1,1 s/ActiveState=(.*)/\1/p'`
  if [ $status ]; then
    if [ $status == "active" ]; then
      echo -e "\033[32m[OK] docker is running.\033[0m"
    else
      echo -e "\033[33mStarting docker.\033[0m"
      systemctl start docker
      status=`systemctl show --property ActiveState docker | sed -n -r '1,1 s/ActiveState=(.*)/\1/p'`
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
  local file_name = "nginx/conf/"$domain".conf"
  local domain
  local local
  local port
  echo -e "\033[31mWhat is the domain name of the server?\033[0m"
  read domain
  echo -e "\033[31mWhat is local IP?\033[0m"
  read local
  echo -e "\033[31mWhat is the portainer local port?\033[0m"
  read port

  echo "server {" >> $file_name
  echo "        listen          80;" >> $file_name
  echo "        server_name     "$domain";" >> $file_name
  echo "        access_log      /var/log/nginx/"$domain"_docker_access.log;" >> $file_name
  echo "        error_log       /var/log/nginx/"$domain"_docker_error.log info;" >> $file_name
  echo " " >> $file_name
  echo "        location / {" >> $file_name
  echo "                proxy_pass              http://"$local":"$port"/;" >> $file_name
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
  local file_name = "shadowsocks/conf/config.json"
  local port
  local password
  echo -e "\033[31mWhat is the port of shadowsocks service?\033[0m"
  read port
  echo -e "\033[31mWhat is the password of the shadowsocks service?\033[0m"
  read password

  echo "{" >> $file_name
  echo "        \"server\":\"0.0.0.0\"," >> $file_name
  echo "        \"server_port\":"$port"," >> $file_name
  echo "        \"password\":\""$password"\"," >> $file_name
  echo "        \"timeout\":300," >> $file_name
  echo "        \"method\":\"aes-256-cfb\"," >> $file_name
  echo "        \"fast_open\":true," >> $file_name
  echo "        \"nameserver\":\"8.8.8.8\"," >> $file_name
  echo "        \"mode\":\"tcp_and_udp\"," >> $file_name 
  echo "}" >> $file_name
}

create_shadowsocksr_conf()
{
  local file_name = "shadowsocks-r/conf/config.json"
  local port
  local password
  echo -e "\033[31mWhat is the port of the shadowsocks-r service?\033[0m"
  read port
  echo -e "\033[31mWhat is the password of the shadowsocks-r service?\033[0m"
  read password

  echo "{" >> $file_name
  echo "        \"server\":\"0.0.0.0\"," >> $file_name
  echo "        \"server_ipv6\":\"::\"," >> $file_name
  echo "        \"server_port\":"$port"," >> $file_name
  echo "        \"local_address\":\"127.0.0.1\"," >> $file_name
  echo "        \"local_port\":1080," >> $file_name
  echo "        \"password\":\""$password"\"," >> $file_name
  echo "        \"timeout\":300," >> $file_name
  echo "        \"method\":\"aes-256-cfb\"," >> $file_name
  echo "        \"protocol\":\"origin\"," >> $file_name 
  echo "        \"protocol_param\":\"\"," >> $file_name 
  echo "        \"obfs\":\"plain\"," >> $file_name 
  echo "        \"obfs_param\":\"\"," >> $file_name 
  echo "        \"redirect\":\"\"," >> $file_name 
  echo "        \"dns_ipv6\":false," >> $file_name 
  echo "        \"fast_open\":true," >> $file_name
  echo "        \"workers\":1," >> $file_name
  echo "}" >> $file_name
}

create_l2tp_conf()
{
  local file_name = "l2tp/conf/l2tp.env"
  local user
  local password
  local psk
  echo -e "\033[31mWhat is the l2tp username?\033[0m"
  read user
  echo -e "\033[31mWhat is the l2tp password?\033[0m"
  read password
  echo -e "\033[31mWhat is the l2tp psk?\033[0m"
  read psk

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
  local file_name = "ocserv/conf/ocserv.env"
  local domain
  local org
  echo -e "\033[31mWhat is the cert domain name of the ocserv service?\033[0m"
  read domain
  echo -e "\033[31mWhat is the cert org name of the ocserv service?\033[0m"
  read org
  echo -e "\033[31mWhat is the username to add?\033[0m"
  read ocserv_user

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
  curl -O https://raw.githubusercontent.com/waylonwang/docker-compose/master/base.yml
  curl -O https://raw.githubusercontent.com/waylonwang/docker-compose/master/vpn.yml
  curl -O https://raw.githubusercontent.com/waylonwang/docker-compose/master/compose_base.sh
  curl -O https://raw.githubusercontent.com/waylonwang/docker-compose/master/compose_vpn.sh
  echo -e "\033[32m[OK] compose files and scripts has downloaded.\033[0m"
}

compose_all_file()
{
  echo -e "\033[33mComposing the base services.\033[0m"
  ./compose_base.sh
  echo -e "\033[32m[OK] all base services is up.\033[0m"
  echo -e "\033[33mComposing the VPN services.\033[0m"
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

error_status="off"
ocserv_init="off"

check_docker_installed

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
