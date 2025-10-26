from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
from .common import (
    Issue, check_required_columns, check_required_not_null,
    validate_types_generic, check_pk, check_fk_exists
)

SPEC_MODULOS: Dict[str, Any] = {
    "required": [
        "modulo_id",
        "modulo_curso_id",
        "modulo_titulo",
        "modulo_ordem",
        "modulo_data_criacao",
    ],
    "columns": {
        "modulo_id": {"type": "int"},
        "modulo_curso_id": {"type": "int"},
        "modulo_titulo": {"type": "string", "min_len": 1},
        "modulo_ordem": {"type": "int", "ge": 1},
        "modulo_descricao": {"type": "string"},
        "modulo_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "modulo_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["modulo_id"],
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_MODULOS["required"],
        SPEC_MODULOS["columns"],
        SPEC_MODULOS["pk"]
    )

    # 1) Estrutura
    issues += check_required_columns(df, req)
    if not any(i.kind == "structure" for i in issues):
        issues += check_required_not_null(df, req)

    # 2) Tipos/domínios
    if not any(i.kind == "structure" for i in issues):
        issues += validate_types_generic(df, cols_spec)

    # 3) PK
    issues += check_pk(df, pk_cols)

    # 4) FK -> cursos
    if not any(i.kind == "structure" for i in issues):
        issues += check_fk_exists(df, "modulo_curso_id", "cursos.csv", "curso_id", "cursos")

    return issues
