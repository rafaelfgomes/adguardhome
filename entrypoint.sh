#!/bin/sh

PUID=${PUID:-1000}
PGID=${PGID:-1000}

echo ">> Iniciando AdGuard Home com UID: $PUID e GID: $PGID"

addgroup -g "$PGID" adguard 2>/dev/null || true

adduser -D -H -u "$PUID" -G adguard -s /bin/sh adguard 2>/dev/null || true

chown -R adguard:adguard /opt/adguardhome/conf

chown -R adguard:adguard /opt/adguardhome/work

setcap 'cap_net_bind_service=+eip' /opt/AdGuardHome/AdGuardHome

echo ">> Iniciando a aplicação..."

exec su-exec adguard "$@"