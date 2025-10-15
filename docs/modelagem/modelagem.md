# Modelagem Lógica — EduTech

> Versão: rascunho inicial  
> Objetivo: descrever entidades, atributos, chaves e relacionamentos até 3FN.

<br>

## 1) Entidades (mínimo exigido no EduTech.md)
- **alunos**: id (PK), nome, email [UNIQUE], data_nascimento, data_cadastro
- **instrutores**: id (PK), nome, email [UNIQUE], especialidade, biografia
- **categorias**: id (PK), nome, descricao
- **cursos**: id (PK), titulo, descricao, categoria_id (FK), instrutor_id (FK), preco, carga_horaria, nivel, data_criacao
- **modulos**: id (PK), curso_id (FK), titulo, ordem, descricao
- **aulas**: id (PK), modulo_id (FK), titulo, ordem, duracao_minutos, tipo
- **matriculas**: id (PK), aluno_id (FK), curso_id (FK), data_matricula, data_conclusao, status, valor_pago
- **progresso_aulas**: id (PK), matricula_id (FK), aula_id (FK), concluida, data_conclusao, tempo_assistido_minutos
- **avaliacoes**: id (PK), matricula_id (FK), curso_id (FK), nota, comentario, data_avaliacao

<br>

## 2) Relacionamentos e cardinalidades
- categorias 1 → N cursos  
- instrutores 1 → N cursos  
- cursos 1 → N modulos  
- modulos 1 → N aulas  
- alunos N → N cursos (via **matriculas**)  
- matriculas 1 → N progresso_aulas (um registro por aula daquela matrícula)  
- cursos 1 → N avaliacoes, **mas** amarradas a uma matrícula (FK dupla: matricula_id, curso_id)

<br>

## 3) Regras e constraints-chave
- Emails únicos em **alunos** e **instrutores**.
- Domínios:
  - **cursos.nivel** ∈ {livre, tecnico, graduacao, especializacao} (tipos de níveis alterado para ter mais sentido)
  - **aulas.tipo** ∈ {EAD, hibrido, presencial} (tipos de aulas alterado para ter mais sentido)
  - **matriculas.status** ∈ {ativa, concluida, cancelada}
  - **avaliacoes.nota** ∈ [0..10]
- Checks numéricos:
  - **cursos.preco** ≥ 0
  - **modulos.ordem** ≥ 1; **aulas.ordem** ≥ 1
  - **aulas.duracao_minutos** > 0
  - **progresso_aulas.tempo_assistido_minutos** ≥ 0
- Integridade:
  - **cursos.(categoria_id, instrutor_id)** → FK válidas
  - **modulos.curso_id** → cursos.id
  - **aulas.modulo_id** → modulos.id
  - **matriculas.(aluno_id, curso_id)** → (alunos.id, cursos.id)
  - **progresso_aulas.(matricula_id, aula_id)** → (matriculas.id, aulas.id)
  - **avaliacoes.matricula_id** → matriculas.id e **avaliacoes.curso_id** → cursos.id
- Unicidades úteis:
  - **modulos**: (curso_id, ordem) UNIQUE
  - **aulas**: (modulo_id, ordem) UNIQUE
  - **progresso_aulas**: (matricula_id, aula_id) UNIQUE
  - Índices recomendados (a ser implementado):
    - FK clássicas (curso_id, modulo_id, aluno_id, instrutor_id, categoria_id)
    - **matriculas(status)** → relatórios por status
    - **avaliacoes(curso_id, nota)** → média/contagens por curso 
    - **progresso_aulas(matricula_id, aula_id)**

<br>

## 4) Normalização (até 3FN)
- **1FN**: todos os campos atômicos, sem listas/arrays; ordens e tipos em colunas próprias.
- **2FN**: não são usadas PK composta como primária; quando houver natural key composta (ex.: progresso por aula), manter surrogate `id`, mas **impor UNIQUE** no par (matricula_id, aula_id) para impedir dependência parcial.
- **3FN**: atributos não-chave dependem apenas da chave da tabela:
  - Preço do curso fica em **cursos** (não duplica em **matriculas** além de **valor_pago**, que é o *valor transacional* da época, justificado para histórico).
  - Métricas agregadas (ex.: média de notas) ficarão em *queries/views*, não em colunas.

<br>

## 5) Esboço para ER (rótulos de cardinalidade)
- categorias (1) —— (N) cursos —— (1) modulos —— (N) aulas  
- instrutores (1) —— (N) cursos  
- alunos (N) —— (N) cursos **via** matriculas  
- matriculas (1) —— (N) progresso_aulas —— (N) aulas *(pelo vínculo via FK)*  
- cursos (1) —— (N) avaliacoes **e** avaliacoes —— (N) matriculas *(FK dupla garantindo vínculo correto)*

<br>

## 6) Decisões de projeto
- Manter `valor_pago` em **matriculas** para preservar histórico (ex.: promoções) sem conflitar com 3FN, pois é um fato da transação.
- Manter surrogate keys (id) para simplicidade e interoperabilidade futura (Python, APIs).
- Impor UNIQUE compostas onde há “chaves naturais” úteis à integridade (ordens, progresso).
