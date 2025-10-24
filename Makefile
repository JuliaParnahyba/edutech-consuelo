# =========================
# EduTech — Makefile UX++
# Portável, mensagens coloridas e feedback visual.
# =========================

# -------- Config DB (podem vir de .env, mas aqui há defaults seguros)
POSTGRES_HOST ?= localhost
POSTGRES_PORT ?= 5433
POSTGRES_USER ?= edutech_admin
POSTGRES_PASSWORD ?= edutechpass
POSTGRES_DB ?= edutech

# -------- Comandos base
DOCKER_UP		= docker compose up -d
DOCKER_DOWN		= docker compose down
DOCKER_DOWN_V	= docker compose down -v
PG_CMD			= PGPASSWORD='$(POSTGRES_PASSWORD)' psql -h $(POSTGRES_HOST) -p $(POSTGRES_PORT) -U $(POSTGRES_USER) -d $(POSTGRES_DB) -v ON_ERROR_STOP=1

# -------- Cores/estilo (ANSI)
RESET=\033[0m
BOLD=\033[1m
DIM=\033[2m
FG_GREEN=\033[32m
FG_CYAN=\033[36m
FG_YELLOW=\033[33m
FG_RED=\033[31m
FG_BLUE=\033[34m
GRAY=\033[90m

# -------- Macros de UI
define banner
	@printf "$(FG_CYAN)$(BOLD)▶ %s$(RESET)\n" "$(1)"
endef

define ok
	@printf "$(FG_GREEN)✔ %s$(RESET)\n" "$(1)"
endef

define warn
	@printf "$(FG_YELLOW)⚠ %s$(RESET)\n" "$(1)"
endef

define fail
	@printf "$(FG_RED)✖ %s$(RESET)\n" "$(1)"
endef

# Spinner simples (gira enquanto o comando roda)
# Uso: $(call spin,Mensagem,comando args...)
define spin
	@bash -c 'set -euo pipefail; MSG=$(printf "%s" "$(1)"); \
	i=0; frames="/-\|"; printf "$(FG_BLUE)⏳ %s $(RESET)" "$$MSG"; \
	( $(2) ) & pid=$$!; \
	while kill -0 $$pid 2>/dev/null; do i=$$(( (i+1) % 4 )); printf "\r$(FG_BLUE)⏳ %s %s$(RESET) " "$$MSG" "$${frames:$$i:1}"; sleep 0.1; done; \
	wait $$pid; printf "\r$(FG_GREEN)✔ %s$(RESET)\n" "$$MSG";'
endef

# -------- Ajuda automática
# Regra: comente o target com "## descrição" na mesma linha.
help: ## Mostra esta ajuda
	@echo ""
	@printf "$(BOLD)EduTech — comandos disponíveis$(RESET)\n\n"
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## ' Makefile | sed -E 's/:.*?## /: /' | sort | awk '{printf "  $(FG_CYAN)%-18s$(RESET) %s\n", $$1, substr($$0, index($$0,$$2))}'
	@echo ""
	@printf "$(GRAY)Conexão atual:$(RESET) host=$(POSTGRES_HOST) port=$(POSTGRES_PORT) db=$(POSTGRES_DB) user=$(POSTGRES_USER)\n"
	@echo ""

.PHONY: help up down env db.apply db.clean db.reset db.info db.query

# =========================
# Docker
# =========================
up: ## Sobe o PostgreSQL via Docker Compose
	$(call spin,Subindo containers (Docker), $(DOCKER_UP))

down: ## Derruba containers (mantém volume); use 'make down-v' para reset total
	$(call spin,Derrubando containers (Docker), $(DOCKER_DOWN))

down-v: ## Derruba containers e volume
	$(call spin,Derrubando containers e volumes (Docker), $(DOCKER_DOWN_V))

env: ## Exibe variáveis de ambiente efetivas usadas pelo Make
	$(call banner,"Ambiente efetivo")
	@printf "  HOST : $(POSTGRES_HOST)\n  PORT : $(POSTGRES_PORT)\n  USER : $(POSTGRES_USER)\n  DB   : $(POSTGRES_DB)\n"

# =========================
# Banco de Dados (psql)
# =========================
db.apply: ## Aplica o deploy completo (env, tables, indexes, triggers, comments, seeds)
	$(call spin,Aplicando schema (sql/deploy.sql), $(PG_CMD) -f sql/deploy.sql)

db.clean: ## DROP SCHEMA edutech CASCADE (apenas o schema, mantém DB/roles)
	$(call spin,Limpando schema edutech (DROP CASCADE), $(PG_CMD) -c "DROP SCHEMA IF EXISTS edutech CASCADE;")

db.reset: ## DROP + recria tudo via deploy.sql
	$(call spin,Drop schema edutech, $(PG_CMD) -c "DROP SCHEMA IF EXISTS edutech CASCADE;")
	$(call spin,Recriando schema (deploy.sql), $(PG_CMD) -f sql/deploy.sql)

db.shell: ## Abre sessão interativa psql conectada ao banco edutech
	$(call banner,Abrindo shell interativo psql...)
	@$(PG_CMD)

db.info: ## Mostra info resumida: schemas, tabelas, índices, triggers e FKs
	$(call banner,Schemas)
	@$(PG_CMD) -c "\dn"
	$(call banner,Tabelas (schema edutech))
	@$(PG_CMD) -c "\dt edutech.*"
	$(call banner,Índices (schema edutech))
	@$(PG_CMD) -c "\di edutech.*"
	$(call banner,Triggers (schema edutech))
	@$(PG_CMD) -c "SELECT event_object_table AS tabela, trigger_name AS trigger, action_timing AS quando, event_manipulation AS evento FROM information_schema.triggers WHERE trigger_schema = 'edutech' ORDER BY tabela, trigger;"
	$(call banner,FKs e políticas ON DELETE)
	@$(PG_CMD) -c "SELECT tc.table_name AS tabela, tc.constraint_name AS fk, kcu.column_name AS coluna, ccu.table_name AS referencia, rc.delete_rule AS on_delete FROM information_schema.table_constraints tc JOIN information_schema.key_column_usage kcu ON tc.constraint_name=kcu.constraint_name AND tc.table_schema=kcu.table_schema JOIN information_schema.referential_constraints rc ON tc.constraint_name=rc.constraint_name AND tc.table_schema=rc.constraint_schema JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name=tc.constraint_name AND ccu.constraint_schema=tc.table_schema WHERE tc.table_schema='edutech' AND tc.constraint_type='FOREIGN KEY' ORDER BY tabela, fk;"

db.query: ## Executa consultas analíticas em sql/queries/queries.sql
	$(call spin,Executando consultas (queries.sql), $(PG_CMD) -f sql/queries/queries.sql)
	$(call ok,Consultas finalizadas com sucesso!)

# Fim
