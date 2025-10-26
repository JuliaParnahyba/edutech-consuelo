from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
from .common import (
    Issue, check_required_columns, check_required_not_null,
    validate_types_generic, check_pk,
)

SPEC_INSTRUTORES: Dict[str, Any] = {
    "required": [
        "instrutor_id",
        "instrutor_primeiro_nome",
        "instrutor_ultimo_nome",
        "instrutor_email",
        "instrutor_especial_principal_id",     # FK para especialidades
        "instrutor_data_criacao",
    ],
    "columns": {
        "instrutor_id": {"type": "int"},
        "instrutor_primeiro_nome": {"type": "string", "min_len": 1},
        "instrutor_ultimo_nome": {"type": "string", "min_len": 1},
        "instrutor_email": {"type": "email"},
        "instrutor_especial_principal_id": {"type": "int"},
        "instrutor_biografia": {"type": "string"},
        "instrutor_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "instrutor_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["instrutor_id"],
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_INSTRUTORES["required"],
        SPEC_INSTRUTORES["columns"],
        SPEC_INSTRUTORES["pk"]
    )
    
    # 1) estrutura e tipos
    issues += check_required_columns(df, req)
    if not any(i.kind == "structure" for i in issues):
        issues += check_required_not_null(df, req)
        issues += validate_types_generic(df, cols_spec)

    # 2) PK
    issues += check_pk(df, pk_cols)
    
    return issues
