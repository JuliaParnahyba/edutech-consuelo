from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
from .common import (
    Issue, check_required_columns, check_required_not_null,
    validate_types_generic, check_pk, check_fk_exists
)

SPEC_AVALIACOES: Dict[str, Any] = {
    "required": [
        "avaliacao_id",
        "avaliacao_aluno_id",
        "avaliacao_aula_id",
        "avaliacao_nota",
        "avaliacao_data_criacao",
    ],
    "columns": {
        "avaliacao_id": {"type": "int"},
        "avaliacao_aluno_id": {"type": "int"},
        "avaliacao_aula_id": {"type": "int"},
        "avaliacao_nota": {"type": "int", "ge": 0, "le": 5},
        "avaliacao_comentario": {"type": "string"},
        "avaliacao_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "avaliacao_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["avaliacao_id"],
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_AVALIACOES["required"],
        SPEC_AVALIACOES["columns"],
        SPEC_AVALIACOES["pk"],
    )

    # 1) Estrutura
    issues += check_required_columns(df, req)
    if not any(i.kind == "structure" for i in issues):
        issues += check_required_not_null(df, req)

    # 2) Tipos/domínios
    if not any(i.kind == "structure" for i in issues):
        issues += validate_types_generic(df, cols_spec)
    
    # 3) “data_atualizacao ≥ data_criacao”     
    c = pd.to_datetime(df["avaliacao_data_criacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    a = pd.to_datetime(df["avaliacao_data_atualizacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    bad = c.notna() & a.notna() & (a < c)
    for i in df[bad].index:
        issues.append(Issue("quality", "Atualização não pode ser anterior à criação", int(i), "avaliacao_data_atualizacao"))

    # 4) PK
    issues += check_pk(df, pk_cols)

    # 5) FKs
    if not any(i.kind == "structure" for i in issues):
        issues += check_fk_exists(df, "avaliacao_aluno_id", "alunos.csv", "aluno_id", "alunos")
        issues += check_fk_exists(df, "avaliacao_aula_id", "aulas.csv", "aula_id", "aulas")

    return issues
