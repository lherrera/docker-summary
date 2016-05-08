#!/bin/bash
#==============================================================================
#title           : docker-summary.sh
#description     : Displays Docker host, engine and registry information 
#author		 : Luis Herrera
#date            : 8-May-2016
#version         : 0.1
#usage		 : ./docker-summary.sh
#notes           :
#==============================================================================
echo "-------------------------"
echo "Docker Env Summary Report"
echo "-------------------------"
date +%Y/%m/%d' - '%H:%M:%S

INFO=$(docker info 2>/dev/null )
if [ -n "$DOCKER_HOST" ] 
then
	echo "--------------"
	echo "Server Details"
	echo "--------------"
	echo "Server Name: $DOCKER_MACHINE_NAME"
	DEADDR=$( grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' <<< "$DOCKER_HOST")
	echo "Server Address: $DEADDR"
else
	if  grep -q "Name: docker" <<< "$INFO" 
	then
		echo "--------------"
		echo "Server Details"
		echo "--------------"
		DENAME=$(hostname)
		echo "Server Name: $DENAME"
		DEADDR=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' |head -1)
		echo "Server Address: $DEADDR"
	else
		echo "Not connected to Docker Engine" 
		exit
	fi
fi
grep 'Operating' <<< "$INFO"
grep 'Kernel' <<< "$INFO"
grep '^CPUs' <<< "$INFO"
grep 'Total Memory' <<< "$INFO"

PROV=$(egrep '^ provider' <<< "$INFO" | cut -d'=' -f 2)
if [ -n "$PROV" ]
then
	echo "Provider: $PROV"
fi 

echo "--------------"
echo "Engine Details"
echo "--------------"

TYPE=$(grep '^Server Version' <<< "$INFO" | cut -d':' -f2)

if [[ "$TYPE" == *"swarm"* ]]  
then
	echo "Swarm Cluster"
	echo "Version: $TYPE"	
	grep 'Role' <<< "$INFO"
	grep 'Strategy' <<< "$INFO"
	grep 'Nodes' <<< "$INFO"
	echo "--------------"
else
	echo "Standalone Engine"
	echo "Version: $TYPE"
fi
grep '^Images' <<< "$INFO"
grep '^Containers' <<< "$INFO"
VOL=$(docker volume ls |wc -l)
VOL=$(expr $VOL - 1)
echo "Volumes: $VOL"
NET=$(docker network ls |wc -l)
NET=$(expr $NET - 1)
echo "Networks: $NET"
if [[ "$TYPE" != *"swarm"* ]]  
then
	echo "----------------"
	echo "Registry Details"
	echo "----------------"
	REG=$(grep 'Registry' <<< "$INFO")
	if grep -q "docker.io" <<< "$REG"
	then
   		echo "Registry: Docker Hub"
	else 
   		echo $REG
	fi

	RUSER=$(grep 'Username' <<< "$INFO")
	if [  -n "$RUSER" ]
	then
   		echo  $RUSER
	else
   		echo "Not logged in"
	fi
fi
