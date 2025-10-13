# EduTech
_SQL (70%) + Python (30%)_

_Projeto do curso Full Stack do Instituto Consuelo com a Casa Digital._

## Fluxo de branches & revisão
- **Branches**:  
  - `main` — estável e reservada para a entrega final.  
  - `development` — desenvolvimento contínuo (commits diretos).
- **Política atual**: 
    - desenvolver **diretamente em `development`**; 
    - abrir **uma PR `development` → `main`** ao final do desenvolvimento.
- **Revisão final**: 
    - a PR final será avaliada por 
       - [**Professor Júlio César**](https://github.com/julio-cesar96)
       - [**Monitor Douglas**](https://github.com/douglassilvaf)
- **Proteções**: 
    - branch protection e CODEOWNERS **serão habilitados somente ao final**, antes da PR final.

## Como rodar (mínimo)
1. Gere dados sintéticos:
    ```bash
    python3 python/gerador_dados.py
    python3 python/validador.py
    ```

2. Execute o schema e os dados no PostgreSQL:
    ```
    \i sql/schema.sql;
    \i sql/dados.sql;
    ```

3. Rode as consultas:
    ```
    \i sql/consultas.sql;
    ```

