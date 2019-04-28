#! /bin/bash

codename=`sudo lsb_release -c | sed -n -r '1,1 s/.*Codename:\s*(\S*)/\1/p'`

sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak

echo "deb http://mirrors.aliyun.com/ubuntu/ $codename main restricted universe multiverse" >> /etc/apt/sources.list

echo "deb-src http://mirrors.aliyun.com/ubuntu/ $codename main restricted universe multiverse" >> /etc/apt/sources.list

echo "deb http://mirrors.aliyun.com/ubuntu/ $codename-security main restricted universe multiverse" >> /etc/apt/sources.list

echo "deb-src http://mirrors.aliyun.com/ubuntu/ $codename-security main restricted universe multiverse" >> /etc/apt/sources.list

echo "deb http://mirrors.aliyun.com/ubuntu/ $codename-updates main restricted universe multiverse" >> /etc/apt/sources.list

echo "deb-src http://mirrors.aliyun.com/ubuntu/ $codename-updates main restricted universe multiverse" >> /etc/apt/sources.list

echo "deb http://mirrors.aliyun.com/ubuntu/ $codename-backports main restricted universe multiverse" >> /etc/apt/sources.list

echo "deb-src http://mirrors.aliyun.com/ubuntu/ $codename-backports main restricted universe multiverse" >> /etc/apt/sources.list

echo "deb http://mirrors.aliyun.com/ubuntu/ $codename-proposed main restricted universe multiverse" >> /etc/apt/sources.list

echo "deb-src http://mirrors.aliyun.com/ubuntu/ $codename-proposed main restricted universe multiverse" >> /etc/apt/sources.list

apt-get update
