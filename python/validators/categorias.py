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

# Alinhado ao schema.sql (datas no formato "%Y-%m-%d %H:%M:%S")
SPEC_CATEGORIAS: Dict[str, Any] = {
    "required": [
        "categoria_id",
        "categoria_nome",
        "categoria_data_criacao"
    ],
    "columns": {
        "categoria_id": {"type": "int"},
        "categoria_nome": {"type": "string", "min_len": 1},
        "categoria_descricao": {"type": "string"},
        "categoria_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "categoria_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["categoria_id"],
}


def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_AULAS["required"],
        SPEC_AULAS["columns"],
        SPEC_AULAS["pk"]
    )

    # 1) estrutura
    issues += check_required_columns(df, req)
    if not any(i.kind == "structure" for i in issues):
        issues += check_required_not_null(df, req)

    # 2) tipos/domínios
    if not any(i.kind == "structure" for i in issues):
        issues += validate_types_generic(df, cols_spec)

    # 3) PK
    issues += check_pk(df, pk_cols)

    return issues
