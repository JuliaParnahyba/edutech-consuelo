-- ======================================
-- EduTech | deploy.sql
-- Objetivo: "escrever algo"
-- ======================================

\echo '→ Deploy iniciado'
\set ON_ERROR_STOP on
-- BEGIN/COMMIT recurso para evitar criar banco incompleto em caso de erro.
-- Todas as "transações" ficarão dentro do bloco, neste caso, marcando todas as etapas necessárias para criação do banco
BEGIN;
-- 0. Ambiente
    \i sql/env.sql              
-- 1. Tables
    \i sql/schemas/tables.sql   
-- 2. Índices 
    \i sql/schemas/index.sql
-- 3. Triggers
    \i sql/schemas/triggers.sql
-- 4. Comentários
    \i sql/schemas/comments.sql 

-- 5. Seeds básicos (dimensões controladas) via make db.seed
    --\i sql/seeds/nivel_cursos.sql
    --\i sql/seeds/situacoes_matricula.sql

-- 6. Seed principal (demais dimensões e fatos)
    --\i sql/seeds/dados.sql
COMMIT;

\echo '✓ Deploy finalizado'
