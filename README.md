# 🧩 EduTech — Sistema de Gerenciamento de Cursos Online

Projeto educacional desenvolvido no curso **Full Stack** do **Instituto Consuelo**, em parceria com a **Casa Digital**, sob licená **MIT**
Este projeto simula uma plataforma de **gerenciamento de cursos**, focado no domínio de **SQL** e **Python**, com ênfase em **modelagem SQL, manipulação de dados e automação com Python**, bem como boas práticas de versionamento.

<br>

## Sobre o projeto

O **EduTech** é um sistema de gerenciamento de cursos que integra **modelagem SQL robusta** com **automação em Python**.
Seu objetivo é consolidar o aprendizado de banco de dados relacional, consultas analíticas e manipulação de dados, simulando o backend de uma plataforma real de ensino.

O projeto segue uma arquitetura modular e idempotente — todos os scripts podem ser executados múltiplas vezes sem corromper o estado do banco.

<br>

## Funcionalidades
- Criação automática do schema edutech
- Tabelas normalizadas (1FN, 2FN e 3FN)
- Chaves primárias e estrangeiras com integridade referencial
- Consultas SQL analíticas com JOINs, agregações e subqueries
- Geração automática de dados com Python + Faker
- Validação de CSVs e geração de relatórios via scripts auxiliares
- Automação completa com Makefile (deploy, reset, info, queries)
- Docker Compose configurado com PostgreSQL e Adminer

<br>

## Tecnologias utilizadas

| Categoria           | Ferramenta                 |
| ------------------: | :------------------------- |
| Banco de Dados      | PostgreSQL 15              |
| Linguagem de Script | Python 3.12                |
| Biblioteca de Dados | Faker                      |
| Ambiente            | Docker Compose             |
| Interface DB        | Adminer                    |
| Automação           | Makefile                   |
| Documentação        | Markdown + Comentários SQL |

<br>

## Instalação

### Pré-requisitos
- Docker e Docker Compose instalados
- Make disponível no terminal
- Sistema operacional compatível (Linux, WSL2 ou macOS)

## Execução Geral do Projeto com Makefile
A automação do ambiente está feita via **Makefile**, garantindo portabilidade e reprodutibilidade.
Todos os comandos abaixo funcionam em Linux, macOS e WSL2 (Windows).

> <br> 
> 
> Comandos principais disponíveis:
> | Comando            | Descrição                                                            |
> | -----------------: | :------------------------------------------------------------------- |
> | `make up`          | Sobe os containers Docker (`PostgreSQL` + `Adminer`)                 |
> | `make down`        | Derruba os containers (mantém o volume e os dados)                   |
> | `make down-v`      | Derruba containers **e** remove o volume (reset total do banco)      |
> | `make env`         | Exibe as variáveis de ambiente efetivas de conexão                   |
> | `make db.apply`    | Executa o `deploy.sql` (cria ou atualiza o schema completo do banco) |
> | `make db.clean`    | Remove apenas o schema `edutech` (mantendo o banco e usuários)       |
> | `make db.reset`    | Dropa e recria todo o schema, aplicando o `deploy.sql` do zero       |
> | `make db.seed`     | Executa os **seeds** de dados idempotentes (sem apagar os registros) |
> | `make db.seed-dev` | Executa os **seeds** com `TRUNCATE + RESTART IDENTITY` (modo DEV)    |
> | `make db.shell`    | Abre uma sessão interativa `psql` conectada ao banco `edutech`       |
> | `make db.info`     | Exibe um resumo das tabelas, índices, triggers e FKs do schema       |
> | `make db.query`    | Executa as consultas analíticas em `sql/queries/queries.sql`         |
> | `make help`        | Mostra a lista completa de comandos disponíveis e suas descrições    |
>
> 
> <br>

💡 _Dica rápida: execute make help para ver todos os comandos disponíveis com descrição._

<br>

### Clone o repositório
```bash
git clone https://github.com/juliaparnahyba/edutech-consuelo.git
cd edutech-consuelo
```

<br>

### Subir o ambiente PostgreSQL via Docker
```bash
make up
```
1. Cria e inicializa o container PostgreSQL definido no docker-compose.yml.
2. Usa as variáveis de conexão padrão ou definidas no .env.
3. Executa container Adminer para acesso via interface web.

<br>

- _Verificar se o container está ativo, rode:_
```bash
make state
```
<br>

### Acessando o banco via Adminer
Abra o navegador [http://localhost:8080](http://localhost:8080) e preenchar os campos para realizar o login

| Campo        | Valor recomendado |
| -----------: | :---------------- |
| **System**   | PostgreSQL        |
| **Server**   | `db`              |
| **Username** | `edutech_admin`   |
| **Password** | `sua_senha`       |
| **Database** | `edutech`         |

<br>

![Login Adminer](/docs/src_img/image.png)

<br>

### Criar e aplicar o schema completo
```bash
make db.apply
```
_Executa o script sql/deploy.sql, que orquestra:_
  1. Criação do schema edutech
  2. Geração de todas as tabelas, índices e constraints
  3. Criação dos triggers (updated_at)
  4. Inserção de comentários e metadados

<br>

- Para recriar o zero:
```bash
make db.reset
```

<br>

- Para apenas remover o schema:
```bash
make db.clean
```

<br>

### Popular Dados Fictícios
1. Cria CSVs com dados coerentes (alunos, instrutores, cursos, etc.)
```bash
make data.gen
```
_Gera dados sintéticos para acelerar testes e demos do projeto, usando Python + Faker._<br>

O comando alvo aceita argumentos como parâmetros opcionais:
```bash
# Ex.: 1) aumentar a base
make data.gen ALUNOS=500 CURSOS=120

# Ex.: 2) gerar dados reprodutíveis (determinísticos)
make data.gen SEED=42
```
_Se alguma variável não for informada, o gerador usa defaults internos (definidos no Makefile)._

<br>

2. Validador dos dados `.csv`

_Valida a tabela desejada, de forma individual_
```bash
make data.validate TABLE=table_name
```

**ou**

```bash
make data.validate-all
```
_Valida todas as tables de forma sequencial, acompanhadas de logs e resumo final._

<br>

3. Inserir dados diretamente no PostgreSQL
```bash
make db.load-csv
```
_Upa os dados gerados pelo script em Python no banco, de maneira que cada `.csv` corresponda a uma table do banco._

<br>

### Explorar e validar o banco
1. Obtém resumo de estrutura e integridade:
```bash
make db.info
```
Mostra os seguintes dados:
  - Schemas disponíveis
  - Tabelas e índices do schema `edutech`
  - Triggers ativos
  - Regras `ON DELETE` de todas as FKs

<br>

### Executar consultas analíticas e relatórios
```bash
make db.query
```
_Executa automaticamente o script `sql/queries/queries.sql`._

<br>

### Encerrar ou reiniciar containers
1. Parar o container sem apagar os dados:
```bash
make down
```
<br>

2. Parar e apagar o volume (reset total):
```bash
make down-v
```
<br>

### Conferir ambiente atual
```bash
make env
```
_Exibe o host, porta, usuário e banco utilizados pelos comandos automáticos._

<br>

## Estrutura de diretórios

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
│   ├── validators/                    # diretório contendo todos os validadores
│   │   ├── alunos.py                  # scripts de validação por tabela
│   │   └── ...   
│   ├── gerador_dados.py               # gera dados sintéticos com Faker
│   ├── utils.py                       # funções auxiliares
│   └── ...
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

## Fluxo de branches e revisão  

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

## Referências

🔗 [Ver resumo completo do projeto](./docs/Resumo_EduTech.md)

📊 [GitHub Project – EduTech_Consuelo](https://github.com/users/JuliaParnahyba/projects/14)

<br>

## Licença
Distribuído sob a licença MIT.
Consulte o arquivo LICENSE para mais detalhes.

## Sobre a Autora
[Julia Parnaíba](https://www.linkedin.com/in/julia-parnahyba)
Estudante de Engenharia de Software (42 Rio) e participante do curso Full Stack - Instituto Consuelo + Casa Digital.
Atua com automação RPA (UiPath) e desenvolvimento backend.

📌 **Última atualização:** 26 de outubro de 2025  
📎 **Responsável:** [@JuliaParnahyba](https://github.com/JuliaParnahyba)