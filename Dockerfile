FROM alpine

# Instala as ferramentas necessárias
# su-exec: para rodar o app como usuário comum
# libcap: fornece o comando setcap (crítico para a porta 53)
# curl, tar, tzdata: utilitários básicos
RUN apk add --no-cache su-exec libcap curl tar tzdata

# Define variáveis de ambiente padrão
ENV PUID=911 \
    PGID=911 \
    TZ=America/Sao_Paulo

# Cria as pastas de trabalho e baixa o AdGuard Home
WORKDIR /opt

RUN curl -sSL https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz | tar -xz && \
    mkdir -p /opt/adguardhome/conf /opt/adguardhome/work

# Copia nosso script para dentro da imagem e dá permissão de execução
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Expõe as portas necessárias (DNS, HTTP WebUI, DNS-over-HTTPS, etc)
EXPOSE 53/tcp 53/udp 80/tcp 443/tcp 3000/tcp 853/tcp

# Define o script de entrada
ENTRYPOINT ["/entrypoint.sh"]

# Define o comando que o entrypoint vai executar
CMD ["/opt/AdGuardHome/AdGuardHome", "-h", "0.0.0.0", "-c", "/opt/adguardhome/conf/AdGuardHome.yaml", "-w", "/opt/adguardhome/work"]