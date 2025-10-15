-- EduTech | schema.sql
-- Objetivo: DDL do banco (tabelas, PK/FK, constraints, índices). Criação do ambiente do BD, tendo as tabelas criadas dentro de um schema.


-- BEGIN/COMMIT recurso para evitar criar banco incompleto em caso de erro.
-- Todas as "transações" ficarão dentro do bloco, neste caso, marcando todas as etapas necessárias para criação do banco
BEGIN;

-- Criação do schema que irá englobar as tables do projeto, de maneira que seja criado apenas se ele não existir.
CREATE SCHEMA IF NOT EXISTS edutech;

-- Define a ordem onde o Postgres procura/cria objetos: primeiro em edutech, depois no schema padrão public.
SET search_path TO edutech, public;

-- TODO: criar tabelas (alunos, instrutores, categorias, cursos, modulos, aulas, matriculas, progresso_aulas, avaliacoes) na ordem correta (quem fornece PK antes de quem usa como FK).
-- Ordem de criação (dependência): 
--  alunos, instrutores e categrias 
--  cursos, modulos e aulas
--  matriculas, progresso_aulas e avaliacoes

-- entidades independentes
CREATE TABLE alunos (
    aluno_id        SERIAL PRIMARY KEY,
    primeiro_nome   TEXT NOT NULL,
    ultimo_nome     TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL
);

CREATE TABLE instrutores (
    instrutor_id    SERIAL PRIMARY KEY,
    primeiro_nome   TEXT NOT NULL,
    ultimo_nome     TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    especialidade   TEXT NOT NULL,
    biografia       TEXT
);

CREATE TABLE categorias (
    categoria_id    SERIAL PRIMARY KEY,
    nome            TEXT NOT NULL UNIQUE,
    descricao       TEXT
);


-- entidates pai
CREATE TABLE cursos ();

CREATE TABLE modulos ();

CREATE TABLE aulas ();

CREATE TABLE matriculas ();

CREATE TABLE progresso_aulas ();

CREATE TABLE avaliacoes ();

COMMIT;
