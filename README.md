# 🧩 EduTech  
_SQL (70%) + Python (30%)_  

Projeto desenvolvido no curso **Full Stack** do **Instituto Consuelo**, em parceria com a **Casa Digital**.  
O sistema simula uma plataforma de **gerenciamento de cursos online**, aplicando conceitos práticos de **modelagem SQL, manipulação de dados e automação com Python**.

<br>

## ⚙️ Fluxo de branches e revisão  

- **Branches principais:**  
  - `main` — branch estável, utilizada apenas para a versão final do projeto.  
  - `development` — branch de desenvolvimento contínuo (recebe commits diretos).  

- **Política atual:**  
  - O desenvolvimento é feito diretamente na branch `development`;  
  - Ao final do projeto, será aberta uma **Pull Request (`development` → `main`)** para a entrega oficial.  

- **Revisão final:**  
  - A PR final será avaliada por:  
    - [**Professor Júlio César**](https://github.com/julio-cesar96)  
    - [**Monitor Douglas**](https://github.com/douglassilvaf)  

- **Proteções:**  
  - As regras de branch protection e o arquivo `CODEOWNERS` serão habilitados **apenas antes da PR final**, garantindo que o merge final seja revisado e aprovado.  

<br>

## ▶️ Como executar o projeto  

### 1️⃣ Gerar dados sintéticos  
Execute os scripts Python de geração e validação de dados:  
```bash
python3 python/gerador_dados.py
python3 python/validador.py
```

### 2️⃣ Criar e popular o banco de dados (PostgreSQL)
No terminal interativo do PostgreSQL, rode os scripts SQL:
```bash
\i sql/schema.sql;
\i sql/dados.sql;
```

### 3️⃣ Executar consultas e relatórios
```bash
\i sql/consultas.sql;
\i sql/relatorios_analiticos.sql;
```

<br>

## 📁 Estrutura de diretórios

```bash
/docs/      → documentação e diagramas  
/sql/       → schema.sql, dados.sql, consultas e relatórios  
/python/    → scripts auxiliares (gerador, validador, utils)  
/data/      → arquivos CSV gerados e processados  
```

```bash
EDUTECH-CONSUELO/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
├── data/
│   └── ...
├── docs/
│   ├── standards/
│   ├── Resumo_EduTech.md
├── python/
│   ├── gerador_dados.py
│   ├── utils.py
│   ├── validador.py
├── sql/
│   ├── schema.sql
│   ├── dados.sql
│   ├── consultas.sql
│   ├── relatorios_analiticos.sql
├── LICENSE
└── README.md
```


<br>

## 📎 Referências

🔗 [Ver resumo completo do projeto](./docs/Resumo_EduTech.md)

📊 [GitHub Project – EduTech_Consuelo](https://github.com/users/JuliaParnahyba/projects/14)

<br>

📌 **Última atualização:** 13 de outubro de 2025  
📎 **Responsável:** [@JuliaParnahyba](https://github.com/JuliaParnahyba)