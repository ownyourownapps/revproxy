# revproxy

Stack de reverse proxy e gerenciamento de containers com Traefik, Cloudflared, Dozzle e Portainer.

## Serviços e suas funções

### Reverse Proxy e Túnel
- **Traefik**: Reverse proxy moderno que roteia requisições HTTP/HTTPS, gerencia certificados SSL/TLS automaticamente via Let's Encrypt, e expõe dashboards e serviços através de subdomínios configurados.
- **Cloudflared**: Túnel Cloudflare que permite expor serviços de forma segura sem abrir portas diretamente no firewall, mantendo os serviços protegidos atrás da rede Cloudflare.

### Gerenciamento de Containers
- **Dozzle**: Visualizador de logs de containers Docker em tempo real. Interface web simples e leve para monitorar logs de todos os containers em execução.
- **Portainer**: Interface web completa para gerenciar containers Docker, imagens, volumes, redes e stacks. Facilita o gerenciamento visual da infraestrutura Docker.

## Como usar

1. **Copie o arquivo de exemplo de variáveis de ambiente:**
   ```bash
   cp .env.example .env
   ```

2. **Preencha as variáveis no arquivo `.env`:**
   - `ACME_EMAIL`: Email para receber notificações do Let's Encrypt
   - `CF_DNS_API_TOKEN`: Token da API DNS do Cloudflare (para DNS challenge)
   - `CLOUDFLARE_TUNNEL_TOKEN`: Token do Cloudflare Tunnel
   - `TRAEFIK_DOMAIN`: Domínio para acessar o dashboard do Traefik
   - `DOMAIN_BASE`: Domínio base para subdomínios (ex: `example.com`)
   - `BASIC_AUTH_HASH`: Hash para autenticação básica do Traefik dashboard
     - Gerar com: `echo $(htpasswd -nb admin password) | sed -e s/\\$/\\$\\$/g`
   - `IP_ALLOWLIST`: IPs permitidos para acessar o dashboard (opcional, padrão: localhost + redes privadas)
   - `MOUNT_POINT`: Ponto de montagem para volumes persistentes (opcional, padrão: `./data`)

3. **Crie a rede externa do Traefik (se ainda não existir):**
   ```bash
   docker network create traefik
   ```
   > **Nota**: Esta rede é compartilhada com outras stacks para permitir que o Traefik roteie requisições para serviços em outros docker-compose.

4. **Inicie os serviços:**
   ```bash
   docker compose up -d
   ```
   Ou usando o Makefile:
   ```bash
   make up
   ```

## Conectar outras stacks

Para conectar outras stacks ao Traefik:

1. **Adicione a rede externa `traefik` no docker-compose.yml da outra stack:**
   ```yaml
   networks:
     traefik:
       external: true
   ```

2. **Adicione os serviços à rede `traefik`:**
   ```yaml
   services:
     seu-servico:
       networks:
         - traefik
   ```

3. **Adicione labels Traefik para expor via subdomínios:**
   ```yaml
   labels:
     - traefik.enable=true
     - traefik.http.routers.seu-servico.rule=Host(`servico.${DOMAIN_BASE}`)
     - traefik.http.routers.seu-servico.entrypoints=websecure
     - traefik.http.routers.seu-servico.tls.certresolver=le
     - traefik.http.routers.seu-servico.middlewares=secure-headers
     - traefik.http.services.seu-servico.loadbalancer.server.port=PORTA
   ```

## Serviços e portas

- **Traefik**: Portas 80/443 expostas no host
  - Dashboard: `https://${TRAEFIK_DOMAIN}`
  - Métricas Prometheus: `http://localhost:8082/metrics` (não exposto publicamente)

- **Cloudflared**: Sem portas expostas (túnel Cloudflare para exposição externa)

- **Dozzle**: Acesso via `https://dozzle.${DOMAIN_BASE}` (porta interna 8080, não exposta)

- **Portainer**: Acesso via `https://portainer.${DOMAIN_BASE}` (porta interna 9000, não exposta)

> **Nota**: Dozzle e Portainer não expõem portas diretamente. O acesso é feito exclusivamente via Traefik através dos subdomínios configurados.

## Segurança

- **Traefik Dashboard**: Protegido com autenticação básica e IP allowlist (configurável via `IP_ALLOWLIST` e `BASIC_AUTH_HASH`)
- **Certificados SSL/TLS**: Gerenciados automaticamente via Let's Encrypt com DNS challenge do Cloudflare
- **Cloudflared**: Túnel Cloudflare para exposição segura dos serviços sem abrir portas diretamente no firewall
- **Secure Headers**: Middleware aplicado a todos os serviços expostos via Traefik (XSS protection, HSTS, etc.)

## Comandos Úteis

- `make up` - Iniciar todos os serviços
- `make down` - Parar todos os serviços
- `make restart` - Reiniciar todos os serviços
- `make logs` - Ver logs de todos os serviços
- `make ps` - Listar containers em execução
- `make health-check` - Verificar saúde dos serviços
- `make open-traefik` - Abrir Traefik dashboard no navegador
- `make open-dozzle` - Abrir Dozzle no navegador
- `make open-portainer` - Abrir Portainer no navegador

## Dependências

Esta stack deve ser iniciada **antes** de outras stacks que dependem do Traefik, pois elas precisam da rede `traefik` e do Traefik em execução para funcionar corretamente.

## Ordem de inicialização recomendada

1. Iniciar `revproxy` primeiro: `docker compose up -d` (ou `make up`)
2. Aguardar alguns segundos para o Traefik inicializar completamente
3. Iniciar outras stacks que dependem do Traefik
