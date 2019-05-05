#! /bin/bash
# Copyright (c) 2018-2019 Waylon Wang <waylon@waylon.wang>
# Licensed under the MIT License

#*************************************************************************************
# 本脚本基于Neilpang/acme.sh，用于Synology NAS自动化创建或更新Let's Encrypt SSL证书
# 本脚本适用于Synology DSM V6.x版本，仅支持ACME V2.0协议通过域名验证获取泛域名证书
# 
# 作者:waylon@waylon.wang
#*************************************************************************************

# 修改以下内容为自己的域名服务商信息，具体的DNS类型或环境变量名称请参见Neilpang/acme.sh
export CX_Key="ChangeToYourKey"
export CX_Secret="ChangeToYourSecret"
DNS="dns_cx"
# 修改以下内容为自己安装的acme.sh的路径，如采用默认安装路径则无须修改
ACME_PATH="/usr/local/share/acme.sh"

# 以下为处理脚本，不理解的请勿随意修改
NAME="installcert.sh"
VER="1.0"
URL="https://github.com/waylonwang/sh-scripts/synology_acme_install.sh"
HELP="用法: ./${NAME} <命令> [<参数>]\n
命令:\n
\t-m create\t\t模式：创建证书\n
\t-m update\t\t模式：更新证书\n
\t-h\t\t显示本帮助\n
参数:\n
\t-d [域名]\t\t指定处理证书的对应的域名\n
\t-n [名称(描述)]\t\t指定处理证书的对应的名称(描述)，如不指定则处理默认证书\n
\t-f\t\t更新证书时，忽略证书到期日强制更新"
# 颜色
CLR_YL="\033[1;33m"
CLR_RD="\033[0;31m"
CLR_NO="\033[0m"
# 退出状态
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ICLR_NOORRECT=2
EXIT_COMMAND_NOT_FOUND=127
# acme.sh配置文件路径
ACME_CONFIG_HOME="${ACME_PATH}/config"
# 证书存储路径
# CERT_FOLDER="/usr/syno/etc/certificate/system/default"
# CERT_ARCHIVE="/usr/syno/etc/certificate/_archive/$(cat /usr/syno/etc/certificate/_archive/DEFAULT)"
# CERT_REVERSEPROXY="/usr/syno/etc/certificate/ReverseProxy"
CERT_FOLDER="/usr/syno/etc/certificate"
CERT_ID=""
CERT_ARCHIVE=""
# 输入参数解析的变量
FORCE=1 
MODE=1 
NAME="default"
DOMAIN=""

  
function parse_cert_id()
{
    if [ ! -f "JSON.sh" ]; then
        curl -O -s https://raw.githubusercontent.com/dominictarr/JSON.sh/master/JSON.sh
        chmod +x JSON.sh
    fi
    if [ "${NAME}" != "default" ]; then
        CERT_ID=`cat ${CERT_FOLDER}/_archive/INFO | ./JSON.sh | grep '\[".*","desc"\].*"${NAME}"' | sed -r 's/\["(.*)",.*/\1/'`
    else
    	  CERT_ID=`cat ${CERT_FOLDER}/_archive/DEFAULT`
    fi
    CERT_ARCHIVE=${CERT_FOLDER}/_archive/${CERT_ID}
}

function create_cert()
{
    $ACME_PATH/acme.sh --issue -d $DOMAIN -d *.$DOMAIN --dns $DNS \
            --certpath $CERT_ARCHIVE/cert.pem \
            --keypath $CERT_ARCHIVE/privkey.pem \
            --fullchainpath $CERT_ARCHIVE/fullchain.pem \
            --capath $CERT_ARCHIVE/chain.pem \
            --home $ACME_PATH \
            --config-home $ACME_CONFIG_HOME \
            --dnssleep 20 
    return $?
}

function update_cert()
{
    if [ "$FORCE" == 0 ]; then
        $ACME_PATH/ acme.sh --renew -d $DOMAIN -d *.$DOMAIN \
            --certpath $CERT_ARCHIVE/cert.pem \
            --keypath $CERT_ARCHIVE/privkey.pem \
            --fullchainpath $CERT_ARCHIVE/fullchain.pem \
            --capath $CERT_ARCHIVE/chain.pem \
            --home $ACME_PATH \
            --config-home $ACME_CONFIG_HOME \
            --dnssleep 20 \
            --force
    else    
        $ACME_PATH/acme.sh --renew -d $DOMAIN -d *.$DOMAIN \
            --certpath $CERT_ARCHIVE/cert.pem \
            --keypath $CERT_ARCHIVE/privkey.pem \
            --fullchainpath $CERT_ARCHIVE/fullchain.pem \
            --capath $CERT_ARCHIVE/chain.pem \
            --home $ACME_PATH \
            --config-home $ACME_CONFIG_HOME \
            --dnssleep 20 
    fi
    return $?
}

function cp_reverseproxy()
{
		local flag=""
    for file in `ls ${CERT_FOLDER}/ReverseProxy`
    do
    		flag=`cat /usr/syno/etc/certificate/_archive/INFO | ./JSON.sh | grep '\["${CERT_ID}","services",.*,"service"\].*"${file}"'`
        if [ "${flag}" != "" ]; then
            cp ${CERT_ARCHIVE}/*.pem ${CERT_FOLDER}/ReverseProxy/${file}
        fi
    done	
}

function main()
{
    # 获取证书
    if [ "${MODE}" -eq 0 ]; then
    	  echo -e "${CLR_YL}开始创建${DOMAIN}证书,保存到:${CLR_NO}${CERT_ARCHIVE}"
        create_cert
    else
    	  echo  -e "${CLR_YL}开始更新${DOMAIN}证书,保存到:${CLR_NO}${CERT_ARCHIVE}"
        update_cert 
    fi
    result=$?

    # 对获取证书的结果进行处理
    wait
    if [ $result -eq 1 ];then
        echo -e "${CLR_RD}结束,未获取到有效的证书!${CLR_NO}"
        exit $EXIT_FAILURE
    elif [ $result -eq 2 ];then
        echo -e "${CLR_RD}忽略,未到更新时间!${CLR_NO}"
        exit $EXIT_ICLR_NOORRECT
    elif [ $result -ne 0 ];then
        echo -e "${CLR_RD}异常,证书获取异常!${CLR_NO}"
        exit $EXIT_FAILURE
    fi

    # 处理默认证书
    wait
    if [ "${DESC}" == "default" ]; then
    	echo -e "${CLR_YL}复制证书到默认目录:${CLR_NO}${CERT_FOLDER}/system/default"
	    cp ${CERT_ARCHIVE}/*.pem ${CERT_FOLDER}/system/default
	    # 处理反代
	    wait
	    echo -e "${CLR_YL}复制证书到反代目录:${CLR_NO}${CERT_FOLDER}/ReverseProxy"
      cp_reverseproxy
	  fi

    # 重启Nginx
    wait
    echo -e "${CLR_YL}重新加载Nginx${CLR_NO}"
    synoservicectl --reload nginx

    # 结束提示
    if [ ${MODE} -eq 0 ];then
        echo -e "${CLR_YL}证书创建完成!${CLR_NO}"
    else
        echo -e "${CLR_YL}证书更新完成!${CLR_NO}"
    fi
}


while getopts "d:fhn:m:" arg_all; do
    case $arg_all in
        d)
            DOMAIN=$OPTARG ;;
        f)
            FORCE=0 ;;
        h)
            echo -e "${CLR_YL}${NAME} V${VER}\n${URL}${CLR_NO}"
            echo -e $HELP
            exit $EXIT_ICLR_NOORRECTprompt=0 ;;
        n)
						NAME=$OPTARG ;;
        m)
            if [ "$OPTARG" == "create" ]; then
                MODE=0
            elif [ "$OPTARG" == "update" ]; then
                MODE=1
            else
                echo -e "${CLR_RD}[Fault]${CLR_NO} -m 模式命令输入错误, 请输入'-m create' 或 '-m update'"
                exit  $EXIT_FAILURE
            fi
            ;;
        ?)
            echo -e "${CLR_RD}[Fault]${CLR_NO} 输入错误, 未知的参数"
            exit $EXIT_FAILURE ;;
      esac
done

if [ "${DOMAIN}" == "" ]; then
	  echo -e "${CLR_RD}[Fault]${CLR_NO} -d 域名参数输入错误, 请输入 '-d [域名]'"
    exit $EXIT_FAILURE ;;
fi

shift $((OPTIND-1))

parse_cert_id

main
