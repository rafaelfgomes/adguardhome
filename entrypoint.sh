#!/bin/sh

PUID=${PUID:-1000}
PGID=${PGID:-1000}

echo ">> Iniciando AdGuard Home com UID: $PUID e GID: $PGID"

addgroup -g "$PGID" adguard 2>/dev/null || true

adduser -D -H -u "$PUID" -G adguard -s /bin/sh adguard 2>/dev/null || true

chown -R adguard:adguard /opt/adguardhome/conf

chown -R adguard:adguard /opt/adguardhome/work

echo ">> Iniciando a aplicação..."

if [ ! -f "/opt/adguardhome/conf/AdGuardHome.yaml" ]; then
    echo "================================================================="
    echo ">> [AVISO] Primeira execução detectada!"
    echo ">> O Wizard inicial do AdGuard Home exige root por padrão."
    echo ">> Iniciando temporariamente como ROOT..."
    echo ">>"
    echo ">> O QUE VOCÊ DEVE FAZER AGORA:"
    echo ">> 1. Acesse o navegador na porta 3000 e finalize a instalação."
    echo ">> 2. Volte ao terminal e reinicie: docker compose restart"
    echo "================================================================="

    # Executa como root (sem su-exec) apenas nesta vez
    exec "$@"
else
    echo ">> Configuração encontrada! Iniciando de forma segura."
    echo ">> Rebaixando privilégios para UID: $PUID e GID: $PGID"

    chown -R adguard:adguard /opt/adguardhome/conf

    chown -R adguard:adguard /opt/adguardhome/work

    # Dá permissão na porta 53 para o arquivo
    setcap 'cap_net_bind_service=+eip' /opt/AdGuardHome/AdGuardHome

    # Executa travado como usuário comum
    exec su-exec adguard "$@"
fi