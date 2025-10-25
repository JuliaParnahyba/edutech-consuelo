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

# Spinner que silencia a saída e imprime o log ao final
define spin_log
	@bash -c 'set -euo pipefail; MSG=$(printf "%s" "$(1)"); LOG=$$(mktemp); \
	i=0; frames="/-\|"; printf "$(FG_BLUE)⏳ %s $(RESET)" "$$MSG"; \
	( $(2) ) >"$$LOG" 2>&1 & pid=$$!; \
	while kill -0 $$pid 2>/dev/null; do i=$$(( (i+1) % 4 )); \
	  printf "\r$(FG_BLUE)⏳ %s %s$(RESET) " "$$MSG" "$${frames:$$i:1}"; sleep 0.1; done; \
	if wait $$pid; then \
	  printf "\r$(FG_GREEN)✔ %s$(RESET)\n" "$$MSG"; \
	  cat "$$LOG"; rm -f "$$LOG"; \
	else \
	  status=$$?; printf "\r$(FG_RED)✖ %s (status $$status)$(RESET)\n" "$$MSG"; \
	  printf "$(FG_YELLOW)--- LOG ---$(RESET)\n"; cat "$$LOG"; rm -f "$$LOG"; exit $$status; \
	fi'
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

.PHONY: help up down down-v env db.apply db.seed db.seed-dev db.clean db.reset db.shell db.info db.load-csv db.query

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
	$(call banner,Ambiente efetivo)
	@printf "  HOST : $(POSTGRES_HOST)\n  PORT : $(POSTGRES_PORT)\n  USER : $(POSTGRES_USER)\n  DB   : $(POSTGRES_DB)\n"

# =========================
# Banco de Dados (psql)
# =========================
db.apply: ## Aplica o deploy completo (env, tables, indexes, triggers, comments, seeds)
	$(call spin,Aplicando schema (sql/deploy.sql), \
	$(PG_CMD) -f sql/deploy.sql)

db.seed: ## Roda apenas os seeds (inclui dados.sql); use DEV=on para truncar
	$(call spin,Executando seeds (DEV toggle via -v DEV=on), \
	$(PG_CMD) -f sql/seeds/nivel_cursos.sql && \
	$(PG_CMD) -f sql/seeds/situacoes_matricula.sql && \
	$(PG_CMD) -f sql/seeds/dados.sql)

db.seed-dev: ## Seed com TRUNCATE + RESTART IDENTITY (DEV=on)
	$(call spin,Executando seeds com TRUNCATE (DEV=on), \
	$(PG_CMD) -v DEV=on -f sql/seeds/nivel_cursos.sql && \
	$(PG_CMD) -v DEV=on -f sql/seeds/situacoes_matricula.sql && \
	$(PG_CMD) -v DEV=on -f sql/seeds/dados.sql)

db.clean: ## DROP SCHEMA edutech CASCADE (apenas o schema, mantém DB/roles)
	$(call spin,Limpando schema edutech (DROP CASCADE), \
	$(PG_CMD) -c "DROP SCHEMA IF EXISTS edutech CASCADE;")

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

db.load-csv: ## Carrega CSVs de /data no schema edutech via \copy (ordem correta)
	$(call banner,Carregando CSVs no Postgres (schema edutech))
	@$(PG_CMD) -c "\copy edutech.categorias (categoria_id,categoria_nome,categoria_descricao,categoria_data_criacao,categoria_data_atualizacao) from 'data/categorias.csv' with (format csv, header true)"
	@$(PG_CMD) -c "\copy edutech.especialidades (especialidade_id,especialidade_nome,especialidade_descricao,especialidade_data_criacao,especialidade_data_atualizacao) from 'data/especialidades.csv' with (format csv, header true)"
	@$(PG_CMD) -c "\copy edutech.nivel_cursos (nivel_curso_id,nivel_curso_nome,nivel_curso_descricao,nivel_curso_data_criacao,nivel_curso_data_atualizacao) from 'data/nivel_cursos.csv' with (format csv, header true)"
	@$(PG_CMD) -c "\copy edutech.situacoes_matricula (situacao_matricula_id,situacao_matricula_tipo,situacao_matricula_descricao,situacao_matricula_data_criacao,situacao_matricula_data_atualizacao) from 'data/situacoes_matricula.csv' with (format csv, header true)"

	@$(PG_CMD) -c "\copy edutech.instrutores (instrutor_id,instrutor_primeiro_nome,instrutor_ultimo_nome,instrutor_email,instrutor_especial_principal_id,instrutor_biografia,instrutor_data_criacao,instrutor_data_atualizacao) from 'data/instrutores.csv' with (format csv, header true)"
	@$(PG_CMD) -c "\copy edutech.instrutor_especialidades (ie_instrutor_id,ie_especialidade_id,ie_data_criacao,ie_data_atualizacao) from 'data/instrutor_especialidades.csv' with (format csv, header true)"

	@$(PG_CMD) -c "\copy edutech.cursos (curso_id,curso_titulo,curso_descricao,curso_categoria_id,curso_instrutor_id,curso_nivel_id,curso_carga_horaria,curso_preco,curso_data_criacao,curso_data_atualizacao) from 'data/cursos.csv' with (format csv, header true)"
	@$(PG_CMD) -c "\copy edutech.modulos (modulo_id,modulo_curso_id,modulo_titulo,modulo_ordem,modulo_descricao,modulo_data_criacao,modulo_data_atualizacao) from 'data/modulos.csv' with (format csv, header true)"
	@$(PG_CMD) -c "\copy edutech.aulas (aula_id,aula_modulo_id,aula_titulo,aula_ordem,aula_duracao_min,aula_tipo,aula_data_criacao,aula_data_atualizacao) from 'data/aulas.csv' with (format csv, header true)"

	@$(PG_CMD) -c "\copy edutech.alunos (aluno_id,aluno_primeiro_nome,aluno_ultimo_nome,aluno_email,aluno_data_nascimento,aluno_data_criacao,aluno_data_atualizacao) from 'data/alunos.csv' with (format csv, header true)"
	@$(PG_CMD) -c "\copy edutech.matriculas (matricula_id,matricula_aluno_id,matricula_curso_id,matricula_situacao_id,matricula_num_matricula,matricula_data_matricula,matricula_valor_pago,matricula_data_conclusao,matricula_diploma,matricula_data_criacao,matricula_data_atualizacao) from 'data/matriculas.csv' with (format csv, header true)"

	@$(PG_CMD) -c "\copy edutech.progresso_aulas (progresso_id,progresso_matricula_id,progresso_aula_id,progresso_percentual,progresso_concluida,progresso_data_conclusao,progresso_tempo_assistido_min,progresso_data_criacao,progresso_data_atualizacao) from 'data/progresso_aulas.csv' with (format csv, header true)"
	@$(PG_CMD) -c "\copy edutech.avaliacoes (avaliacao_id,avaliacao_aluno_id,avaliacao_aula_id,avaliacao_nota,avaliacao_comentario,avaliacao_data_criacao,avaliacao_data_atualizacao) from 'data/avaliacoes.csv' with (format csv, header true)"
	$(call ok,Carga dos CSVs concluída)


db.query: ## Executa consultas analíticas em sql/queries/queries.sql
	$(call spin,Executando consultas (queries.sql), $(PG_CMD) -f sql/queries/queries.sql)
	$(call ok,Consultas finalizadas com sucesso!)

# =========================
# Descobrir Python do sistema (python3 ou python)
# =========================
SYS_PY := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null)

ifeq ($(strip $(SYS_PY)),)
  $(error Python não encontrado no PATH. Instale Python 3 e garanta que 'python3' (ou 'python') esteja disponível)
endif

# =========================
# Python / Dados sintéticos
# =========================
VENV          ?= .venv
PY            := $(VENV)/bin/python
REQ           ?= requirements.txt
GEN_SCRIPT    ?= python/gerador_dados.py

# Parâmetros padrão do gerador (customize à vontade na CLI)
CATEGORIAS    ?= 8
ESPECIALIDADES?= 12
INSTRUTORES   ?= 15
CURSOS        ?= 25
MOD_MIN       ?= 3
MOD_MAX       ?= 6
AUL_MIN       ?= 3
AUL_MAX       ?= 6
ALUNOS        ?= 300
MATRICULAS    ?= 700
PROG_MIN_PCT  ?= 25
PROG_MAX_PCT  ?= 70
AVAL_PROB     ?= 0.6
SEED          ?= 42

.PHONY: py.which py.shell py.deps py.exit py.exit! data.gen data.peek data.clean

py.which: ## Mostra o Python do sistema e da venv
	$(call banner,Detectando Python)
	@printf "Sistema: $(FG_CYAN)$(SYS_PY)$(RESET)\n"
	@if [ -x "$(PY)" ]; then printf "Venv   : $(FG_CYAN)$(PY)$(RESET)\n"; else printf "Venv   : (ainda não criada)\n"; fi

py.venv: ## Cria venv local (.venv) se não existir
	@if [ -d "$(VENV)" ] && [ -x "$(PY)" ]; then \
	  printf "$(FG_GREEN)✔ venv já existe em $(VENV)$(RESET)\n"; \
	else \
	  $(call banner,Criando venv com $(SYS_PY)); \
	  $(SYS_PY) -c "import venv" 2>/dev/null || { \
	    echo "$(FG_RED)✖ Módulo 'venv' não encontrado.$(RESET)"; \
	    echo "$(FG_YELLOW)→ Dica (Ubuntu/Debian): sudo apt-get install -y python3-venv$(RESET)"; exit 1; }; \
	  $(SYS_PY) -m venv $(VENV); \
	  printf "$(FG_GREEN)✔ venv criada em $(VENV)$(RESET)\n"; \
	fi

py.shell: ## Abre um shell interativo já dentro da venv
	$(call banner,Abrindo shell com venv ativa)
	@bash --noprofile --norc -i -c 'source "$(VENV)/bin/activate"; printf "$(FG_GREEN)✔ v

py.deps: py.venv ## Instala dependências Python (usa requirements.txt se existir)
	$(call banner,Instalando dependências Python)
	@$(PY) -m pip install -U pip -q
	$(call spin,Instalando pacotes necessários, \
		if [ -f "$(REQ)" ]; then \
			$(PY) -m pip install -r $(REQ) -q; \
		else \
			$(PY) -m pip install Faker -q; \
		fi)
	@$(PY) -m pip show Faker | awk -F': ' '/^Name|^Version/{print $$1": " $$2}'
	$(call banner,Pacotes ativos na venv:)
	@$(PY) -m pip list --disable-pip-version-check | tail -n +3
	$(call ok,Dependências instaladas com sucesso!)


py.exit: ## Exibe instrução para sair da venv atual
	$(call banner,Saindo do ambiente virtual)
	@printf "$(FG_YELLOW)Para sair manualmente da venv, execute:$(RESET)\n"
	@printf "  $(FG_CYAN)deactivate$(RESET)\n\n"
	@printf "$(GRAY)Dica: use 'make py.exit!' para sair automaticamente.$(RESET)\n"

py.exit!: ## Sai automaticamente da venv (executa 'deactivate' + 'exec bash')
	$(call banner,Saída automática da venv)
	@printf "$(FG_YELLOW)Encerrando venv e reabrindo shell limpo...$(RESET)\n"
	@bash -c 'if [ -n "$$VIRTUAL_ENV" ]; then deactivate 2>/dev/null || true; fi; exec bash'

data.gen: py.deps ## Gera CSVs em /data com parâmetros padronizados
	$(call spin_log,Gerando CSVs (python/gerador_dados.py), \
	$(PY) $(GEN_SCRIPT) \
		--seed $(SEED) \
		--categorias $(CATEGORIAS) \
		--especialidades $(ESPECIALIDADES) \
		--instrutores $(INSTRUTORES) \
		--cursos $(CURSOS) \
		--modulos-min $(MOD_MIN) --modulos-max $(MOD_MAX) \
		--aulas-min $(AUL_MIN)   --aulas-max $(AUL_MAX) \
		--alunos $(ALUNOS) --matriculas $(MATRICULAS) \
		--progresso-min-pct $(PROG_MIN_PCT) \
		--progresso-max-pct $(PROG_MAX_PCT) \
		--avaliacoes-prob $(AVAL_PROB))

data.peek: ## Mostra cabeçalhos e primeiras linhas de cada CSV
	$(call banner,Preview dos CSVs gerados)
	@for f in data/*.csv; do \
	  printf "$(FG_CYAN)%s$(RESET)\n" "$$f"; \
	  head -n 2 "$$f" || true; \
	  echo ""; \
	done

data.clean: ## Remove todos os CSVs de /data
	$(call spin,Limpando /data/*.csv, rm -f data/*.csv)


# Fim
