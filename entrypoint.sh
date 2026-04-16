#!/bin/sh

PUID=${PUID:-1000}

PGID=${PGID:-1000}

echo ">> Configurando permissões absolutas para UID: $PUID e GID: $PGID"

addgroup -g "$PGID" adguardgroup 2>/dev/null || true

adduser -D -H -u "$PUID" -G adguardgroup -s /bin/sh adguarduser 2>/dev/null || true

chmod -R -s /opt/adguardhome/conf 2>/dev/null || true

chmod -R -s /opt/adguardhome/work 2>/dev/null || true

chown -R ${PUID}:${PGID} /opt/adguardhome/conf

chown -R ${PUID}:${PGID} /opt/adguardhome/work

if [ ! -f "/opt/adguardhome/conf/AdGuardHome.yaml" ]; then
    echo ">> Primeira execução detectada! Rodando como root para o Setup..."
    exec "$@"
else
    echo ">> Iniciando AdGuard Home isolado..."

    chown -R ${PUID}:${PGID} /opt/adguardhome/conf

    chown -R ${PUID}:${PGID} /opt/adguardhome/work

    setcap 'cap_net_bind_service=+eip' /opt/AdGuardHome/AdGuardHome

    exec su-exec ${PUID}:${PGID} "$@"
fi