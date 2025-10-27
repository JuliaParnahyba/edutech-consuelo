# ===============================================================
# EduTech | validador_csv.py
# ---------------------------------------------------------------
# Propósito:
# Valida e higieniza arquivos tabulares (CSV/TSV) antes da carga no PostgreSQL.
# Nesta etapa, o script:
#   - Verifica estrutura (colunas obrigatórias e ordem mínima, se solicitado)
#   - Valida tipos e domínios (int, float/decimal, string, date, email)
#   - Checa PK (unicidade) e FKs (referência entre arquivos)
#   - Regras de qualidade (ex.: email válido, datas coerentes, preços ≥ 0)
#   - Tratamento de nulos (imputação simples ou descarte)
#   - Deduplicação
#   - Geração de relatório (console + arquivo JSON e TXT)
#   - Saídas limpas em /data/clean e inválidas em /data/quarantine
#
# Integra com utils.py (opcional) para paths e logging.
# ===============================================================

from __future__ import annotations
import argparse, logging, sys, json
from typing import Dict
import pandas as pd

from validators.common import get_logger, Issue
from validators import (
  alunos as v_alunos,
  categorias as v_categorias,
  nivel_cursos as v_nivel,
  instrutores as v_instrutores,
  cursos as v_cursos,
  modulos as v_modulos,
  aulas as v_aulas,
  matriculas as v_matriculas,
  progresso_aulas as v_progresso,
  avaliacoes as v_avaliacoes,
)

VALIDATORS: Dict[str, object] = {
  "alunos": v_alunos,  
  "categorias": v_categorias,
  "nivel_cursos": v_nivel,
  "instrutores": v_instrutores,
  "cursos": v_cursos,
  "modulos": v_modulos,
  "aulas": v_aulas,
  "matriculas": v_matriculas,
  "progresso_aulas":v_progresso,
  "avaliacoes":v_avaliacoes,
}

def parse_args() -> argparse.Namespace:
  p = argparse.ArgumentParser(description="EduTech — Validador CSV (router por tabela)")

  p.add_argument(
    "--table",
    required=True,
    help="Tabela lógica (ex.: alunos)"
  )

  p.add_argument(
    "--input",
    required=True,
    help="Caminho do CSV de entrada (ex.: data/alunos.csv)"
  )

  p.add_argument(
    "--log-level",
    default="INFO",
    help="Nível de log"
  )

  return p.parse_args()


def main() -> int:
  args = parse_args()
  log = get_logger(args.log_level)

  if args.table not in VALIDATORS:
    log.error(f"Tabela não suportada ainda: {args.table}. Suportadas: {', '.join(VALIDATORS.keys())}")
    return 2

  try:
    df = pd.read_csv(args.input)
  except Exception as e:
    log.error(f"Falha ao ler CSV '{args.input}': {e}")
    return 1

  validator = VALIDATORS[args.table]
  issues = validator.validate(df)

  # Sumário simples
  summary = {
    "table": args.table,
    "rows_in": int(len(df)),
    "issues_total": len(issues),
    "issues_by_kind": {},
  }
  for it in issues:
    summary["issues_by_kind"].setdefault(it.kind, 0)
    summary["issues_by_kind"][it.kind] += 1

  log.info(json.dumps(summary, ensure_ascii=False))

  # Amostra de até 10 issues
  for it in issues[:10]:
    loc = f" row={it.row_index}" if it.row_index is not None else ""
    col = f" col={it.col}" if it.col else ""
    log.info(f"- [{it.kind}]{loc}{col} — {it.message}")

  # Código de saída: 0 se sem issues, 3 se houve issues
  return 0 if not issues else 3


if __name__ == "__main__":
    raise SystemExit(main())
