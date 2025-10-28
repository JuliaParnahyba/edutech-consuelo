from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
import os
from .common import (
    Issue, check_required_columns, check_required_not_null,
    validate_types_generic, check_pk, check_fk_exists, _bool_as_str
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

    # 3) “data_atualizacao ≥ data_criacao”     
    c = pd.to_datetime(df["matricula_data_criacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    a = pd.to_datetime(df["matricula_data_atualizacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    bad = c.notna() & a.notna() & (a < c)
    for i in df[bad].index:
        issues.append(Issue("quality", "Atualização não pode ser anterior à criação", int(i), "matricula_data_atualizacao"))

    # 4) PK
    issues += check_pk(df, pk_cols)

    # 5) FKs
    if not any(i.kind == "structure" for i in issues):
        issues += check_fk_exists(df, "matricula_aluno_id", "alunos.csv", "aluno_id", "alunos")
        issues += check_fk_exists(df, "matricula_curso_id", "cursos.csv", "curso_id", "cursos")
        issues += check_fk_exists(df, "matricula_situacao_id", "situacoes_matricula.csv", "situacao_matricula_id", "situacoes_matricula")

    # 6) Regras de negócio (quality)
    # Q4) data_conclusao >= data_matricula (quando existir)
    dm = pd.to_datetime(df["matricula_data_matricula"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    dc = pd.to_datetime(df["matricula_data_conclusao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    bad_q4 = dc.notna() & dm.notna() & (dc < dm)
    for i in df[bad_q4].index:
        issues.append(Issue("quality", "Data de conclusão anterior à matrícula", int(i), "matricula_data_conclusao"))

    # Q5) diploma == true => data_conclusao presente
    dipl = _bool_as_str(df["matricula_diploma"])
    bad_q5 = (dipl == "true") & (dc.isna())
    for i in df[bad_q5].index:
        issues.append(Issue("quality", "Diploma exige data de conclusão", int(i), "matricula_data_conclusao"))

    # Q6)situacao == 'concluída' => data_conclusao presente
    try:
        from .common import get_data_root
        data_root = get_data_root()
    except Exception:
        data_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "data"))
    sit_path = os.path.join(data_root, "situacoes_matricula.csv")

    try:
        sits = pd.read_csv(sit_path)[["situacao_matricula_id", "situacao_matricula_tipo"]]
        sits["situacao_matricula_id"] = pd.to_numeric(sits["situacao_matricula_id"], errors="coerce").astype("Int64")
        tmp = df.copy()
        tmp["matricula_situacao_id"] = pd.to_numeric(tmp["matricula_situacao_id"], errors="coerce").astype("Int64")
        tmp = tmp.merge(sits, left_on="matricula_situacao_id", right_on="situacao_matricula_id", how="left")
        bad_q6 = (tmp["situacao_matricula_tipo"] == "concluída") & (dc.isna())
        for i in tmp[bad_q6].index:
            issues.append(Issue("quality", "Situação 'concluída' exige data de conclusão", int(i), "matricula_data_conclusao"))
    except Exception:
        # se não houver arquivo de situações, ignora essa regra
        pass


    return issues
