-- EduTech | triggers.sql
-- Objetivo: "escrever algo"

-- 4. Triggers | Função simples, trigger por tabela.
-- ALUNOS
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_alunos_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.aluno_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_alunos_set_updated_at ON edutech.alunos;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_alunos_set_updated_at
BEFORE UPDATE ON edutech.alunos
FOR EACH ROW EXECUTE FUNCTION edutech.fn_alunos_touch_updated_at();


-- ESPECIALIDADES
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_especialidades_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.especialidade_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_especialidades_set_updated_at ON edutech.especialidades;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_especialidades_set_updated_at
BEFORE UPDATE ON edutech.especialidades
FOR EACH ROW EXECUTE FUNCTION edutech.fn_especialidades_touch_updated_at();


-- CATEGORIAS
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_categorias_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.categoria_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_categorias_set_updated_at ON edutech.categorias;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_categorias_set_updated_at
BEFORE UPDATE ON edutech.categorias
FOR EACH ROW EXECUTE FUNCTION edutech.fn_categorias_touch_updated_at();


-- NIVEL_CURSOS
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_nivel_cursos_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.nivel_curso_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_nivel_cursos_set_updated_at ON edutech.nivel_cursos;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_nivel_cursos_set_updated_at
BEFORE UPDATE ON edutech.nivel_cursos
FOR EACH ROW EXECUTE FUNCTION edutech.fn_nivel_cursos_touch_updated_at();


-- SITUACOES_MATRICULA
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_situacoes_matricula_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.situacao_matricula_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_situacoes_matricula_set_updated_at ON edutech.situacoes_matricula;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_situacoes_matricula_set_updated_at
BEFORE UPDATE ON edutech.situacoes_matricula
FOR EACH ROW EXECUTE FUNCTION edutech.fn_situacoes_matricula_touch_updated_at();


-- INSTRUTORES
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_instrutores_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.instrutor_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_instrutores_set_updated_at ON edutech.instrutores;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_instrutores_set_updated_at
BEFORE UPDATE ON edutech.instrutores
FOR EACH ROW EXECUTE FUNCTION edutech.fn_instrutores_touch_updated_at();


-- CURSOS
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_cursos_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.curso_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_cursos_set_updated_at ON edutech.cursos;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_cursos_set_updated_at
BEFORE UPDATE ON edutech.cursos
FOR EACH ROW EXECUTE FUNCTION edutech.fn_cursos_touch_updated_at();

-- MODULOS
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_modulos_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.modulo_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_modulos_set_updated_at ON edutech.modulos;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_modulos_set_updated_at
BEFORE UPDATE ON edutech.modulos
FOR EACH ROW EXECUTE FUNCTION edutech.fn_modulos_touch_updated_at();


-- AULAS
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_aulas_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.aula_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_aulas_set_updated_at ON edutech.aulas;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_aulas_set_updated_at
BEFORE UPDATE ON edutech.aulas
FOR EACH ROW EXECUTE FUNCTION edutech.fn_aulas_touch_updated_at();


-- MATRICULAS
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_matriculas_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.matricula_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_matriculas_set_updated_at ON edutech.matriculas;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_matriculas_set_updated_at
BEFORE UPDATE ON edutech.matriculas
FOR EACH ROW EXECUTE FUNCTION edutech.fn_matriculas_touch_updated_at();


-- INSTRUTORES_ESPECILIDADES
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_instrutor_especialidades_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.ie_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_instrutor_especialidades_set_updated_at ON edutech.instrutor_especialidades;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_instrutor_especialidades_set_updated_at
BEFORE UPDATE ON edutech.instrutor_especialidades
FOR EACH ROW EXECUTE FUNCTION edutech.fn_instrutor_especialidades_touch_updated_at();


-- PROGRESSO_AULAS
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_progresso_aulas_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.progresso_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_progresso_aulas_set_updated_at ON edutech.progresso_aulas;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_progresso_aulas_set_updated_at
BEFORE UPDATE ON edutech.progresso_aulas
FOR EACH ROW EXECUTE FUNCTION edutech.fn_progresso_aulas_touch_updated_at();


-- AVALIACOES
-- cria ou recria a função
CREATE OR REPLACE FUNCTION edutech.fn_avaliacoes_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.avaliacao_data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

-- remove trigger antigo
DROP TRIGGER IF EXISTS trg_avaliacoes_set_updated_at ON edutech.avaliacoes;
-- cria ou recria o trigger que chama a função antes do UPDATE
CREATE TRIGGER trg_avaliacoes_set_updated_at
BEFORE UPDATE ON edutech.avaliacoes
FOR EACH ROW EXECUTE FUNCTION edutech.fn_avaliacoes_touch_updated_at();
