#!/bin/sh

PUID=${PUID:-1000}

PGID=${PGID:-1000}

echo ">> Configurando permissões absolutas para UID: $PUID e GID: $PGID"

addgroup -g "$PGID" adguard 2>/dev/null || true

adduser -D -H -u "$PUID" -G adguard -s /bin/sh adguard 2>/dev/null || true

chmod -R -s /opt/adguardhome/conf 2>/dev/null || true

chmod -R -s /opt/adguardhome/work 2>/dev/null || true

chown -R adguard:adguard /opt/adguardhome

chmod -R 700 /opt/adguardhome

if [ ! -f "/opt/adguardhome/conf/AdGuardHome.yaml" ]; then
    echo ">> Primeira execução detectada! Rodando como root para o Setup..."
    exec "$@"
else
    echo ">> Iniciando AdGuard Home isolado..."

    setcap 'cap_net_bind_service=+eip' /opt/AdGuardHome/AdGuardHome

    exec su-exec adguard:adguard "$@"
fi