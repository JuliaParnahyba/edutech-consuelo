# 🧩 EduTech — Consultas SQL  

> Documento de apoio ao arquivo [`sql/queries/queries.sql`](../sql/queries/queries.sql)  
> Objetivo: explicar o propósito e a lógica de cada bloco de consultas implementadas.

---

## 🎯 Objetivo Geral  

O arquivo `queries.sql` consolida **consultas exploratórias e analíticas** sobre o banco de dados **EduTech**, cobrindo as principais entidades e relações do sistema.  
Essas consultas foram projetadas para **explorar, validar e compreender** os dados gerados a partir das tabelas de cursos, alunos, instrutores, categorias, matrículas e suas dependências.

---

## 🧱 Estrutura de Blocos  

| Bloco | Tema | Objetivo |
| :---- | :---- | :---- |
| **1** | Listagens simples | Explorar dados básicos de cada entidade principal. |
| **2** | Relacionamentos | Visualizar conexões entre entidades, como curso ↔ categoria ↔ instrutor. |
| **3** | Contagens e agregações | Realizar análises quantitativas, com `COUNT`, `GROUP BY` e `HAVING`. |
| **4** | Filtros temporais | Explorar dados recentes (últimos dias) e status de atividade. |
| **5** | Diagnósticos | Verificar integridade e detectar dados órfãos ou incompletos. |
| **6** | Visões resumidas | Gerar resumos consolidados de cursos e alunos. |

---

## 🔍 Detalhamento por Bloco  

### **1️⃣ Listagens simples**
Consultas básicas de referência para visualizar o conteúdo das principais tabelas.  
Inclui filtros, ordenações e uso de aliases consistentes.

- **Cursos com categoria, nível e instrutor:** demonstra `INNER JOIN` em cascata.  
- **Alunos ativos:** filtro booleano `COALESCE(aluno_ativo, TRUE)` e ordenação por data.  
- **Matrículas com situação:** `JOIN` direto com tabela de situações.

---

### **2️⃣ Relacionamentos entre entidades**
Mostra o uso de `JOIN` para conectar múltiplas tabelas e entender a estrutura do sistema.

- **Cursos por categoria** — organiza por tema e filtra opcionalmente (`:categoria_id`).  
- **Cursos por instrutor** — mantém cursos sem instrutor via `LEFT JOIN`.  
- **Módulos e aulas por curso** — exibe hierarquia curso → módulo → aula.  
- **Alunos matriculados por curso** — cruza alunos, cursos e situações de matrícula.

---

### **3️⃣ Contagens e agregações**
Aplica `COUNT`, `GROUP BY`, `HAVING` e `ORDER BY` para análises quantitativas.

- **Matrículas por curso** — total geral.  
- **Matrículas ativas por curso** — filtro por situação “ativa”.  
- **Matrículas por categoria** — agrega por tema de curso.  
- **Cursos com ao menos N aulas** — utiliza `HAVING` e `CTE` (`WITH`).

---

### **4️⃣ Diagnósticos e qualidade dos dados**
Consultas voltadas à verificação de **integridade referencial** e **coerência lógica**.

- **Cursos sem instrutor associado** — identifica lacunas de cadastro.  
- **Aulas órfãs** — checa inconsistência em `aulas` ↔ `modulos`.  
- **Percentual de matrículas por situação** — utiliza janela `SUM() OVER ()`.  

---

### **5️⃣ Visões resumidas por entidade**
Fornece visões de alto nível para relatórios rápidos.

- **Resumo de cursos** — total de módulos e aulas.  
- **Resumo de alunos** — total de matrículas e última data registrada.

---

## ⚙️ Execução  

Essas consultas podem ser executadas diretamente no PostgreSQL via linha de comando, Makefile ou Adminer.

```bash
# Executar via Makefile
make db.query
```


