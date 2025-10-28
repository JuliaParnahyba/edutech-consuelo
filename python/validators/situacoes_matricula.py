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

SPEC_SITUACOES: Dict[str, Any] = {
    "required": [
        "situacao_matricula_id",
        "situacao_matricula_tipo",
        "situacao_matricula_descricao",
        "situacao_matricula_data_criacao",
    ],
    "columns": {
        "situacao_matricula_id": {"type": "int"},
        "situacao_matricula_tipo": {"type": "string", "enum": ["ativa", "concluída", "cancelada", "pendente"]},
        "situacao_matricula_descricao": {"type": "string", "min_len": 3},
        "situacao_matricula_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "situacao_matricula_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["situacao_matricula_id"],
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_SITUACOES["required"],
        SPEC_SITUACOES["columns"],
        SPEC_SITUACOES["pk"],
    )

    # 1) Estrutura, tipos e PK
    issues += check_required_columns(df, req)
    if not any(i.kind == "structure" for i in issues):
        issues += check_required_not_null(df, req)
        issues += validate_types_generic(df, cols_spec)
        issues += check_pk(df, pk_cols)

    # 2) “data_atualizacao ≥ data_criacao”
    c = pd.to_datetime(df["situacao_matricula_data_criacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    a = pd.to_datetime(df["situacao_matricula_data_atualizacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    bad = c.notna() & a.notna() & (a < c)
    for i in df[bad].index:
        issues.append(Issue("quality", "Atualização não pode ser anterior à criação", int(i), "situacao_matricula_data_atualizacao"))
    
    return issues
