from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
from .common import (
    Issue, check_required_columns, check_required_not_null,
    validate_types_generic, check_pk, check_fk_exists
)

SPEC_AULAS: Dict[str, Any] = {
    "required": [
        "aula_id",
        "aula_modulo_id",
        "aula_titulo",
        "aula_ordem",
        "aula_duracao_min",
        "aula_tipo",
        "aula_data_criacao",
    ],
    "columns": {
        "aula_id": {"type": "int"},
        "aula_modulo_id": {"type": "int"},
        "aula_titulo": {"type": "string", "min_len": 1},
        "aula_ordem": {"type": "int", "ge": 1},
        "aula_duracao_min": {"type": "int", "ge": 1},
        "aula_tipo": {"type": "string", "enum": ["EAD", "hibrido", "presencial"]},
        "aula_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "aula_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["aula_id"],
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_AULAS["required"],
        SPEC_AULAS["columns"],
        SPEC_AULAS["pk"]
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

    # 4) FK -> modulos
    if not any(i.kind == "structure" for i in issues):
        issues += check_fk_exists(df, "aula_modulo_id", "modulos.csv", "modulo_id", "modulos")

    return issues
