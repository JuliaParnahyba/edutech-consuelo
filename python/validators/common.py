from __future__ import annotations
import logging, re, sys
from dataclasses import dataclass
from typing import List, Dict, Any
import pandas as pd

EMAIL_REGEX = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

@dataclass
class Issue:
    kind: str
    message: str
    row_index: int | None = None
    col: str | None = None

def get_logger(level: str = "INFO") -> logging.Logger:
    lvl = getattr(logging, level.upper(), logging.INFO)
    log = logging.getLogger("edutech.validators")

    if not log.handlers:
        h = logging.StreamHandler(sys.stdout)
        h.setFormatter(logging.Formatter("[%(levelname)s] %(message)s"))
        log.addHandler(h)

    log.setLevel(lvl)

    return log


def check_required_columns(df: pd.DataFrame, required: List[str]) -> List[Issue]:
    issues: List[Issue] = []

    for col in required:
        if col not in df.columns:
            issues.append(Issue("structure", f"Coluna obrigatória ausente: {col}", None, col))

    return issues

def check_required_not_null(df: pd.DataFrame, required: List[str]) -> List[Issue]:
    issues: List[Issue] = []

    for col in required:
        if col in df.columns:
            null_mask = df[col].isna() | (df[col].astype(str).str.strip() == "")
            for idx in df[null_mask].index.tolist():
                issues.append(Issue("null", "Campo obrigatório vazio", int(idx), col))

    return issues

def _coerce_numeric(series: pd.Series, kind: str) -> pd.Series:
    s = pd.to_numeric(series, errors="coerce")

    return s.astype("Int64") if kind == "int" else s

def validate_types_generic(df: pd.DataFrame, columns_spec: Dict[str, Any]) -> List[Issue]:
    issues: List[Issue] = []
    for col, colspec in (columns_spec or {}).items():
        if col not in df.columns:
            continue

        series = df[col]
        non_null = ~(series.isna() | (series.astype(str).str.strip() == ""))
        t = (colspec or {}).get("type", "string")

        if t == "int":
            coerced = _coerce_numeric(series, "int")
            bad_type = non_null & coerced.isna()
            issues += [Issue("type", "Valor inteiro inválido", int(i), col) for i in df[bad_type].index]

            # ge/le para inteiros (só onde o tipo é válido)
            ok_num = non_null & ~bad_type
            if "ge" in colspec:
                ge = colspec["ge"]
                bad = ok_num & (coerced < ge)
                issues += [Issue("domain", f"Valor menor que {ge}", int(i), col) for i in df[bad].index]
            if "le" in colspec:
                le = colspec["le"]
                bad = ok_num & (coerced > le)
                issues += [Issue("domain", f"Valor maior que {le}", int(i), col) for i in df[bad].index]

        elif t in ("float", "decimal"):
            coerced = _coerce_numeric(series, "float")
            bad_type = non_null & coerced.isna()
            issues += [Issue("type", "Valor numérico inválido", int(i), col) for i in df[bad_type].index]

            # ge/le para decimais (só onde o tipo é válido)
            ok_num = non_null & ~bad_type
            if "ge" in colspec:
                ge = colspec["ge"]
                bad = ok_num & (coerced < ge)
                issues += [Issue("domain", f"Valor menor que {ge}", int(i), col) for i in df[bad].index]
            if "le" in colspec:
                le = colspec["le"]
                bad = ok_num & (coerced > le)
                issues += [Issue("domain", f"Valor maior que {le}", int(i), col) for i in df[bad].index]

        elif t == "date":
            fmt = colspec.get("fmt")
            parsed = pd.to_datetime(series, errors="coerce", format=fmt)
            bad = non_null & parsed.isna()
            issues += [Issue("type", f"Data inválida (esperado {fmt})", int(i), col) for i in df[bad].index]

        elif t == "email":
            bad = non_null & ~series.astype(str).str.match(EMAIL_REGEX)
            issues += [Issue("domain", f"Email inválido: '{v}'", int(i), col) for i, v in series[bad].items()]

        else:
            # tipo string "livre"
            pass

        # Regras de domínio extras para strings/enums
        if "min_len" in colspec:
            bad = non_null & (series.astype(str).str.len() < int(colspec["min_len"]))
            issues += [Issue("domain", f"Comprimento menor que {colspec['min_len']}", int(i), col) for i in df[bad].index]
        if "enum" in colspec:
            allowed = set(colspec["enum"])
            bad = non_null & ~series.isin(allowed)
            issues += [Issue("domain", f"Valor '{v}' não permitido", int(i), col) for i, v in series[bad].items()]
    return issues


def check_pk(df: pd.DataFrame, pk_cols: list[str]) -> list[Issue]:
    issues: list[Issue] = []

    if not pk_cols:
        return issues

    if not all(c in df.columns for c in pk_cols):
        faltando = [c for c in pk_cols if c not in df.columns]
        issues.append(Issue("pk", f"Colunas de PK ausentes: {faltando}"))
        return issues

    dup_mask = df.duplicated(subset=pk_cols, keep=False)

    for idx in df[dup_mask].index.tolist():
        issues.append(Issue("pk", "PK duplicada", int(idx), ",".join(pk_cols)))
        
    return issues


# --- helpers de caminho para encontrar data/ ---
def get_data_root() -> str:
    try:
        from utils import resolve_paths  # opcional
        return str(resolve_paths().data_dir)
    except Exception:
        import os
        here = os.path.dirname(__file__)
        return os.path.abspath(os.path.join(here, "..", "..", "data"))

def check_fk_exists(
    df: pd.DataFrame,
    col: str,
    ref_filename: str,
    ref_col: str,
    table_label: str,
) -> list[Issue]:
    """
    Verifica se os valores de df[col] existem em table_label.ref_col (carregado de data/<ref_filename>).
    """
    issues: list[Issue] = []
    import os

    data_root = get_data_root()
    ref_path = os.path.join(data_root, ref_filename)

    # tentativa de leitura
    try:
        ref_df = pd.read_csv(ref_path)
    except Exception:
        return [Issue("fk", f"Falha ao ler referência '{table_label}' em {ref_path}")]

    if ref_col not in ref_df.columns:
        return [Issue("fk", f"Coluna ref ausente em {table_label}: {ref_col}")]

    if col not in df.columns:
        return [Issue("fk", f"Coluna FK ausente: {col}")]

    # --- Estratégia de coerção 1: numérica ---
    ref_num = pd.to_numeric(ref_df[ref_col], errors="coerce")
    fk_num  = pd.to_numeric(df[col], errors="coerce")

    if ref_num.notna().any() and fk_num.notna().any():
        ref_set = set(ref_num.dropna().astype("Int64").unique())
        to_check = fk_num.astype("Int64")
        bad_mask = ~to_check.isin(ref_set)
    else:
        # --- Estratégia de coerção 2: string normalizada ---
        ref_str = ref_df[ref_col].astype(str).str.strip()
        fk_str  = df[col].astype(str).str.strip()
        ref_set = set(ref_str.unique())
        to_check = fk_str
        bad_mask = ~to_check.isin(ref_set)

    # logs de diagnóstico (aparecem quando rodar o validador com INFO/DEBUG)
    # (evita logger aqui para não criar dependência cíclica; diagnóstico via Issue com row=None)
    if not ref_set:
        issues.append(Issue("fk", f"[diag] {table_label}.{ref_col}: 0 chaves carregadas de {ref_path}"))

    # materializa issues por linha
    for idx, val in to_check[bad_mask].items():
        issues.append(Issue("fk", f"'{val}' não encontrado em {table_label}.{ref_col}", int(idx), col))

    return issues

def _bool_as_str(series: pd.Series) -> pd.Series:
    """
    Converte para strings 'true'/'false' de forma tolerante:
    aceita bools reais e strings com qualquer capitalização.
    """
    s = series.copy()
    # primeiro, mapeia bool reais
    if s.dtype == bool:
        return s.map({True: "true", False: "false"})
    # strings: strip + lower + normalização de variantes
    s = s.astype(str).str.strip().str.lower()
    s = s.replace({"true": "true", "false": "false"})
    return s
