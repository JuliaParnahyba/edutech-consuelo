# 🧩 EduTech  
_SQL (70%) + Python (30%)_  

Projeto desenvolvido no curso **Full Stack** do **Instituto Consuelo**, em parceria com a **Casa Digital**.  
O sistema simula uma plataforma de **gerenciamento de cursos online**, aplicando conceitos práticos de **modelagem SQL, manipulação de dados e automação com Python**.

<br>

## 🎯 Objetivo do Projeto

O **EduTech** foi projetado para consolidar o aprendizado de **banco de dados e automação de dados**, aplicando:

- **Modelagem lógica e física em PostgreSQL**
- **Execução de scripts SQL idempotentes**
- **Triggers e documentação dentro do próprio banco**
- **Políticas de integridade referencial (`ON DELETE` CASCADE/RESTRICT)**
- **Geração de dados sintéticos com Python e Faker**
- **Organização modular e versionada do schema**

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
EDUTECH-CONSUELO/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
│
├── data/                              # CSVs gerados pelos scripts Python
│   └── ...
│
├── docs/
│   ├── modelagem/
│   │   ├── modelagem02.md             # modelagem lógica v2 (atual)
│   │   └── diagrama02_edutech.svg     # ERD atualizado
│   ├── standards/
│   └── Resumo_EduTech.md
│
├── python/
│   ├── gerador_dados.py               # gera dados sintéticos com Faker
│   ├── validador.py                   # valida coerência entre tabelas
│   ├── utils.py                       # funções auxiliares
│
├── sql/
│   ├── deploy.sql                     # orquestrador geral (BEGIN…COMMIT)
│   ├── env.sql                        # schema + search_path
│   ├── queries/
│   │   └── queries.sql
│   ├── schemas/
│   │   ├── tables.sql                 # DDL (13 tabelas + constraints)
│   │   ├── indexes.sql                # índices idempotentes
│   │   ├── triggers.sql               # funções + triggers updated_at
│   │   └── comments.sql               # COMMENT ON TABLE/COLUMN…
│   ├── seeds/
│   │   ├── course_level.sql
│   │   └── enrollment_status.sql
│   └── views/                         # (para relatórios analíticos futuros)
│
├── Makefile                           # automação: db.apply, db.reset, etc.
├── docker-compose.yml
├── .env.example
├── requirements.txt
├── LICENSE
└── README.md
```

<br>

## 🛳️ Executar PostgreSQL + Adminer via Docker

<br>

> <br>
>
> Porta do host: **5433** → Porta interna do container: **5432** <br>
> Adminer: Interface web em [http://localhost:8080](http://localhost:8080)  
> Variáveis em `.env` (exemplo): 
> ```bash
> POSTGRES_VERSION=18
> PGPORT=5433
> POSTGRES_USER=edutech_admin
> POSTGRES_PASSWORD=sua_senha
> POSTGRES_DB=edutech
> ADMINER_PORT=8080
> ```
> <br>

<br>

### 🚀 Subir o ambiente completo
```bash
docker compose up -d
```
Sobe dois serviços:
  1. edutech_db — container PostgreSQL 18 com persistência no volume pgdata
  2. edutech_adminer — interface gráfica web para gerenciamento do banco

💡 _O Adminer só é liberado quando o banco estiver saudável (healthcheck OK)._

<br>

### 🔍 Acessar o banco via Adminer
Abra o navegador [http://localhost:8080](http://localhost:8080) e preenchar os campos para realizar o login

| Campo        | Valor recomendado                           |
| ------------ | ------------------------------------------- |
| **System**   | PostgreSQL                                  |
| **Server**   | `db` (dentro da rede Docker) ou `localhost` |
| **Username** | `edutech_admin`                             |
| **Password** | `sua_senha`                               |
| **Database** | `edutech`                                   |

<br>

![Login Adminer](/docs/src_img/image.png)

<br>

### 🔎 Verificar status:
```bash
docker ps --filter "name=edutech_db"
```

<br>

### ⚙️ Testar conexão:
```bash
PGPASSWORD=sua_senha psql -h 127.0.0.1 -p 5433 -U edutech_admin -d edutech -c "SELECT current_database(), current_user;"

```

<br>

### ⛓️‍💥 Parar/Remover:
```bash
docker compose down         # para e mantém dados
docker compose down -v      # ⚠️ remove também o volume (zera o banco)
```

<br>

_Os scripts em ./sql são executados automaticamente apenas na primeira inicialização do volume pgdata._


<br>

## 🧩 Automação via Makefile
Comandos principais disponíveis:
| Comando         | Descrição                                              |
| --------------- | ------------------------------------------------------ |
| `make db.apply` | Executa o `deploy.sql` (cria/atualiza schema completo) |
| `make db.clean` | Remove apenas o schema `edutech`                       |
| `make db.reset` | Dropa e recria o schema completo                       |
| `make db.info`  | Exibe tabelas e funções do schema atual                |

<br>

## 🌱 População de Dados (Seeds)
Os scripts de seed são responsáveis por popular o banco de dados com informações iniciais, garantindo um ambiente pronto para consultas e testes.

### 📂 Estrutura dos seeds
| Arquivo | Função |
| ------- | ------ |
| `sql/seeds/nivel_cursos.sql` | Insere os níveis de curso (*iniciante*, *intermediário*, *avançado*) |
| `sql/seeds/situacoes_matricula.sql` | Insere as situações padrão de matrícula (*ativa*, *pendente*, *trancada*, *cancelada*) |
| `sql/seeds/dados.sql` | Popula as tabelas principais com dados coerentes e relacionamentos válidos (categorias, instrutores, cursos, módulos, aulas, alunos e matrículas) |



## 🧠 Etapas já implementadas
| Etapa                                    | Descrição                                                     | Status |
| ---------------------------------------- | ------------------------------------------------------------- | ------ |
| **[01] Setup inicial**                   | Estrutura de diretórios, Makefile, CLI GitHub                 | ✅      |
| **[02.01] Modelagem Lógica**             | Entidades e relacionamentos normalizados                      | ✅      |
| **[02.02] Implementação SQL**            | Tabelas, índices, triggers, comentários e políticas ON DELETE | ✅      |
| **[02.03] Geração de Dados (Python)**    | Scripts de população e validação automatizada                 | 🔜     |
| **[02.04] Consultas e Views Analíticas** | Criação de relatórios SQL e agregações                        | 🔜     |

<br>

## 🐍 Ambiente Python

**Para criar ambiente virtual**

```bash
python3 -m venv .venv
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows
```

<br>

**Instale as dependências do projeto:**
```bash
pip install -r requirements.txt
```

💡 _O ambiente virtual .venv já está incluído no .gitignore para evitar versionamento.
Todas as dependências utilizadas no projeto serão registradas em requirements.txt._

<br>

## 🧭 Execução Geral do Projeto
A automação do ambiente é feita via **Makefile**, garantindo portabilidade e reprodutibilidade.
Todos os comandos abaixo funcionam em Linux, macOS e WSL2 (Windows).

💡 _Dica rápida: execute make help para ver todos os comandos disponíveis com descrição._

### Subir o ambiente PostgreSQL via Docker
```bash
make up
```
1. Cria e inicializa o container PostgreSQL definido no docker-compose.yml.
2. Usa as variáveis de conexão padrão ou definidas no .env.

- _Verificar se o container está ativo:_
```bash
docker ps --filter "name=edutech_db"
```

### Criar e aplicar o schema completo
```bash
make db.apply
```
_Executa o script sql/deploy.sql, que orquestra:_
  1. Criação do schema edutech
  2. Geração de todas as tabelas, índices e constraints
  3. Criação dos triggers (updated_at)
  4. Inserção de comentários e metadados

- Para recriar o zero:
```bash
make db.reset
```

- Para apenas remover o schema:
```bash
make db.clean
```

### Rodar o seed 
1. Padrão (idempotente)
```bash
make db.seed
```

2. Desenvolvimento (limpeza total):
```bash
make db.seed-dev
```
_Executa os mesmos seeds, mas antes faz `TRUNCATE ... RESTART IDENTITY CASCADE;`, recriando o ambiente do zero — ideal para testar ou reinicializar o banco durante o desenvolvimento._

#### ✅ Validações automáticas
O `sql/seeds/dados.sql` realiza checagens após o `COMMIT`, exibindo:
- Total de registros por tabela essencial;
- Confirmações de integridade mínima (t = true para cada verificação).

Exemplo de saída:
```bash
→ Validações pós-seed
   tabela    | total
-------------+-------
 alunos      |     5
 cursos      |     3
 ...
(7 rows)
✓ Seed concluído
```


### Explorar e validar o banco
1. Obtém resumo de estrutura e integridade:
```bash
make db.info
```
Mostra os seguintes dados:
  1. Schemas disponíveis
  2. Tabelas e índices do schema `edutech`
  3. Triggers ativos
  4. Regras `ON DELETE` de todas as FKs


2. Abrir sessão interativa do PostgreSQL:
```bash
make db.shell
```
_Entra diretamente no prompt edutech=# autenticado com as credenciais configuradas.
Ideal para testes manuais e consultas rápidas._


### 4️⃣ Executar consultas analíticasExecutar consultas e relatórios
```bash
make db.query
```
_Executa automaticamente o script `sql/queries/queries.sql` usando as variáveis de conexão definidas no `.env` ou de conexão padrão contidas no Makefile._

### 5️⃣ Encerrar ou reiniciar containers
1. Parar o container sem apagar os dados:
```bash
make down
```

2. Parar e apagar o volume (reset total):
```bash
make down-v
```

### 6️⃣ Conferir ambiente atual
```bash
make env
```
_Exibe o host, porta, usuário e banco utilizados pelos comandos automáticos._


<br>

## 📎 Referências

🔗 [Ver resumo completo do projeto](./docs/Resumo_EduTech.md)

📊 [GitHub Project – EduTech_Consuelo](https://github.com/users/JuliaParnahyba/projects/14)

<br>

📌 **Última atualização:** 24 de outubro de 2025  
📎 **Responsável:** [@JuliaParnahyba](https://github.com/JuliaParnahyba)