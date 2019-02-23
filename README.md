# linux shell scripts
* deploy_vpn.sh : VPS一键部署各种FQ和VPN服务的脚本，VPN服务包含shadowsocks、shadowsocks-r、ocserv、L2TP，基础服务包括nginx及portainer，服务全部以Docker方式部署，Docker Image分别取自：
** teddysun/shadowsocks-libev:alpine
** teddysun/shadowsocks-r:alpine
** tommylau/ocserv 
** teddysun/l2tp:alpine
** nginx:alpine
** portainer/portainer
安装方法：
curl -O https://raw.githubusercontent.com/waylonwang/sh-scripts/master/deploy_vpn.sh
chmod +x deploy_vpn.sh
./deploy_vpn.sh
