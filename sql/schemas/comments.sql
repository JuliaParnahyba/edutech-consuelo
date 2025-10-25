-- ======================================
-- EduTech | comments.sql
-- Objetivo: Documentação de tabelas e colunas críticas (COMMENT ON)
-- Observação: colunas *_data_atualizacao são mantidas via trigger BEFORE UPDATE.
-- ======================================

-- 5. Comentários
-- TABELA: alunos
COMMENT ON TABLE edutech.alunos IS 'Cadastro de estudantes da plataforma EduTech.';
COMMENT ON COLUMN edutech.alunos.aluno_id IS 'Identificador único do aluno.';
COMMENT ON COLUMN edutech.alunos.aluno_email IS 'E-mail único do aluno (login/contato).';
COMMENT ON COLUMN edutech.alunos.aluno_data_nascimento IS 'Data de nascimento do aluno.';
COMMENT ON COLUMN edutech.alunos.aluno_data_criacao IS 'Timestamp de criação do registro.';
COMMENT ON COLUMN edutech.alunos.aluno_data_atualizacao IS 'Timestamp da última atualização (trigger BEFORE UPDATE).';


-- TABELA: especialidades
COMMENT ON TABLE edutech.especialidades IS 'Domínios de conhecimento (ex.: SQL, Python, UX).';
COMMENT ON COLUMN edutech.especialidades.especialidade_id IS 'Identificador único da especialidade.';
COMMENT ON COLUMN edutech.especialidades.especialidade_nome IS 'Nome único da especialidade.';
COMMENT ON COLUMN edutech.especialidades.especialidade_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.especialidades.especialidade_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: categorias
COMMENT ON TABLE edutech.categorias IS 'Categorias de cursos (ex.: Banco de Dados, Programação).';
COMMENT ON COLUMN edutech.categorias.categoria_id IS 'Identificador único da categoria.';
COMMENT ON COLUMN edutech.categorias.categoria_nome IS 'Nome único da categoria.';
COMMENT ON COLUMN edutech.categorias.categoria_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.categorias.categoria_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: nivel_cursos
COMMENT ON TABLE edutech.nivel_cursos IS 'Níveis de dificuldade dos cursos (ex.: Iniciante, Intermediário, Avançado).';
COMMENT ON COLUMN edutech.nivel_cursos.nivel_curso_id IS 'Identificador único do nível.';
COMMENT ON COLUMN edutech.nivel_cursos.nivel_curso_nome IS 'Nome único do nível.';
COMMENT ON COLUMN edutech.nivel_cursos.nivel_curso_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.nivel_cursos.nivel_curso_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: situacoes_matricula
COMMENT ON TABLE edutech.situacoes_matricula IS 'Domínio de status das matrículas (ex.: ativa, trancada, concluída).';
COMMENT ON COLUMN edutech.situacoes_matricula.situacao_matricula_id IS 'Identificador único do status.';
COMMENT ON COLUMN edutech.situacoes_matricula.situacao_matricula_tipo IS 'Tipo de status (único).';
COMMENT ON COLUMN edutech.situacoes_matricula.situacao_matricula_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.situacoes_matricula.situacao_matricula_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: instrutores
COMMENT ON TABLE edutech.instrutores IS 'Instrutores responsáveis pelos cursos.';
COMMENT ON COLUMN edutech.instrutores.instrutor_id IS 'Identificador único do instrutor.';
COMMENT ON COLUMN edutech.instrutores.instrutor_email IS 'E-mail único do instrutor.';
COMMENT ON COLUMN edutech.instrutores.instrutor_especial_principal_id IS 'FK para especialidades.especialidade_id (especialidade principal do instrutor).';
COMMENT ON COLUMN edutech.instrutores.instrutor_biografia IS 'Breve biografia/apresentação do instrutor.';
COMMENT ON COLUMN edutech.instrutores.instrutor_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.instrutores.instrutor_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: cursos
COMMENT ON TABLE edutech.cursos IS 'Catálogo de cursos oferecidos na plataforma.';
COMMENT ON COLUMN edutech.cursos.curso_id IS 'Identificador único do curso.';
COMMENT ON COLUMN edutech.cursos.curso_titulo IS 'Título único do curso (vitrine).';
COMMENT ON COLUMN edutech.cursos.curso_categoria_id IS 'FK para categorias.categoria_id (classificação temática).';
COMMENT ON COLUMN edutech.cursos.curso_instrutor_id IS 'FK para instrutores.instrutor_id (responsável pelo curso).';
COMMENT ON COLUMN edutech.cursos.curso_nivel_id IS 'FK para nivel_cursos.nivel_curso_id (nível de dificuldade). ON DELETE RESTRICT.';
COMMENT ON COLUMN edutech.cursos.curso_carga_horaria IS 'Carga horária total (horas), mínima 1.';
COMMENT ON COLUMN edutech.cursos.curso_preco IS 'Preço do curso (R$), não negativo.';
COMMENT ON COLUMN edutech.cursos.curso_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.cursos.curso_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: modulos
COMMENT ON TABLE edutech.modulos IS 'Estrutura do curso em módulos (unidades).';
COMMENT ON COLUMN edutech.modulos.modulo_id IS 'Identificador único do módulo.';
COMMENT ON COLUMN edutech.modulos.modulo_curso_id IS 'FK para cursos.curso_id (curso ao qual o módulo pertence).';
COMMENT ON COLUMN edutech.modulos.modulo_titulo IS 'Título do módulo.';
COMMENT ON COLUMN edutech.modulos.modulo_ordem IS 'Ordem do módulo no curso (>=1, única por curso).';
COMMENT ON COLUMN edutech.modulos.modulo_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.modulos.modulo_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: aulas
COMMENT ON TABLE edutech.aulas IS 'Aulas pertencentes a um módulo.';
COMMENT ON COLUMN edutech.aulas.aula_id IS 'Identificador único da aula.';
COMMENT ON COLUMN edutech.aulas.aula_modulo_id IS 'FK para modulos.modulo_id (módulo pai).';
COMMENT ON COLUMN edutech.aulas.aula_titulo IS 'Título da aula.';
COMMENT ON COLUMN edutech.aulas.aula_ordem IS 'Ordem da aula no módulo (>=1, única por módulo).';
COMMENT ON COLUMN edutech.aulas.aula_duracao_min IS 'Duração prevista em minutos (>=1).';
COMMENT ON COLUMN edutech.aulas.aula_tipo IS 'Formato da aula: EAD | hibrido | presencial.';
COMMENT ON COLUMN edutech.aulas.aula_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.aulas.aula_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: matriculas
COMMENT ON TABLE edutech.matriculas IS 'Relação de matrícula do aluno em um curso (histórico acadêmico e financeiro).';
COMMENT ON COLUMN edutech.matriculas.matricula_id IS 'Identificador único da matrícula.';
COMMENT ON COLUMN edutech.matriculas.matricula_aluno_id IS 'FK para alunos.aluno_id (quem se matriculou).';
COMMENT ON COLUMN edutech.matriculas.matricula_curso_id IS 'FK para cursos.curso_id (curso escolhido).';
COMMENT ON COLUMN edutech.matriculas.matricula_situacao_id IS 'FK para situacoes_matricula.situacao_matricula_id (status atual).';
COMMENT ON COLUMN edutech.matriculas.matricula_num_matricula IS 'Identificador externo (AASSMM#####). Reservado para geração automática futura.';
COMMENT ON COLUMN edutech.matriculas.matricula_data_matricula IS 'Data/hora de criação da matrícula (carimbo de negócio).';
COMMENT ON COLUMN edutech.matriculas.matricula_valor_pago IS 'Valor pago pelo aluno (R$). Pode ser 0 em casos de bolsa/isenção.';
COMMENT ON COLUMN edutech.matriculas.matricula_data_conclusao IS 'Data de conclusão do curso (quando aplicável).';
COMMENT ON COLUMN edutech.matriculas.matricula_diploma IS 'Indica se o aluno obteve diploma (regras de % de progresso).';
COMMENT ON COLUMN edutech.matriculas.matricula_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.matriculas.matricula_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: instrutor_especialidades (N:N)
COMMENT ON TABLE edutech.instrutor_especialidades IS 'Tabela de vínculo N:N entre instrutores e especialidades.';
COMMENT ON COLUMN edutech.instrutor_especialidades.ie_instrutor_id IS 'FK para instrutores.instrutor_id. ON DELETE CASCADE (remove vínculos do instrutor).';
COMMENT ON COLUMN edutech.instrutor_especialidades.ie_especialidade_id IS 'FK para especialidades.especialidade_id. ON DELETE RESTRICT.';
COMMENT ON COLUMN edutech.instrutor_especialidades.ie_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.instrutor_especialidades.ie_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: progresso_aulas
COMMENT ON TABLE edutech.progresso_aulas IS 'Progresso do aluno por aula (percentual, conclusão e tempo assistido).';
COMMENT ON COLUMN edutech.progresso_aulas.progresso_id IS 'Identificador único do progresso.';
COMMENT ON COLUMN edutech.progresso_aulas.progresso_matricula_id IS 'FK para matriculas.matricula_id (matrícula do aluno).';
COMMENT ON COLUMN edutech.progresso_aulas.progresso_aula_id IS 'FK para aulas.aula_id (aula acompanhada).';
COMMENT ON COLUMN edutech.progresso_aulas.progresso_percentual IS 'Percentual de conclusão da aula (0–100).';
COMMENT ON COLUMN edutech.progresso_aulas.progresso_concluida IS 'Indicador de conclusão da aula.';
COMMENT ON COLUMN edutech.progresso_aulas.progresso_data_conclusao IS 'Carimbo de conclusão (quando concluída).';
COMMENT ON COLUMN edutech.progresso_aulas.progresso_tempo_assistido_min IS 'Tempo assistido (minutos).';
COMMENT ON COLUMN edutech.progresso_aulas.progresso_data_criacao IS 'Criado em.';
COMMENT ON COLUMN edutech.progresso_aulas.progresso_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';


-- TABELA: avaliacoes
COMMENT ON TABLE edutech.avaliacoes IS 'Avaliações (nota e comentário) dadas por um aluno a uma aula.';
COMMENT ON COLUMN edutech.avaliacoes.avaliacao_id IS 'Identificador único da avaliação.';
COMMENT ON COLUMN edutech.avaliacoes.avaliacao_aluno_id IS 'FK para alunos.aluno_id (quem avaliou).';
COMMENT ON COLUMN edutech.avaliacoes.avaliacao_aula_id IS 'FK para aulas.aula_id (aula avaliada).';
COMMENT ON COLUMN edutech.avaliacoes.avaliacao_nota IS 'Nota de 0 a 5.';
COMMENT ON COLUMN edutech.avaliacoes.avaliacao_comentario IS 'Comentário opcional (até 150 chars).';
COMMENT ON COLUMN edutech.avaliacoes.avaliacao_data_criacao IS 'Data/hora em que a avaliação foi registrada.';
COMMENT ON COLUMN edutech.avaliacoes.avaliacao_data_atualizacao IS 'Atualizado em (trigger BEFORE UPDATE).';
-- 
