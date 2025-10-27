from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
from .common import (
    Issue,
    check_required_columns,
    check_required_not_null,
    validate_types_generic,
    check_pk,
    check_fk_exists
)

SPEC_IE: Dict[str, Any] = {
    "required": [
        "ie_instrutor_id",
        "ie_especialidade_id",
        "ie_data_criacao",
    ],
    "columns": {
        "ie_instrutor_id": {"type": "int"},
        "ie_especialidade_id": {"type": "int"},
        "ie_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "ie_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["ie_instrutor_id", "ie_especialidade_id"],
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_IE["required"],
        SPEC_IE["columns"],
        SPEC_IE["pk"],
    )

    # 1) Estrutura, tipos, PK e FKs
    issues += check_required_columns(df, req)
    if not any(i.kind == "structure" for i in issues):
        issues += check_required_not_null(df, req)
        issues += validate_types_generic(df, cols_spec)
        issues += check_pk(df, pk_cols)
        issues += check_fk_exists(df, "ie_instrutor_id", "instrutores.csv", "instrutor_id", "instrutores")
        issues += check_fk_exists(df, "ie_especialidade_id", "especialidades.csv", "especialidade_id", "especialidades")

    # 2) “data_atualizacao ≥ data_criacao”
    c = pd.to_datetime(df["ie_data_criacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    a = pd.to_datetime(df["ie_data_atualizacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    bad = c.notna() & a.notna() & (a < c)
    for i in df[bad].index:
        issues.append(Issue("quality", "Atualização não pode ser anterior à criação", int(i), "ie_data_atualizacao"))

    return issues
