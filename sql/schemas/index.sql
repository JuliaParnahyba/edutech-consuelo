-- ======================================
-- EduTech | index.sql
-- Objetivo: "escrever algo"
-- ======================================

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
