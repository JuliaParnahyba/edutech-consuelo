-- ======================================
-- EduTech | situacoes_matricula.sql
-- Objetivo: DML - inserir dados mínimos para smoke test para situações de matrícula
-- ======================================

-- TODO: inserts coerentes com o schema (categorias, cursos, alunos, etc.)
\echo '→ Iniciando seed: sql/situacoes_matricula.sql'
\echo '================================================='
SET search_path TO edutech, public;

BEGIN;
INSERT INTO situacoes_matricula (situacao_matricula_tipo, situacao_matricula_descricao)
VALUES
    ('ativa', 'Matrícula ativa e acessando o curso'),
    ('pendente', 'Aguardando confirmação/pagamento'),
    ('trancada', 'Acesso suspenso temporariamente'),
    ('cancelada', 'Matrícula cancelada')
ON CONFLICT (situacao_matricula_tipo) DO NOTHING;
COMMIT;
\echo '================================================='
\echo '✓ Seed situacoes_matricula concluído\n'