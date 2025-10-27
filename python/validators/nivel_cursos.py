from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
from .common import (
    Issue, check_required_columns, check_required_not_null,
    validate_types_generic, check_pk,
)

SPEC_NIVEL: Dict[str, Any] = {
    "required": [
        "nivel_curso_id",
        "nivel_curso_nome",
        "nivel_curso_descricao",
        "nivel_curso_data_criacao",
    ],
    "columns": {
        "nivel_curso_id": {"type": "int"},
        "nivel_curso_nome": {"type": "string", "min_len": 1},
        "nivel_curso_descricao": {"type": "string", "min_len": 1},
        "nivel_curso_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "nivel_curso_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["nivel_curso_id"],
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_NIVEL["required"],
        SPEC_NIVEL["columns"],
        SPEC_NIVEL["pk"]
    )

    # 1) Estrutura e tipos
    issues += check_required_columns(df, req)
    if not any(i.kind == "structure" for i in issues):
        issues += check_required_not_null(df, req)
        issues += validate_types_generic(df, cols_spec)

    # 2) “data_atualizacao ≥ data_criacao”     
    c = pd.to_datetime(df["nivel_curso_data_criacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    a = pd.to_datetime(df["nivel_curso_data_atualizacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    bad = c.notna() & a.notna() & (a < c)
    for i in df[bad].index:
        issues.append(Issue("quality", "Atualização não pode ser anterior à criação", int(i), "nivel_curso_data_atualizacao"))

    # 3) PK
    issues += check_pk(df, pk_cols)
    
    return issues
