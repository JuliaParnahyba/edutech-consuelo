-- EduTech | schema.sql
-- Objetivo: DDL do banco (tabelas, PK/FK, constraints, índices)

-- DICA: mantenha nomes em snake_case e crie sempre PKs explícitas.

-- FUTURO: CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- se optar por UUID

-- DROP/CREATE DATABASE (opcional para ambiente local)
-- CREATE DATABASE edutech;
-- \c edutech;

BEGIN;

-- TODO: criar tabelas (alunos, instrutores, categorias, cursos, modulos, aulas,
--       matriculas, progresso_aulas, avaliacoes) com PK/FK/UNIQUE/CHECK e índices.

COMMIT;
