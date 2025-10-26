from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
from .common import (
    Issue,
    check_required_columns,
    check_required_not_null,
    validate_types_generic,
    check_pk
)

# SPEC específico da tabela alunos
SPEC_ALUNOS: Dict[str, Any] = {
    "required": [
        "aluno_id",
        "aluno_primeiro_nome",
        "aluno_ultimo_nome",
        "aluno_email",
        "aluno_data_nascimento",
        "aluno_data_criacao",
    ],
    "columns": {
        "aluno_id": {"type": "int"},
        "aluno_primeiro_nome": {"type": "string", "min_len": 1},
        "aluno_ultimo_nome": {"type": "string", "min_len": 1},
        "aluno_email": {"type": "email"},
        "aluno_data_nascimento": {"type": "date", "fmt": "%Y-%m-%d"},
        "aluno_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "aluno_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["aluno_id"],
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
