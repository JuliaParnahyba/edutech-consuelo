# 🧩 EduTech  
_SQL (70%) + Python (30%)_  

Projeto desenvolvido no curso **Full Stack** do **Instituto Consuelo**, em parceria com a **Casa Digital**.  
O sistema simula uma plataforma de **gerenciamento de cursos online**, aplicando conceitos práticos de **modelagem SQL, manipulação de dados e automação com Python**.

<br>

## ⚙️ Fluxo de branches e revisão  

- **Branches principais:**  
  - `main` — branch estável, utilizada apenas para a versão final do projeto.  
  - `development` — branch de desenvolvimento contínuo (recebe commits diretos).  

- **Política atual:**  
  - O desenvolvimento é feito diretamente na branch `development`;  
  - Ao final do projeto, será aberta uma **Pull Request (`development` → `main`)** para a entrega oficial.  

- **Revisão final:**  
  - A PR final será avaliada por:  
    - [**Professor Júlio César**](https://github.com/julio-cesar96)  
    - [**Monitor Douglas**](https://github.com/douglassilvaf)  

- **Proteções:**  
  - As regras de branch protection e o arquivo `CODEOWNERS` serão habilitados **apenas antes da PR final**, garantindo que o merge final seja revisado e aprovado.  

<br>

## 📁 Estrutura de diretórios

```bash
/docs/      → documentação e diagramas  
/sql/       → schema.sql, dados.sql, consultas e relatórios  
/python/    → scripts auxiliares (gerador, validador, utils)  
/data/      → arquivos CSV gerados e processados  
```

```bash
EDUTECH-CONSUELO/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
├── data/
│   └── ...
├── docs/
│   ├── standards/
│   ├── Resumo_EduTech.md
├── python/
│   ├── gerador_dados.py
│   ├── utils.py
│   ├── validador.py
├── sql/
│   ├── deploy.sql              # orquestrador (BEGIN…COMMIT + includes)
│   ├── 00_env.sql              # schema, search_path, extensões (opcional)
│   ├── queries/
│     ├── queries.sql
│   ├── schemas/
│     ├── comments.sql          # COMMENT ON TABLE/COLUMN…
│     ├── indexes.sql           # CREATE INDEX … (idempotente)
│     ├── tables.sql            # CREATE TABLE … (sem BEGIN/COMMIT aqui)
│     ├── triggers.sql          # funções + triggers BEFORE UPDATE
│   └── seeds/
│     ├── curse_level.sql
│     ├── situation_insc.sql
├── LICENSE
└── README.md
```

<br>

## 🛳️ Executar PostgreSQL via Docker

<br>

> <br>
>
> Porta do host: **5433** → Porta interna do container: **5432**  
> Variáveis em `.env` (exemplo): 
> ```bash
> POSTGRES_VERSION=18
> PGPORT=5433
> POSTGRES_USER=edutech_admin
> POSTGRES_PASSWORD=***
> POSTGRES_DB=edutech
> ```
> <br>

<br>

Subir o banco:
```bash
docker compose up -d
```

<br>

Verificar status:
```bash
docker ps --filter "name=edutech_db"
```

<br>

Testar conexão:
```bash
PGPASSWORD=<sua_senha> psql -h 127.0.0.1 -p 5433 -U edutech_admin -d edutech -c "select current_database(), current_user;"
```

<br>

Parar/Remover:
```bash
docker compose down         # para e mantém dados
docker compose down -v      # ⚠️ remove também o volume (zera o banco)
```

<br>

_Os scripts em ./sql são executados automaticamente apenas na primeira inicialização do volume pgdata._


<br>

## 🐍 Ambiente Python

**Para configurar o ambiente Python localmente, execute:**

```bash
python3 -m venv .venv
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows
```

<br>

Instale as dependências do projeto (caso existam):
```bash
pip install -r requirements.txt
```

<br>

💡 _O ambiente virtual .venv já está incluído no .gitignore para evitar versionamento.
Todas as dependências utilizadas no projeto serão registradas em requirements.txt._

<br>

## ▶️ Como executar o projeto  

### 1️⃣ Gerar dados sintéticos  
Execute os scripts Python de geração e validação de dados:  
```bash
python3 python/gerador_dados.py
python3 python/validador.py
```

### 2️⃣ Criar e popular o banco de dados (PostgreSQL)
No terminal interativo do PostgreSQL, rode os scripts SQL:
```bash
\i sql/schema.sql;
\i sql/dados.sql;
```

### 3️⃣ Executar consultas e relatórios
```bash
\i sql/consultas.sql;
\i sql/relatorios_analiticos.sql;
```

<br>

## 📎 Referências

🔗 [Ver resumo completo do projeto](./docs/Resumo_EduTech.md)

📊 [GitHub Project – EduTech_Consuelo](https://github.com/users/JuliaParnahyba/projects/14)

<br>

📌 **Última atualização:** 13 de outubro de 2025  
📎 **Responsável:** [@JuliaParnahyba](https://github.com/JuliaParnahyba)