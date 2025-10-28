from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
from .common import (
    Issue,
    check_required_columns,
    check_required_not_null,
    validate_types_generic,
    check_pk,
)

SPEC_ESPECIALIDADES: Dict[str, Any] = {
    "required": [
        "especialidade_id",
        "especialidade_nome",
        "especialidade_descricao",
        "especialidade_data_criacao",
    ],
    "columns": {
        "especialidade_id": {"type": "int"},
        "especialidade_nome": {"type": "string", "min_len": 1},
        "especialidade_descricao": {"type": "string", "min_len": 1},
        "especialidade_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "especialidade_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["especialidade_id"],
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_ESPECIALIDADES["required"],
        SPEC_ESPECIALIDADES["columns"],
        SPEC_ESPECIALIDADES["pk"],
    )

    # 1) Estrutura, tipos e PK
    issues += check_required_columns(df, req)
    if not any(i.kind == "structure" for i in issues):
        issues += check_required_not_null(df, req)
        issues += validate_types_generic(df, cols_spec)
        issues += check_pk(df, pk_cols)

    # 2) “data_atualizacao ≥ data_criacao”
    c = pd.to_datetime(df["especialidade_data_criacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    a = pd.to_datetime(df["especialidade_data_atualizacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    bad = c.notna() & a.notna() & (a < c)
    for i in df[bad].index:
        issues.append(Issue("quality", "Atualização não pode ser anterior à criação", int(i), "especialidade_data_atualizacao"))

    return issues
