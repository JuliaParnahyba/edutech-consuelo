-- EduTech | 01_schema.sql
-- Objetivo: DDL do banco (tabelas, PK/FK, constraints, índices). Criação do ambiente do BD, tendo as tabelas criadas dentro de um schema.


-- BEGIN/COMMIT recurso para evitar criar banco incompleto em caso de erro.
-- Todas as "transações" ficarão dentro do bloco, neste caso, marcando todas as etapas necessárias para criação do banco
BEGIN;

-- 1. Criação do schema que irá englobar as tables do projeto, de maneira que seja criado apenas se ele não existir.
CREATE SCHEMA IF NOT EXISTS edutech;
-- Define a ordem onde o Postgres procura/cria objetos: primeiro em edutech, depois no schema padrão public.
SET search_path TO edutech, public;

-- 2. Criação das tabelas na ordem correta (quem fornece PK antes de quem usa como FK).
-- entidades independentes
CREATE TABLE IF NOT EXISTS alunos (
    aluno_id                            SERIAL PRIMARY KEY,
    aluno_primeiro_nome                 VARCHAR(50) NOT NULL,
    aluno_ultimo_nome                   VARCHAR(50) NOT NULL,
    aluno_email                         TEXT NOT NULL UNIQUE,
    aluno_data_nascimento               DATE NOT NULL,
        
    aluno_data_criacao                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    aluno_data_atualizacao              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS especialidades (
    especialidade_id                    SERIAL PRIMARY KEY,
    especialidade_nome                  VARCHAR(50) NOT NULL UNIQUE,
    especialidade_descricao             VARCHAR(150),

    especialidade_data_criacao          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    especialidade_data_atualizacao      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS categorias (
    categoria_id                        SERIAL PRIMARY KEY,
    categoria_nome                      VARCHAR(50) NOT NULL UNIQUE,
    categoria_descricao                 VARCHAR(150),
    
    categoria_data_criacao              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    categoria_data_atualizacao          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS nivel_cursos (
    nivel_curso_id                      SERIAL PRIMARY KEY,
    nivel_curso_nome                    VARCHAR(15) NOT NULL UNIQUE,
    nivel_curso_descricao               VARCHAR(100) NOT NULL,

    nivel_curso_data_criacao            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    nivel_curso_data_atualizacao        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS situacoes_matricula (
    situacao_matricula_id               SERIAL  PRIMARY KEY,
    situacao_matricula_tipo             VARCHAR(15) NOT NULL UNIQUE,
    situacao_matricula_descricao        VARCHAR(50) NOT NULL,

    situacao_matricula_data_criacao     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    situacao_matricula_data_atualizacao TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- entidades pai
CREATE TABLE IF NOT EXISTS instrutores (
    instrutor_id                        SERIAL PRIMARY KEY,
    instrutor_primeiro_nome             VARCHAR(50) NOT NULL,
    instrutor_ultimo_nome               VARCHAR(50) NOT NULL,
    instrutor_email                     TEXT NOT NULL UNIQUE,
    instrutor_especial_principal_id     INT NOT NULL REFERENCES especialidades(especialidade_id),   
    instrutor_biografia                 VARCHAR(300),
        
    instrutor_data_criacao              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    instrutor_data_atualizacao          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cursos (
    curso_id                            SERIAL PRIMARY KEY,
    curso_titulo                        VARCHAR(100) NOT NULL UNIQUE,
    curso_descricao                     VARCHAR(250),
    
    curso_categoria_id                  INT NOT NULL REFERENCES categorias(categoria_id),
    curso_instrutor_id                  INT NOT NULL REFERENCES instrutores(instrutor_id),
    curso_nivel_id                      INT NOT NULL REFERENCES nivel_cursos(nivel_curso_id) ON DELETE RESTRICT,

    curso_carga_horaria                 INT NOT NULL CHECK (curso_carga_horaria >= 1),
    curso_preco                         NUMERIC(10,2) NOT NULL CHECK (curso_preco >= 0),

    curso_data_criacao                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    curso_data_atualizacao              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS modulos (
    modulo_id                           SERIAL PRIMARY KEY,
    modulo_curso_id                     INT NOT NULL REFERENCES cursos(curso_id),
    modulo_titulo                       VARCHAR(50) NOT NULL,
    modulo_ordem                        INT NOT NULL CHECK (modulo_ordem >= 1),
    modulo_descricao                    VARCHAR(250),

    UNIQUE (modulo_curso_id, modulo_ordem),
    
    modulo_data_criacao                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    modulo_data_atualizacao             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS aulas (
    aula_id                             SERIAL PRIMARY KEY,
    aula_modulo_id                      INT NOT NULL REFERENCES modulos(modulo_id),
    aula_titulo                         VARCHAR(50) NOT NULL,
    aula_ordem                          INT NOT NULL CHECK (aula_ordem >= 1),
    aula_duracao_min                    INT NOT NULL CHECK (aula_duracao_min >= 1),
    aula_tipo                           VARCHAR(15) NOT NULL CHECK (aula_tipo IN ('EAD', 'hibrido', 'presencial')),

    UNIQUE (aula_modulo_id, aula_ordem),
    
    aula_data_criacao                   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    aula_data_atualizacao               TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS matriculas (
    matricula_id                        SERIAL PRIMARY KEY,
    matricula_aluno_id                  INT NOT NULL REFERENCES alunos(aluno_id),
    matricula_curso_id                  INT NOT NULL REFERENCES cursos(curso_id),
    matricula_situacao_id               INT NOT NULL REFERENCES situacoes_matricula(situacao_matricula_id),

    matricula_num_matricula             VARCHAR(12) UNIQUE, -- PARA FAZER: AASSMM#####, GERADO AUTOMATICAMENTE AO GERAR A MATRÍCULA

    matricula_data_matricula            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    matricula_valor_pago                NUMERIC (10,2) NOT NULL CHECK (matricula_valor_pago >= 0),
    
    matricula_data_conclusao            TIMESTAMPTZ,
    matricula_diploma                   BOOLEAN NOT NULL DEFAULT FALSE, -- PARA SER TRUE PRECISA TER X% DO TEMPO TOTAL DO CURSO

    UNIQUE (matricula_aluno_id, matricula_curso_id),
    
    matricula_data_criacao              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    matricula_data_atualizacao          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- entidades filhas
CREATE TABLE IF NOT EXISTS instrutor_especialidades (
    ie_instrutor_id                     INT NOT NULL REFERENCES instrutores(instrutor_id)           ON DELETE CASCADE,
    ie_especialidade_id                 INT NOT NULL REFERENCES especialidades(especialidade_id)    ON DELETE RESTRICT,

    PRIMARY KEY (ie_instrutor_id, ie_especialidade_id),

    ie_data_criacao                     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ie_data_atualizacao                 TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS progresso_aulas (
    progresso_id                        SERIAL PRIMARY KEY,
    progresso_matricula_id              INT NOT NULL REFERENCES matriculas(matricula_id),
    progresso_aula_id                   INT NOT NULL REFERENCES aulas(aula_id),

    progresso_percentual                INT NOT NULL DEFAULT 0 CHECK (progresso_percentual BETWEEN 0 AND 100),
    progresso_concluida                 BOOLEAN NOT NULL DEFAULT FALSE,

    progresso_data_conclusao            TIMESTAMPTZ,
    progresso_tempo_assistido_min       INT NOT NULL DEFAULT 0 CHECK (progresso_tempo_assistido_min >= 0),

    UNIQUE (progresso_matricula_id, progresso_aula_id),

    progresso_data_criacao              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    progresso_data_atualizacao          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS avaliacoes (
    avaliacao_id                        SERIAL PRIMARY KEY,
    avaliacao_aluno_id                  INT NOT NULL REFERENCES alunos(aluno_id),
    avaliacao_aula_id                   INT NOT NULL REFERENCES aulas(aula_id),

    avaliacao_nota                      INT NOT NULL CHECK (avaliacao_nota BETWEEN 0 AND 5),
    avaliacao_comentario                VARCHAR(150),

    UNIQUE (avaliacao_aluno_id, avaliacao_aula_id),

    avaliacao_data_avaliacao            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    avaliacao_data_atualizacao          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Criação dos índices
-- índices FKs de cursos
CREATE INDEX IF NOT EXISTS idx_edutech_cursos__categoria_id
    ON edutech.cursos (curso_categoria_id);

CREATE INDEX IF NOT EXISTS idx_edutech_cursos__instrutor_id
    ON edutech.cursos (curso_instrutor_id);

CREATE INDEX IF NOT EXISTS idx_edutech_cursos__nivel_id
    ON edutech.cursos (curso_nivel_id);

-- índices FKs de modulos
CREATE INDEX IF NOT EXISTS idx_edutech_modulos__curso_id
    ON edutech.modulos (modulo_curso_id);

-- índices FKs de aulas
CREATE INDEX IF NOT EXISTS idx_edutech_aulas__modulo_id
    ON edutech.aulas (aula_modulo_id);

-- índices FKs de matriculas
CREATE INDEX IF NOT EXISTS idx_edutech_matriculas__aluno_id
    ON edutech.matriculas (matricula_aluno_id);

CREATE INDEX IF NOT EXISTS idx_edutech_matriculas__curso_id
    ON edutech.matriculas (matricula_curso_id);

-- índice composto para filtros/relatórios por curso + situação
CREATE INDEX IF NOT EXISTS idx_edutech_matriculas__curso_id_situacao_id
    ON edutech.matriculas (matricula_curso_id, matricula_situacao_id);

-- índice de especialidade por instrutor
CREATE INDEX IF NOT EXISTS idx_edutech_instrutores__esp_principal
    ON edutech.instrutores (instrutor_especial_principal_id);

-- Junção N:N. índice inverso para buscar instrutores por especialidade:
CREATE INDEX IF NOT EXISTS idx_edutech_instrutor_especialidades__especialidade_id
    ON edutech.instrutor_especialidades (ie_especialidade_id);

-- Para filtrar por especialidade + instrutor:
CREATE INDEX IF NOT EXISTS idx_edutech_instrutor_especialidades__esp_instrutor
    ON edutech.instrutor_especialidades (ie_especialidade_id, ie_instrutor_id);

-- índices FKs/UNIQUEs em progresso_aulas
-- UNIQUE (progresso_matricula_id, progresso_aula_id) cobre primeira coluna
CREATE INDEX IF NOT EXISTS idx_edutech_progresso_aulas__aula_id
    ON edutech.progresso_aulas (progresso_aula_id);

-- Índices FKs/UNIQUEs de avaliacoes
-- UNIQUE (avaliacoes_aluno_id, avaliacoes_aula_id) já cobre a 1ª coluna
CREATE INDEX IF NOT EXISTS idx_edutech_avaliacoes__aula_id
    ON edutech.avaliacoes (avaliacao_aula_id);

-- 4. Triggers
-- Função simples, trigger por tabela.

COMMIT;
