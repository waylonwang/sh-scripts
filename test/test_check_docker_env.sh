#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/waylonwang/sh-scripts/master/check_docker_env.sh)

function test_check_os()
{
	echo 'check_os -t "centos,dsm" -p'
	check_os -t "centos,dsm" -p 
	echo ret $?
	echo

	echo 'check_os -t "centos,dsm"'
	check_os -t "centos,dsm"
	echo ret $?
	echo

	echo 'check_os -t "centos,dsm" -p'
	check_os -t "ubuntu,dsm" -p 
	echo ret $?
	echo

	echo 'check_os -t "centos,dsm"'
	check_os -t "ubuntu,dsm"
	echo ret $?
	echo

	echo 'check_os -t "centos,ubuntu,dsm" -p'
	check_os -t "centos,ubuntu,dsm" -p 
	echo ret $?
	echo

	echo 'check_os -t "centos,ubuntu,dsm"'
	check_os -t "centos,ubuntu,dsm"	
	echo ret $?
	echo
}

function test_check_docker_install()
{
	echo 'check_docker_install'
	check_docker_install
	echo ret $?
	echo

	echo 'check_docker_install -p'
	check_docker_install -p 
	echo ret $?
	echo

	echo 'check_docker_install -p -v'
	check_docker_install -p -v 
	echo ret $?
	echo

	echo 'check_docker_install -p -i -v'
	check_docker_install -p -i -v 
	echo ret $?
	echo

	echo 'check_docker_install -p -i -a -v'
	check_docker_install -p -i -a -v 
	echo ret $?
	echo

	echo 'check_docker_install -p -i -a -v -s'
	check_docker_install -p -i -a -v -s
	echo ret $?
	echo
}

function test_check_compose_install()
{
	echo 'check_compose_install'
	check_compose_install
	echo ret $?
	echo

	echo 'check_compose_install -p'
	check_compose_install -p 
	echo ret $?
	echo

	echo 'check_compose_install -p -v'
	check_compose_install -p -v 
	echo ret $?
	echo

	echo 'check_compose_install -p -i -v'
	check_compose_install -p -i -v 
	echo ret $?
	echo
}

function test_check_docker_active()
{
	echo 'check_docker_active'
	check_docker_active
	echo ret $?
	echo

	echo 'check_docker_active -p'
	check_docker_active -p 
	echo ret $?
	echo

	echo 'check_docker_active -p -s'
	check_docker_active -p -s
	echo ret $?
	echo
}

case $1 in
  1)
    test_check_os ;;
  2)
    test_check_docker_install ;;
  3)
    test_check_compose_install ;;
  4)
    test_check_docker_active ;;
  ?)
    echo -e "${CLR_FG_BRD}[Fault]${CLR_NO} input error, unkonw argument"
	  exit 1 ;;
esac
