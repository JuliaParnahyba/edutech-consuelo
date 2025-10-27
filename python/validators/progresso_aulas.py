from __future__ import annotations
from typing import Dict, Any, List
import pandas as pd
import os
from .common import (
    Issue, 
    check_required_columns, 
    check_required_not_null,
    validate_types_generic, 
    check_pk, 
    check_fk_exists,
    _bool_as_str,
)

SPEC_PROG: Dict[str, Any] = {
    "required": [
        "progresso_id",
        "progresso_matricula_id",
        "progresso_aula_id",
        "progresso_percentual",
        "progresso_concluida",
        "progresso_tempo_assistido_min",
        "progresso_data_criacao",
    ],
    "columns": {
        "progresso_id": {"type": "int"},
        "progresso_matricula_id": {"type": "int"},
        "progresso_aula_id": {"type": "int"},
        "progresso_percentual": {"type": "int", "ge": 0, "le": 100},
        "progresso_concluida": {"type": "string", "enum": ["true", "false", "True", "False", True, False]},
        "progresso_data_conclusao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "progresso_tempo_assistido_min": {"type": "int", "ge": 0},
        "progresso_data_criacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
        "progresso_data_atualizacao": {"type": "date", "fmt": "%Y-%m-%d %H:%M:%S"},
    },
    "pk": ["progresso_id"],
}

def validate(df: pd.DataFrame) -> List[Issue]:
    issues: List[Issue] = []
    req, cols_spec, pk_cols = (
        SPEC_PROG["required"],
        SPEC_PROG["columns"],
        SPEC_PROG["pk"],
    )

    # 1) Estrutura
    issues += check_required_columns(df, req)
    if not any(i.kind == "structure" for i in issues):
        issues += check_required_not_null(df, req)

    # 2) Tipos/domínios
    if not any(i.kind == "structure" for i in issues):
        issues += validate_types_generic(df, cols_spec)

    # 3) “data_atualizacao ≥ data_criacao”     
    c = pd.to_datetime(df["progresso_data_criacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    a = pd.to_datetime(df["progresso_data_atualizacao"], errors="coerce", format="%Y-%m-%d %H:%M:%S")
    bad = c.notna() & a.notna() & (a < c)
    for i in df[bad].index:
        issues.append(Issue("quality", "Atualização não pode ser anterior à criação", int(i), "progresso_data_atualizacao"))

    # 4) PK
    issues += check_pk(df, pk_cols)

    # 5) FKs
    if not any(i.kind == "structure" for i in issues):
        issues += check_fk_exists(df, "progresso_matricula_id", "matriculas.csv", "matricula_id", "matriculas")
        issues += check_fk_exists(df, "progresso_aula_id", "aulas.csv", "aula_id", "aulas")

    # 6) Regras de negócio (quality)
    # Q1) concluída => percentual == 100
    concl = _bool_as_str(df["progresso_concluida"])
    pct = pd.to_numeric(df["progresso_percentual"], errors="coerce")
    bad_q1 = (concl == "true") & (pct != 100)
    for i in df[bad_q1].index:
        issues.append(Issue("quality", "Concluída requer percentual == 100", int(i), "progresso_percentual"))

    # Para Q2 e Q3, necessário ter a duração da aula
    try:
        from .common import get_data_root
        data_root = get_data_root()
    except Exception:
        data_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "data"))
    aulas_path = os.path.join(data_root, "aulas.csv")

    try:
        aulas_df = pd.read_csv(aulas_path)[["aula_id", "aula_duracao_min"]]
        aulas_df["aula_id"] = pd.to_numeric(aulas_df["aula_id"], errors="coerce").astype("Int64")
        aulas_df["aula_duracao_min"] = pd.to_numeric(aulas_df["aula_duracao_min"], errors="coerce")
        tmp = df.copy()
        tmp["progresso_aula_id"] = pd.to_numeric(tmp["progresso_aula_id"], errors="coerce").astype("Int64")
        tmp = tmp.merge(aulas_df, left_on="progresso_aula_id", right_on="aula_id", how="left")
        tempo = pd.to_numeric(tmp["progresso_tempo_assistido_min"], errors="coerce")
        dur   = pd.to_numeric(tmp["aula_duracao_min"], errors="coerce")

        # Q2) tempo_assistido <= duracao
        bad_q2 = tempo > dur
        for i in tmp[bad_q2].index:
            issues.append(Issue("quality", "Tempo assistido excede duração da aula", int(i), "progresso_tempo_assistido_min"))

        # Q3) concluída => tempo_assistido == duracao
        bad_q3 = (concl.loc[tmp.index] == "true") & (tempo != dur)
        for i in tmp[bad_q3].index:
            issues.append(Issue("quality", "Concluída requer tempo == duração da aula", int(i), "progresso_tempo_assistido_min"))

    except Exception:
        # silencioso: se não conseguir ler aulas.csv, apenas não aplica Q2/Q3
        pass


    return issues
