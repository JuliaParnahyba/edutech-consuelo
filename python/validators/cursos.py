from __future__ import annotations
from typing import Dict, Any, List, Set
import os
import pandas as pd
from .common import (
    Issue,
    check_required_columns,
    check_required_not_null,
    validate_types_generic,
    check_pk,
    check_fk_exists,
)

# cursos depende de categorias (FK: curso_categoria_id -> categorias.categoria_id)
SPEC_CURSOS: Dict[str, Any] = {
    "required": [
        "curso_id",
        "curso_titulo",
        "curso_categoria_id",
        "curso_instrutor_id",
        "curso_nivel_id",
        "curso_carga_horaria",
        "curso_preco",
        "curso_data_criacao",
    ],
    "columns": {
        "curso_id": {"type": "int"},
        "curso_titulo": {"type": "string", "min_len": 1},
        "curso_descricao": {"type": "string"},
        "curso_categoria_id": {"type": "int"},
        "curso_instrutor_id": {"type": "int"},
        "curso_nivel_id": {"type": "int"},
        "curso_carga_horaria": {"type": "int", "ge": 1},
        "curso_preco": {"type": "decimal", "ge": 0},
        "curso_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "curso_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["curso_id"],
    # FKs serão checadas no validate()
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_CURSOS["required"],
        SPEC_CURSOS["columns"],
        SPEC_CURSOS["pk"]
    )

    # 1) estrutura
    issues += check_required_columns(df, req)
    if not any(i.kind == "structure" for i in issues):
        issues += check_required_not_null(df, req)

    # 2) tipos/domínios
    if not any(i.kind == "structure" for i in issues):
        issues += validate_types_generic(df, cols_spec)

    # 3) “data_atualizacao ≥ data_criacao”     
    c = pd.to_datetime(df["curso_data_criacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    a = pd.to_datetime(df["curso_data_atualizacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    bad = c.notna() & a.notna() & (a < c)
    for i in df[bad].index:
        issues.append(Issue("quality", "Atualização não pode ser anterior à criação", int(i), "curso_data_atualizacao"))

    # 4) PK
    issues += check_pk(df, pk_cols)

    # 5) FKs (só roda se não faltou estrutura)
    if not any(i.kind == "structure" for i in issues):
        issues += check_fk_exists(df, "curso_categoria_id", "categorias.csv",  "categoria_id",  "categorias")
        issues += check_fk_exists(df, "curso_instrutor_id", "instrutores.csv", "instrutor_id",  "instrutores")
        issues += check_fk_exists(df, "curso_nivel_id",    "nivel_cursos.csv", "nivel_curso_id","nivel_cursos")

    return issues
