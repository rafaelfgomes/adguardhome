#!/bin/sh

chown -R adguard:adguard /opt/adguardhome /opt/AdGuardHome

if [ ! -f "/opt/adguardhome/conf/AdGuardHome.yaml" ]; then
    echo ">> Primeira execução detectada! Rodando como root para o Setup..."

    exec "$@"
else
    echo ">> Iniciando AdGuard Home isolado..."

    setcap 'cap_net_bind_service=+eip' /opt/AdGuardHome/AdGuardHome

    exec su-exec adguard:adguard "$@"
fi