-- ======================================
-- EduTech | dados.sql
-- Seed principal: dados consistentes e reprodutíveis para o ambiente DEV e testes.
-- ======================================

\echo '\n→ Iniciando seed: sql/dados.sql'
\echo '================================================='
SET search_path TO edutech, public;

-- Toggle DEV: TRUNCATE + RESTART IDENTITY
\if :{?DEV}
    \echo '⚠️  DEV=on → TRUNCATE + RESTART IDENTITY (CASCADE)\n'
    BEGIN;
        TRUNCATE TABLE
            progresso_aulas,
            avaliacoes,
            matriculas,
            aulas,
            modulos,
            cursos,
            instrutor_especialidades,
            instrutores,
            alunos,
            categorias,
            especialidades,
            nivel_cursos,
            situacoes_matricula
        RESTART IDENTITY CASCADE;
    COMMIT;
\else
    \echo 'ℹ️  DEV=off → sem TRUNCATE; será usado ON CONFLICT DO NOTHING\n'
\endif

-- Seguraça
SET client_min_messages = WARNING;
BEGIN;

-- 1) DIMENSÕES BÁSICAS: especialidades, categorias
-- 1.1 Especialidades
INSERT INTO especialidades (especialidade_nome, especialidade_descricao)
VALUES
    ('Programação', 'Linguagens e fundamentos de código'),
    ('Dados', 'Análise, engenharia e banco de dados'),
    ('Produtividade', 'Ferramentas e rotinas de trabalho')
ON CONFLICT (especialidade_nome) DO NOTHING;

-- 1.2 Categorias
INSERT INTO categorias (categoria_nome, categoria_descricao)
VALUES
    ('Programação', 'Cursos de linguagens e fundamentos'),
    ('Dados', 'Consultas, modelagem e análise'),
    ('Produtividade', 'Ferramentas e práticas do dia a dia')
ON CONFLICT (categoria_nome) DO NOTHING;


-- 2) NÍVEIS DE CURSO e SITUAÇÕES DE MATRÍCULA (já cobertos nos seeds)
-- (mantemos aqui apenas como fallback idempotente caso rode isolado)
INSERT INTO nivel_cursos (nivel_curso_nome, nivel_curso_descricao)
VALUES
    ('iniciante', 'Conteúdo introdutório, sem pré-requisitos'),
    ('intermediario', 'Requer bases do tema'),
    ('avancado', 'Exige experiência prévia')
ON CONFLICT (nivel_curso_nome) DO NOTHING;

INSERT INTO situacoes_matricula (situacao_matricula_tipo, situacao_matricula_descricao)
VALUES
    ('ativa', 'Matrícula ativa e acessando o curso'),
    ('pendente', 'Aguardando confirmação/pagamento'),
    ('trancada', 'Acesso suspenso temporariamente'),
    ('cancelada', 'Matrícula cancelada')
ON CONFLICT (situacao_matricula_tipo) DO NOTHING;


-- 3) INSTRUTORES + VÍNCULOS DE ESPECIALIDADES
-- instrutor_especial_principal_id referencia especialidades(especialidade_id)
WITH sp AS (
  SELECT especialidade_id, especialidade_nome FROM especialidades
),
src AS (
    SELECT * FROM (VALUES
        ('Ana', 'Souza', 'ana.souza@edutech.dev', 'Programação', 'Eng. de Software e educadora.'),
        ('Carlos', 'Lima', 'carlos.lima@edutech.dev', 'Dados', 'Cientista de Dados e instrutor.')
    ) AS v(fn, ln, email, esp_principal_nome, bio)
),
esp_principal AS (
    SELECT s.fn, s.ln, s.email, s.bio, sp.especialidade_id AS esp_id
    FROM src s
    JOIN sp  ON sp.especialidade_nome = s.esp_principal_nome
)
INSERT INTO instrutores (
    instrutor_primeiro_nome, instrutor_ultimo_nome, instrutor_email,
    instrutor_especial_principal_id, instrutor_biografia
)
SELECT fn, ln, email, esp_id, bio
FROM esp_principal
ON CONFLICT (instrutor_email) DO NOTHING;

-- Vínculo N:N secundário (instrutor_especialidades)
-- (idempotente via PK (ie_instrutor_id, ie_especialidade_id))
INSERT INTO instrutor_especialidades (ie_instrutor_id, ie_especialidade_id)
SELECT i.instrutor_id, e.especialidade_id
FROM instrutores i
JOIN especialidades e ON e.especialidade_nome IN ('Programação','Dados')
WHERE i.instrutor_email = 'ana.souza@edutech.dev'
ON CONFLICT DO NOTHING;

INSERT INTO instrutor_especialidades (ie_instrutor_id, ie_especialidade_id)
SELECT i.instrutor_id, e.especialidade_id
FROM instrutores i
JOIN especialidades e ON e.especialidade_nome IN ('Dados')
WHERE i.instrutor_email = 'carlos.lima@edutech.dev'
ON CONFLICT DO NOTHING;


-- 4) CURSOS
WITH cat AS (SELECT categoria_id, categoria_nome FROM categorias),
    ins AS (SELECT instrutor_id, instrutor_email FROM instrutores),
    nv AS (SELECT nivel_curso_id, nivel_curso_nome FROM nivel_cursos),
src AS (
    SELECT * FROM (VALUES
        ('SQL do Zero', 'Fundamentos de modelagem e consultas SQL.', 'Dados', 'carlos.lima@edutech.dev', 'iniciante', 12, 149.90),
        ('Python para Iniciantes', 'Primeiros passos com Python para automações.', 'Programação', 'ana.souza@edutech.dev', 'iniciante', 16, 199.90),
        ('Dashboards com SQL', 'Consultas analíticas e visualização para BI.', 'Dados', 'carlos.lima@edutech.dev', 'intermediario', 20, 249.90)
    ) AS v(titulo, descricao, categoria_nome, email_instrutor, nivel_nome, carga_h, preco)
)
INSERT INTO cursos (
    curso_titulo, curso_descricao,
    curso_categoria_id, curso_instrutor_id, curso_nivel_id,
    curso_carga_horaria, curso_preco
)
SELECT s.titulo, s.descricao, c.categoria_id, i.instrutor_id, n.nivel_curso_id, s.carga_h, s.preco
FROM src s
JOIN cat c ON c.categoria_nome = s.categoria_nome
JOIN ins i ON i.instrutor_email = s.email_instrutor
JOIN nv  n ON n.nivel_curso_nome = s.nivel_nome
ON CONFLICT (curso_titulo) DO NOTHING;


-- 5) MÓDULOS (UNIQUE por curso+ordem) e AULAS (UNIQUE por módulo+ordem)
-- Módulos
WITH cur AS (SELECT curso_id, curso_titulo FROM cursos),
mod_src AS (
    SELECT * FROM (VALUES
        ('SQL do Zero', 1, 'Introdução e ambiente', 'Configuração de ferramentas e visão geral'),
        ('SQL do Zero', 2, 'SELECT, filtros e ordenação', 'Consultas básicas e filtros'),
        ('SQL do Zero', 3, 'JOINs e agregações', 'Relacionamentos e métricas'),
        ('Python para Iniciantes', 1, 'Ambiente e sintaxe', 'Instalação, venv, hello world'),
        ('Python para Iniciantes', 2, 'Estruturas de dados', 'Listas e dicionários'),
        ('Dashboards com SQL', 1, 'Consultas analíticas', 'CTEs, janelas e métricas'),
        ('Dashboards com SQL', 2, 'Modelagem para BI', 'Dimensões e fatos')
    ) AS v(curso_titulo, ordem, titulo_mod, desc_mod)
)
INSERT INTO modulos (modulo_curso_id, modulo_ordem, modulo_titulo, modulo_descricao)
SELECT c.curso_id, m.ordem, m.titulo_mod, m.desc_mod
FROM mod_src m
JOIN cur c ON c.curso_titulo = m.curso_titulo
ON CONFLICT (modulo_curso_id, modulo_ordem) DO NOTHING;

-- Aulas
WITH mods AS (
    SELECT mo.modulo_id, mo.modulo_ordem, cu.curso_titulo
    FROM modulos mo
    JOIN cursos cu ON cu.curso_id = mo.modulo_curso_id
),
aul_src AS (
    SELECT * FROM (VALUES
        ('SQL do Zero', 1, 1, 'Visão geral + psql/GUI', 18, 'EAD'),
        ('SQL do Zero', 2, 1, 'Cláusulas WHERE/ORDER BY', 22, 'EAD'),
        ('SQL do Zero', 3, 1, 'JOINs, GROUP BY, HAVING', 25, 'EAD'),
        ('Python para Iniciantes', 1, 1, 'Instalação, venv e hello world', 15, 'EAD'),
        ('Python para Iniciantes', 2, 1, 'Listas e dicionários', 24, 'EAD'),
        ('Dashboards com SQL', 1, 1, 'CTEs e janelas', 27, 'EAD'),
        ('Dashboards com SQL', 2, 1, 'Dimensões e fatos', 20, 'EAD')
    ) AS v(curso_titulo, modulo_ordem, aula_ordem, titulo_aula, dur_min, tipo)
)
INSERT INTO aulas (aula_modulo_id, aula_ordem, aula_titulo, aula_duracao_min, aula_tipo)
SELECT m.modulo_id, a.aula_ordem, a.titulo_aula, a.dur_min, a.tipo
FROM aul_src a
JOIN mods m ON m.curso_titulo = a.curso_titulo AND m.modulo_ordem = a.modulo_ordem
ON CONFLICT (aula_modulo_id, aula_ordem) DO NOTHING;


-- 6) ALUNOS
INSERT INTO alunos (aluno_primeiro_nome, aluno_ultimo_nome, aluno_email, aluno_data_nascimento)
VALUES
    ('Julia', 'Parnahyba', 'julia.parnahyba@alunas.dev', DATE '1996-08-12'),
    ('Marina', 'Duarte', 'marina.duarte@alunas.dev', DATE '1994-02-05'),
    ('Paula', 'Nogueira', 'paula.nog@alunas.dev', DATE '1993-11-20'),
    ('Fernanda', 'Reis', 'fernanda.reis@alunas.dev', DATE '1997-04-09'),
    ('Rafaela', 'Castro', 'rafa.castro@alunas.dev', DATE '1998-06-23')
ON CONFLICT (aluno_email) DO NOTHING;


-- 7) MATRÍCULAS (único aluno×curso), com situação e valor
WITH alu AS (SELECT aluno_id, aluno_email FROM alunos),
    cur AS (SELECT curso_id, curso_titulo, curso_preco FROM cursos),
    st AS (SELECT situacao_matricula_id, situacao_matricula_tipo FROM situacoes_matricula),
src AS (
    SELECT * FROM (VALUES
        ('julia.parnahyba@alunas.dev', 'SQL do Zero', 'ativa'),
        ('julia.parnahyba@alunas.dev', 'Python para Iniciantes', 'ativa'),
        ('marina.duarte@alunas.dev', 'SQL do Zero', 'ativa'),
        ('paula.nog@alunas.dev', 'Dashboards com SQL', 'ativa'),
        ('fernanda.reis@alunas.dev', 'Python para Iniciantes', 'ativa'),
        ('fernanda.reis@alunas.dev', 'SQL do Zero', 'ativa'),
        ('rafa.castro@alunas.dev', 'SQL do Zero', 'ativa'),
        ('rafa.castro@alunas.dev', 'Dashboards com SQL', 'pendente')
    ) AS v(email_aluno, titulo_curso, situacao)
)
INSERT INTO matriculas (
    matricula_aluno_id, matricula_curso_id, matricula_situacao_id,
    matricula_valor_pago, matricula_data_matricula, matricula_diploma
)
SELECT a.aluno_id, c.curso_id, s.situacao_matricula_id,
    CASE x.situacao WHEN 'pendente' THEN 0 ELSE c.curso_preco END AS valor_pago,
    NOW()::timestamptz - (random()*30)::int * INTERVAL '1 day',
    false
FROM src x
JOIN alu a ON a.aluno_email = x.email_aluno
JOIN cur c ON c.curso_titulo = x.titulo_curso
JOIN st  s ON s.situacao_matricula_tipo = x.situacao
ON CONFLICT (matricula_aluno_id, matricula_curso_id) DO NOTHING;

COMMIT;


-- Validações pós-seed
\echo '\n→ Validações pós-seed\n'

-- Contagens por tabela
SELECT 'categorias'  AS tabela, COUNT(*) AS total   FROM categorias     UNION ALL
SELECT 'instrutores',           COUNT(*)            FROM instrutores    UNION ALL
SELECT 'cursos',                COUNT(*)            FROM cursos         UNION ALL
SELECT 'modulos',               COUNT(*)            FROM modulos        UNION ALL
SELECT 'aulas',                 COUNT(*)            FROM aulas          UNION ALL
SELECT 'alunos',                COUNT(*)            FROM alunos         UNION ALL
SELECT 'matriculas',            COUNT(*)            FROM matriculas     ORDER BY tabela;



SELECT
  (SELECT COUNT(*) FROM categorias)             >= 3 AS ok_categorias,
  (SELECT COUNT(*) FROM especialidades)         >= 3 AS ok_especialidades,
  (SELECT COUNT(*) FROM nivel_cursos)           >= 3 AS ok_niveis,
  (SELECT COUNT(*) FROM situacoes_matricula)    >= 3 AS ok_situacoes,
  (SELECT COUNT(*) FROM instrutores)            >= 2 AS ok_instrutores,
  (SELECT COUNT(*) FROM cursos)                 >= 3 AS ok_cursos,
  (SELECT COUNT(*) FROM modulos)                >= 3 AS ok_modulos,
  (SELECT COUNT(*) FROM aulas)                  >= 3 AS ok_aulas,
  (SELECT COUNT(*) FROM alunos)                 >= 5 AS ok_alunos,
  (SELECT COUNT(*) FROM matriculas)             >= 8 AS ok_matriculas;

\echo '================================================='
\echo '✓ Seed concluído\n'