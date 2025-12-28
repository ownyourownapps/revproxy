.PHONY: help up down restart logs ps health-check open-traefik open-dozzle open-portainer

# Default target
help:
	@echo "Revproxy Stack - Available commands:"
	@echo ""
	@echo "  make up              - Start all services"
	@echo "  make down            - Stop all services"
	@echo "  make restart         - Restart all services"
	@echo "  make logs            - Show logs from all services"
	@echo "  make ps              - Show running containers"
	@echo "  make health-check    - Check service health"
	@echo ""
	@echo "  make open-traefik    - Open Traefik dashboard"
	@echo "  make open-dozzle     - Open Dozzle UI"
	@echo "  make open-portainer  - Open Portainer UI"

# Docker Compose commands
up:
	@docker compose up -d
	@echo "✅ Services started!"
	@echo ""
	@make ps

down:
	@docker compose down
	@echo "✅ Services stopped!"

restart:
	@docker compose restart
	@echo "✅ Services restarted!"

logs:
	@docker compose logs -f

ps:
	@docker compose ps

# Health Check
health-check:
	@echo "Checking service health..."
	@echo ""
	@echo "Container Status:"
	@docker compose ps
	@echo ""
	@echo "Service URLs (from .env):"
	@echo "  Traefik:   https://$$(grep TRAEFIK_DOMAIN .env 2>/dev/null | cut -d'=' -f2 || echo 'traefik.example.com')"
	@echo "  Dozzle:    https://dozzle.$$(grep DOMAIN_BASE .env 2>/dev/null | cut -d'=' -f2 || echo 'example.com')"
	@echo "  Portainer: https://portainer.$$(grep DOMAIN_BASE .env 2>/dev/null | cut -d'=' -f2 || echo 'example.com')"

# UI Access (via Traefik domains)
open-traefik:
	@DOMAIN=$$(grep TRAEFIK_DOMAIN .env 2>/dev/null | cut -d'=' -f2 || echo 'traefik.example.com'); \
	echo "Opening Traefik at https://$$DOMAIN"; \
	which xdg-open > /dev/null 2>&1 && xdg-open https://$$DOMAIN || \
	which open > /dev/null 2>&1 && open https://$$DOMAIN || \
	echo "Please open https://$$DOMAIN in your browser"

open-dozzle:
	@DOMAIN=$$(grep DOMAIN_BASE .env 2>/dev/null | cut -d'=' -f2 || echo 'example.com'); \
	echo "Opening Dozzle at https://dozzle.$$DOMAIN"; \
	which xdg-open > /dev/null 2>&1 && xdg-open https://dozzle.$$DOMAIN || \
	which open > /dev/null 2>&1 && open https://dozzle.$$DOMAIN || \
	echo "Please open https://dozzle.$$DOMAIN in your browser"

open-portainer:
	@DOMAIN=$$(grep DOMAIN_BASE .env 2>/dev/null | cut -d'=' -f2 || echo 'example.com'); \
	echo "Opening Portainer at https://portainer.$$DOMAIN"; \
	which xdg-open > /dev/null 2>&1 && xdg-open https://portainer.$$DOMAIN || \
	which open > /dev/null 2>&1 && open https://portainer.$$DOMAIN || \
	echo "Please open https://portainer.$$DOMAIN in your browser"

