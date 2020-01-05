# Linux shell scripts
[![License](https://img.shields.io/badge/License-MIT-orange.svg)](https://github.com/waylonwang/sh-scripts/blob/master/LICENSE)

常用Linux shell脚本集合

## 基础脚本

### public_const.sh
基础常量，此脚本可在其他脚本中引用

引用方法：
```shell
source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/public_const.sh)
```

### check_os_env.sh
检查操作系统是否符合要求，此脚本可在其他脚本中引用

引用方法：
```shell
source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/check_os_env.sh)
```

### check_docker_env.sh
检查docker环境是否已经安装及运行，此脚本可在其他脚本中引用

引用方法：
```shell
source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/check_docker_env.sh)
```

### check_base_volumes.sh
检查基础相关(nginx、portainer)的挂载卷是否已存在，此脚本可在其他脚本中引用

引用方法：
```shell
source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/check_base_volumes.sh)
```


### check_db_volumes.sh
检查数据库相关(mysql、phpmyadmin)的挂载卷是否已存在，此脚本可在其他脚本中引用

引用方法：
```shell
source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/lib/check_db_volumes.sh)
```


## 功能脚本

### VPS部署相关功能

#### vps_deploy_vpn.sh
VPS一键部署各种VPN类服务的脚本，VPN类服务包含shadowsocks、shadowsocks-r、ocserv、L2TP等，基础服务则包括nginx及portainer，以上服务全部以docker容器方式部署，docker镜像分别取自：
* teddysun/shadowsocks-libev:alpine
* teddysun/shadowsocks-r:alpine
* tommylau/ocserv 
* teddysun/l2tp:alpine
* nginx:alpine
* portainer/portainer

> 此脚本目前暂时仅支持CentOS系统
>
> 此脚本由waylonwang/docker-compose的编排脚本及其sh执行脚本提供docker容器部署的支持
> * base.yml
> * vpn.yml

安装方法：

```shell
curl -O https://raw.githubusercontent.com/waylonwang/sh-scripts/master/vps_deploy_vpn.sh

chmod +x vps_deploy_vpn.sh

./vps_deploy_vpn.sh
```

#### vps_deploy_docker.sh
VPS一键部署docker环境的脚本，容器服务包含docker、docker-compose，基础服务则包括nginx及portainer，基础服务全部以docker容器方式部署，docker镜像分别取自：
* nginx:alpine
* portainer/portainer

> 此脚本目前支持RH系、Debian操作系统
>
> 此脚本由waylonwang/docker-compose的编排脚本及其sh执行脚本提供docker容器部署的支持
> * base.yml

安装方法：

```shell
curl -L -O https://raw.githubusercontent.com/waylonwang/sh-scripts/master/vps_deploy_docker.sh && chmod +x vps_deploy_docker.sh && ./vps_deploy_docker.sh
```

#### vps_deploy_db.sh
VPS一键部署数据库环境的脚本，数据库服务则包括mysql及phpmyadmin，基础服务则包括nginx及portainer，以上服务全部以docker容器方式部署，docker镜像分别取自：
* mariadb:latest
* phpmyadmin/phpmyadmin:latest

> 此脚本目前支持RH系、Debian操作系统
>
> 此脚本由waylonwang/docker-compose的编排脚本及其sh执行脚本提供docker容器部署的支持
> * base.yml
> * db.yml

安装方法：

```shell
curl -L -O https://raw.githubusercontent.com/waylonwang/sh-scripts/master/vps_deploy_db.sh && chmod +x vps_deploy_db.sh && ./vps_deploy_db.sh
```

### Synology NAS管理关功能

#### synology_acme_install.sh
Synology NAS自动化创建或更新Let's Encrypt SSL证书

> 此脚本适用于Synology DSM V6.x版本
>
> 此脚本基于Neilpang/acme.sh，仅支持ACME V2.0协议通过域名验证获取泛域名证书

安装方法：

```shell
curl -O https://raw.githubusercontent.com/waylonwang/sh-scripts/master/synology_acme_install.sh

chmod +x synology_acme_install.sh

./synology_acme_install.sh  -m create -d domain.com -n cert_name
```

### Proxmox VE管理关功能

#### pve_lxc_docker_patch.sh
在PVE中解除apparmor限制，允许LXC容器中拉取docker镜像

> 此脚本适用于PVE V5.x~V6.x版本
>
安装方法：

```shell
curl -L -O https://raw.githubusercontent.com/waylonwang/sh-scripts/master/pve_lxc_docker_patch.sh && chmod +x pve_lxc_docker_patch.sh && ./pve_lxc_docker_patch.sh
```

### 其他通用功能

#### ubuntu_replace_aliyun_apt_repository.sh
将apt源更改为阿里云镜像

> 此脚本适用于RH系、Debian操作系统

安装方法：

```shell
curl -L -O https://raw.githubusercontent.com/waylonwang/sh-scripts/master/ubuntu_replace_aliyun_apt_repository.sh && chmod +x ubuntu_replace_aliyun_apt_repository.sh && ./ubuntu_replace_aliyun_apt_repository.sh
```
