#!/bin/sh

PUID=${PUID:-1000}
PGID=${PGID:-1000}

echo ">> Iniciando AdGuard Home com UID: $PUID e GID: $PGID"

# 2. Cria o grupo e o usuário com os IDs informados
# O '|| true' evita que o script quebre caso o usuário já exista (em reinicializações)
addgroup -g "$PGID" adguardgroup 2>/dev/null || true
adduser -D -H -u "$PUID" -G adguardgroup -s /bin/sh adguarduser 2>/dev/null || true

# 3. Ajusta o dono das pastas de configuração e dados
# Isso garante que seu host não fique com arquivos travados como 'root'
chown -R adguarduser:adguardgroup /opt/adguardhome/conf
chown -R adguarduser:adguardgroup /opt/adguardhome/work

# 4. TRUQUE CRÍTICO PARA O ADGUARD:
# Como o AdGuard é um servidor DNS, ele precisa da porta 53.
# Usuários normais (não-root) não podem abrir portas abaixo de 1024 no Linux.
# O comando setcap concede essa permissão específica ao binário.
setcap 'cap_net_bind_service=+eip' /opt/AdGuardHome/AdGuardHome

# 5. Executa o AdGuard Home rebaixando os privilégios com o su-exec
# O "$@" repassa qualquer comando extra do CMD do Dockerfile
echo ">> Iniciando a aplicação..."
exec su-exec adguarduser "$@"