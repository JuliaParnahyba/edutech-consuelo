-- ======================================
-- EduTech | nivel_cursos.sql
-- Objetivo: DML - inserir dados mínimos para smoke test
-- ======================================

-- TODO: inserts coerentes com o schema (categorias, cursos, alunos, etc.)
\echo '→ Iniciando seed: sql/nivel_cursos.sql'
\echo '================================================='
SET search_path TO edutech, public;

BEGIN;
INSERT INTO nivel_cursos (nivel_curso_nome, nivel_curso_descricao)
VALUES
    ('iniciante', 'Conteúdo introdutório, sem pré-requisitos'),
    ('intermediario', 'Requer bases do tema'),
    ('avancado', 'Exige experiência prévia')
ON CONFLICT (nivel_curso_nome) DO NOTHING;
COMMIT;
\echo '================================================='
\echo '✓ Seed nivel_cursos concluído\n'