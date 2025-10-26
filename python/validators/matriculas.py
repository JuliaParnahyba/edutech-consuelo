from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
from .common import (
    Issue, check_required_columns, check_required_not_null,
    validate_types_generic, check_pk, check_fk_exists
)

SPEC_MATRICULAS: Dict[str, Any] = {
    "required": [
        "matricula_id",
        "matricula_aluno_id",
        "matricula_curso_id",
        "matricula_situacao_id",
        "matricula_num_matricula",
        "matricula_data_matricula",
        "matricula_valor_pago",
    ],
    "columns": {
        "matricula_id": {"type": "int"},
        "matricula_aluno_id": {"type": "int"},
        "matricula_curso_id": {"type": "int"},
        "matricula_situacao_id": {"type": "int"},
        "matricula_num_matricula": {"type": "string", "min_len": 1},
        "matricula_data_matricula": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "matricula_valor_pago": {"type": "decimal", "ge": 0},
        "matricula_data_conclusao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "matricula_diploma": {"type": "string", "enum": ["true", "false", "True", "False", True, False]},
        "matricula_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "matricula_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["matricula_id"],
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_MATRICULAS["required"],
        SPEC_MATRICULAS["columns"],
        SPEC_MATRICULAS["pk"],
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

    # 4) FKs
    if not any(i.kind == "structure" for i in issues):
        issues += check_fk_exists(df, "matricula_aluno_id", "alunos.csv", "aluno_id", "alunos")
        issues += check_fk_exists(df, "matricula_curso_id", "cursos.csv", "curso_id", "cursos")
        issues += check_fk_exists(df, "matricula_situacao_id", "situacoes_matricula.csv", "situacao_matricula_id", "situacoes_matricula")

    return issues
