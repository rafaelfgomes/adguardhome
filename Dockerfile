FROM alpine

# Instala as ferramentas necessárias
# su-exec: para rodar o app como usuário comum
# libcap: fornece o comando setcap (crítico para a porta 53)
# curl, tar, tzdata: utilitários básicos
RUN apk add --no-cache su-exec libcap curl tar tzdata

# Define variáveis de ambiente padrão
ENV PUID=1000 \
    PGID=1000 \
    TZ=Etc/UTC

RUN addgroup -g "$PGID" adguard 2>/dev/null || true

RUN adduser -D -H -u "$PUID" -G adguard -s /bin/sh adguard 2>/dev/null || true

# Cria as pastas de trabalho e baixa o AdGuard Home
WORKDIR /opt

RUN curl -sSL https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz | tar -xz && \
    mkdir -p /opt/adguardhome/conf /opt/adguardhome/work

RUN chown -R adguard:adguard /opt/adguardhome

RUN chown -R adguard:adguard /opt/AdGuardHome

# Copia o script para dentro da imagem e dá permissão de execução
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Expõe as portas necessárias
# Porta 53: Plain DNS
# Porta 80: HTTP Padrão
# Porta 443: HTTS Padrão
# Porta 3000: Porta Setup Inicial
# Porta 853(tcp): DNS-over-TLS (DoT)
# Porta 784, 853 e 8853(udp): DNS-over-QUIC (DoQ)
# Porta 5443: DNSCrypt Server
EXPOSE 53/tcp \
    53/udp \
    80/tcp \
    443/tcp \
    784/udp \
    853/tcp \
    853/udp \
    3000/tcp \
    5443/tcp \
    5443/udp \
    8853/udp

# Define o script de entrada
ENTRYPOINT ["/entrypoint.sh"]

# Define o comando que o entrypoint vai executar
CMD ["/opt/AdGuardHome/AdGuardHome", "--no-check-update", "-h", "0.0.0.0", "-c", "/opt/adguardhome/conf/AdGuardHome.yaml", "-w", "/opt/adguardhome/work"]