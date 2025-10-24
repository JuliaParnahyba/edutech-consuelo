-- EduTech | env.sql
-- Objetivo: "escrever algo"

-- 1. Criação do schema que irá englobar as tables do projeto, de maneira que seja criado apenas se ele não existir.
CREATE SCHEMA IF NOT EXISTS edutech;
-- Define a ordem onde o Postgres procura/cria objetos: primeiro em edutech, depois no schema padrão public.
SET search_path TO edutech, public;

