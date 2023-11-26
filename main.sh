#!/bin/bash
status=$(docker ps| grep bind-dns)
if ! [ -z "$status" ]
then
    echo "[*] Bind-dns container up, stopping..."
    docker stop bind-dns
    status=$(docker ps| grep bind-dns)
    if [ -z "$status" ]
    then
         echo "[+] Successfully stopped"
    else
         echo "[-] Error stoping bind-dns"
         exit 1
    fi
else
    echo "[*] Bind-dns container down."
fi

status=$(docker ps -a| grep bind-dns)
if ! [ -z "$status" ]
then
    echo "[*] Bind-dns exists, removing..."
    docker rm bind-dns
    status=$(docker ps -a| grep bind-dns)
    if [ -z "$status" ]
    then
         echo "[+] Successfully removed"
    else
         echo "[-] Error removing bind-dns"
         exit 1
    fi
else
    echo "[*] Bind-dns not exists. Starting..."
fi

DOMAIN='YOUR_LOCAL_DOMAIN' ### for example local

docker run -i \
    -d \
    --name bind-dns \
    --restart unless-stopped \
    -p 53:53/tcp \
    -p 53:53/udp \
    -e DNS_A="name.$DOMAIN=192.168.1.1" \
    -e DNS_PTR="192.168.1.1=name.$DOMAIN" \
    -e ALLOW_QUERY='192.168.1.0/24,127.0.0.1' \
    -t cytopia/bind

status=$(docker ps| grep bind-dns)
if ! [ -z "$status" ]
then
    echo "[+] Bind-dns is running."
    exit 0
else
    echo "[-] Bind-dns start error."
    exit 1
fi
