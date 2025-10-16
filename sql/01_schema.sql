-- EduTech | schema.sql
-- Objetivo: DDL do banco (tabelas, PK/FK, constraints, índices). Criação do ambiente do BD, tendo as tabelas criadas dentro de um schema.


-- BEGIN/COMMIT recurso para evitar criar banco incompleto em caso de erro.
-- Todas as "transações" ficarão dentro do bloco, neste caso, marcando todas as etapas necessárias para criação do banco
BEGIN;

-- Criação do schema que irá englobar as tables do projeto, de maneira que seja criado apenas se ele não existir.
CREATE SCHEMA IF NOT EXISTS edutech;

-- Define a ordem onde o Postgres procura/cria objetos: primeiro em edutech, depois no schema padrão public.
SET search_path TO edutech, public;

-- Abaixo, criar as tabelas (alunos, instrutores, categorias, cursos, modulos, aulas, matriculas, progresso_aulas, avaliacoes) na ordem correta (quem fornece PK antes de quem usa como FK).
-- Ordem de criação (dependência): 
--  alunos, instrutores e categrias 
--  cursos, modulos e aulas
--  matriculas, progresso_aulas e avaliacoes

-- entidades independentes
CREATE TABLE alunos (
    aluno_id            SERIAL PRIMARY KEY,
    primeiro_nome       TEXT NOT NULL,
    ultimo_nome         TEXT NOT NULL,
    email               TEXT NOT NULL UNIQUE,
    data_nascimento     DATE NOT NULL,
        
    data_criacao        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE instrutores (
    instrutor_id        SERIAL PRIMARY KEY,
    primeiro_nome       TEXT NOT NULL,
    ultimo_nome         TEXT NOT NULL,
    email               TEXT NOT NULL UNIQUE,
    especialidade       TEXT NOT NULL,
    biografia           TEXT,
        
    data_criacao        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE categorias (
    categoria_id        SERIAL PRIMARY KEY,
    nome                TEXT NOT NULL UNIQUE,
    descricao           TEXT,
    
    data_criacao        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- entidades pai
CREATE TABLE cursos (
    curso_id            SERIAL PRIMARY KEY,
    titulo              TEXT NOT NULL UNIQUE,
    descricao           TEXT,
    
    categoria_id        INT NOT NULL REFERENCES categorias(categoria_id),
    instrutor_id        INT NOT NULL REFERENCES instrutores(instrutor_id),

    carga_horaria       INT NOT NULL CHECK (carga_horaria >= 1),
    nivel               TEXT NOT NULL CHECK (nivel IN ('livre', 'tecnico', 'graduacao', 'especializacao')),
    preco               NUMERIC(10,2) NOT NULL CHECK (preco >= 0),

    data_criacao        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE modulos (
    modulo_id           SERIAL PRIMARY KEY,
    curso_id            INT NOT NULL REFERENCES cursos(curso_id),
    titulo              TEXT NOT NULL,
    ordem               INT NOT NULL CHECK (ordem >= 1),
    descricao           TEXT,

    UNIQUE (curso_id, ordem),
    
    data_criacao        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE aulas (
    aula_id             SERIAL PRIMARY KEY,
    modulo_id           INT NOT NULL REFERENCES modulos(modulo_id),
    titulo              TEXT NOT NULL,
    ordem               INT NOT NULL CHECK (ordem >= 1),
    duracao_min         INT NOT NULL CHECK (duracao_min >= 1),
    tipo                TEXT NOT NULL CHECK (tipo IN ('EAD', 'hibrido', 'presencial')),

    UNIQUE (modulo_id, ordem),
    
    data_criacao        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE matriculas (
    matricula_id        SERIAL PRIMARY KEY,
    aluno_id            INT NOT NULL REFERENCES alunos(aluno_id),
    curso_id            INT NOT NULL REFERENCES cursos(curso_id),

    num_matricula       TEXT UNIQUE, -- PARA FAZER: AASSMM#####, GERADO AUTOMATICAMENTE AO GERAR A MATRÍCULA

    data_matricula      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    valor_pago          NUMERIC (10,2) NOT NULL CHECK (valor_pago >= 0),
    
    situacao            TEXT NOT NULL CHECK (situacao IN ('ativo', 'inativo', 'concluido')),
    data_conclusao      TIMESTAMPTZ,
    diploma             BOOLEAN NOT NULL DEFAULT FALSE, -- PARA SER TRUE PRECISA TER X% DO TEMPO TOTAL DO CURSO

    UNIQUE (aluno_id, curso_id),
    
    data_criacao        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- entidades filhas
CREATE TABLE progresso_aulas (
    progresso_id        SERIAL PRIMARY KEY,
    matricula_id        INT NOT NULL REFERENCES matriculas(matricula_id),
    aula_id             INT NOT NULL REFERENCES aulas(aula_id),

    percentual          INT NOT NULL DEFAULT 0 CHECK (percentual BETWEEN 0 AND 100),
    concluida           BOOLEAN NOT NULL DEFAULT FALSE,

    data_conclusao      TIMESTAMPTZ,
    tempo_assistido_min INT NOT NULL CHECK DEFAULT 0 (tempo_assistido_min >= 0),

    UNIQUE (matricula_id, aula_id),

    data_criacao        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE avaliacoes (
    avaliacao_id        SERIAL PRIMARY KEY,
    aluno_id            INT NOT NULL REFERENCES alunos(aluno_id),
    aula_id             INT NOT NULL REFERENCES aulas(aula_id),

    nota                INT NOT NULL CHECK (nota BETWEEN 0 AND 5),
    comentario          TEXT,

    UNIQUE (aluno_id, aula_id),

    data_avaliacao      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMIT;
