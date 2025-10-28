-- =======================================================================
-- EduTech | queries.sql (alinhado ao seu DDL)
-- Objetivo: Consultas exploratórias para entender entidades e relações.
-- =======================================================================

SET search_path TO edutech, public;

-- =====================================================
-- 1) Listagens simples (exploratórias)
-- =====================================================
-- 1.1) Cursos com categoria, nível e instrutor (visão geral)
SELECT
    crs.curso_id,
    crs.curso_titulo,
    cg.categoria_nome,
    nc.nivel_curso_nome,
    (ins.instrutor_primeiro_nome || ' ' || ins.instrutor_ultimo_nome) AS instrutor_nome,
    crs.curso_carga_horaria,
    crs.curso_preco,
    crs.curso_data_criacao
FROM edutech.cursos            AS crs
JOIN edutech.categorias        AS cg  ON cg.categoria_id    = crs.curso_categoria_id
JOIN edutech.nivel_cursos      AS nc  ON nc.nivel_curso_id  = crs.curso_nivel_id
JOIN edutech.instrutores       AS ins ON ins.instrutor_id   = crs.curso_instrutor_id
ORDER BY crs.curso_titulo;

-- 1.2) Alunos
SELECT
    a.aluno_id,
    (a.aluno_primeiro_nome || ' ' || a.aluno_ultimo_nome) AS aluno_nome,
    a.aluno_email,
    a.aluno_data_nascimento,
    a.aluno_data_criacao
FROM edutech.alunos AS a
ORDER BY a.aluno_data_criacao DESC, aluno_nome;

-- 1.3) Matrículas (com rótulo da situação)
SELECT
    m.matricula_id,
    m.matricula_aluno_id,
    m.matricula_curso_id,
    sm.situacao_matricula_tipo AS situacao,
    m.matricula_data_matricula
FROM edutech.matriculas AS m
JOIN edutech.situacoes_matricula AS sm
  ON sm.situacao_matricula_id = m.matricula_situacao_id
ORDER BY m.matricula_data_matricula DESC;

-- =====================================================
-- 2) Relacionamentos por tema
-- =====================================================
-- 2.1) Cursos por categoria (param opcional :categoria_id)
SELECT
    cg.categoria_nome,
    crs.curso_id,
    crs.curso_titulo
FROM edutech.cursos     AS crs
JOIN edutech.categorias AS cg ON cg.categoria_id = crs.curso_categoria_id
WHERE (categoria_id IS NULL) OR (cg.categoria_id = categoria_id)
ORDER BY cg.categoria_nome, crs.curso_titulo;

-- 2.2) Cursos por instrutor (param opcional :instrutor_id)
SELECT
    (ins.instrutor_primeiro_nome || ' ' || ins.instrutor_ultimo_nome) AS instrutor_nome,
    crs.curso_id,
    crs.curso_titulo
FROM edutech.cursos AS crs
JOIN edutech.instrutores AS ins
  ON ins.instrutor_id = crs.curso_instrutor_id
WHERE (instrutor_id IS NULL) OR (crs.curso_instrutor_id = instrutor_id)
ORDER BY instrutor_nome, crs.curso_titulo;

-- 2.3) Módulos e aulas por curso (param opcional :curso_id)
SELECT
    crs.curso_titulo,
    md.modulo_id,
    md.modulo_titulo,
    md.modulo_ordem,
    au.aula_id,
    au.aula_titulo,
    au.aula_ordem,
    au.aula_duracao_min,
    au.aula_tipo
FROM edutech.cursos  AS crs
JOIN edutech.modulos AS md ON md.modulo_curso_id = crs.curso_id
LEFT JOIN edutech.aulas AS au ON au.aula_modulo_id = md.modulo_id
WHERE (curso_id IS NULL) OR (crs.curso_id = curso_id)
ORDER BY crs.curso_titulo, md.modulo_ordem, au.aula_ordem;

-- 2.4) Alunos matriculados por curso (com situação)
SELECT
    crs.curso_titulo,
    (a.aluno_primeiro_nome || ' ' || a.aluno_ultimo_nome) AS aluno_nome,
    sm.situacao_matricula_tipo AS situacao,
    m.matricula_data_matricula
FROM edutech.matriculas AS m
JOIN edutech.alunos AS a   ON a.aluno_id   = m.matricula_aluno_id
JOIN edutech.cursos AS crs ON crs.curso_id = m.matricula_curso_id
JOIN edutech.situacoes_matricula AS sm ON sm.situacao_matricula_id = m.matricula_situacao_id
WHERE (curso_id IS NULL) OR (m.matricula_curso_id = curso_id)
ORDER BY crs.curso_titulo, aluno_nome;

-- =====================================================
-- 3) Contagens e agregações
-- =====================================================
-- 3.1) Matrículas por curso (todas as situações)
SELECT
    crs.curso_id,
    crs.curso_titulo,
    COUNT(*) AS total_matriculas
FROM edutech.matriculas AS m
JOIN edutech.cursos AS crs ON crs.curso_id = m.matricula_curso_id
GROUP BY crs.curso_id, crs.curso_titulo
ORDER BY total_matriculas DESC, crs.curso_titulo;

-- 3.2) Matrículas por curso (apenas “ativa”)
SELECT
    crs.curso_id,
    crs.curso_titulo,
    COUNT(*) AS matriculas_ativas
FROM edutech.matriculas AS m
JOIN edutech.cursos AS crs ON crs.curso_id = m.matricula_curso_id
JOIN edutech.situacoes_matricula AS sm ON sm.situacao_matricula_id = m.matricula_situacao_id
WHERE sm.situacao_matricula_tipo ILIKE 'ativa'
GROUP BY crs.curso_id, crs.curso_titulo
ORDER BY matriculas_ativas DESC, crs.curso_titulo;

-- 3.3) Matrículas por categoria
SELECT
    cg.categoria_nome,
    COUNT(*) AS total_matriculas
FROM edutech.matriculas AS m
JOIN edutech.cursos AS crs ON crs.curso_id = m.matricula_curso_id
JOIN edutech.categorias AS cg ON cg.categoria_id = crs.curso_categoria_id
GROUP BY cg.categoria_nome
ORDER BY total_matriculas DESC, cg.categoria_nome;

-- 3.4) Cursos com ao menos N aulas (param :min_aulas; padrão 10)
WITH aulas_por_curso AS (
    SELECT
        crs.curso_id,
        crs.curso_titulo,
        COUNT(au.aula_id) AS qtd_aulas
    FROM edutech.cursos  AS crs
    JOIN edutech.modulos AS md ON md.modulo_curso_id = crs.curso_id
    LEFT JOIN edutech.aulas AS au ON au.aula_modulo_id = md.modulo_id
    GROUP BY crs.curso_id, crs.curso_titulo
)
SELECT *
FROM aulas_por_curso
WHERE qtd_aulas >= COALESCE(aulas_por_curso.qtd_aulas, 10)
ORDER BY qtd_aulas DESC, curso_titulo;

-- =====================================================
-- 4) Diagnósticos e qualidade de dados
-- =====================================================
-- 4.1) Cursos sem instrutor associado (não deve ocorrer pelo seu DDL atual)
SELECT
    crs.curso_id,
    crs.curso_titulo
FROM edutech.cursos AS crs
LEFT JOIN edutech.instrutores AS ins ON ins.instrutor_id = crs.curso_instrutor_id
WHERE crs.curso_instrutor_id IS NULL
   OR ins.instrutor_id IS NULL
ORDER BY crs.curso_titulo;

-- 4.2) Aulas órfãs (módulo inexistente) — deve retornar vazio
SELECT
    au.aula_id,
    au.aula_titulo
FROM edutech.aulas AS au
LEFT JOIN edutech.modulos AS md ON md.modulo_id = au.aula_modulo_id
WHERE md.modulo_id IS NULL;

-- 4.3) Percentual de matrículas por situação (global)
SELECT
    sm.situacao_matricula_tipo AS situacao,
    COUNT(*) AS qtd,
    ROUND(100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0), 2) AS pct
FROM edutech.matriculas AS m
JOIN edutech.situacoes_matricula AS sm ON sm.situacao_matricula_id = m.matricula_situacao_id
GROUP BY sm.situacao_matricula_tipo
ORDER BY qtd DESC;

-- =====================================================
-- 6) Visões rápidas (resumos)
-- =====================================================
-- 6.1) Resumo de cursos (qtd módulos, qtd aulas)
WITH mods AS (
    SELECT md.modulo_curso_id AS curso_id, COUNT(*) AS qtd_modulos
    FROM edutech.modulos md
    GROUP BY md.modulo_curso_id
),
aulas AS (
    SELECT md.modulo_curso_id AS curso_id, COUNT(au.aula_id) AS qtd_aulas
    FROM edutech.modulos md
    LEFT JOIN edutech.aulas au ON au.aula_modulo_id = md.modulo_id
    GROUP BY md.modulo_curso_id
)
SELECT
    crs.curso_id,
    crs.curso_titulo,
    COALESCE(m.qtd_modulos, 0) AS qtd_modulos,
    COALESCE(a.qtd_aulas, 0)   AS qtd_aulas
FROM edutech.cursos crs
LEFT JOIN mods  m ON m.curso_id = crs.curso_id
LEFT JOIN aulas a ON a.curso_id = crs.curso_id
ORDER BY qtd_aulas DESC, qtd_modulos DESC, crs.curso_titulo;

-- 6.2) Resumo de alunos (qtd matrículas e última data)
SELECT
    a.aluno_id,
    (a.aluno_primeiro_nome || ' ' || a.aluno_ultimo_nome) AS aluno_nome,
    COUNT(m.matricula_id) AS qtd_matriculas,
    MAX(m.matricula_data_matricula) AS ultima_matricula
FROM edutech.alunos a
LEFT JOIN edutech.matriculas m ON m.matricula_aluno_id = a.aluno_id
GROUP BY a.aluno_id, aluno_nome
ORDER BY qtd_matriculas DESC, ultima_matricula DESC NULLS LAST, aluno_nome;
