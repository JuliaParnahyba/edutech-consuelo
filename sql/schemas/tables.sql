-- ======================================
-- EduTech | tables.sql
-- Objetivo: DDL do banco (tabelas, PK/FK, constraints), tendo as tabelas criadas dentro do schema criado no deploy.sql.
-- ======================================

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
    
    curso_categoria_id                  INT NOT NULL REFERENCES categorias(categoria_id)        ON DELETE RESTRICT,
    curso_instrutor_id                  INT NOT NULL REFERENCES instrutores(instrutor_id)       ON DELETE RESTRICT,
    curso_nivel_id                      INT NOT NULL REFERENCES nivel_cursos(nivel_curso_id)    ON DELETE RESTRICT,

    curso_carga_horaria                 INT NOT NULL CHECK (curso_carga_horaria >= 1),
    curso_preco                         NUMERIC(10,2) NOT NULL CHECK (curso_preco >= 0),

    curso_data_criacao                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    curso_data_atualizacao              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS modulos (
    modulo_id                           SERIAL PRIMARY KEY,
    modulo_curso_id                     INT NOT NULL REFERENCES cursos(curso_id) ON DELETE CASCADE, -- módulos caem com o curso
    modulo_titulo                       VARCHAR(50) NOT NULL,
    modulo_ordem                        INT NOT NULL CHECK (modulo_ordem >= 1),
    modulo_descricao                    VARCHAR(250),

    UNIQUE (modulo_curso_id, modulo_ordem),
    
    modulo_data_criacao                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    modulo_data_atualizacao             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS aulas (
    aula_id                             SERIAL PRIMARY KEY,
    aula_modulo_id                      INT NOT NULL REFERENCES modulos(modulo_id) ON DELETE CASCADE, -- aulas caem com o módulo
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
    ie_instrutor_id                     INT NOT NULL REFERENCES instrutores(instrutor_id)           ON DELETE CASCADE, -- instrutor_especialidades cai com instrutores
    ie_especialidade_id                 INT NOT NULL REFERENCES especialidades(especialidade_id)    ON DELETE RESTRICT, -- não apagar especialidades com vínculos

    PRIMARY KEY (ie_instrutor_id, ie_especialidade_id),

    ie_data_criacao                     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ie_data_atualizacao                 TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS progresso_aulas (
    progresso_id                        SERIAL PRIMARY KEY,
    progresso_matricula_id              INT NOT NULL REFERENCES matriculas(matricula_id)    ON DELETE RESTRICT , -- não apagar matrícula com progresso
    progresso_aula_id                   INT NOT NULL REFERENCES aulas(aula_id)              ON DELETE CASCADE, -- progresso cai com a aula

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
    avaliacao_aluno_id                  INT NOT NULL REFERENCES alunos(aluno_id)    ON DELETE RESTRICT, -- não apagar aluno com avaliações
    avaliacao_aula_id                   INT NOT NULL REFERENCES aulas(aula_id)      ON DELETE CASCADE, -- avaliações caem com a aula

    avaliacao_nota                      INT NOT NULL CHECK (avaliacao_nota BETWEEN 0 AND 5),
    avaliacao_comentario                VARCHAR(150),

    UNIQUE (avaliacao_aluno_id, avaliacao_aula_id),

    avaliacao_data_avaliacao            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    avaliacao_data_atualizacao          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
