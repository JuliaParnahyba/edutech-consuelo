# ===============================================================
# EduTech | gerador_dados.py
# ---------------------------------------------------------------
# Propósito:
# CLI mínima do gerador de dados sintéticos para o projeto EduTech.
# Nesta etapa, o script:
#   - Define argumentos de linha de comando (argparse)
#   - Configura seed determinística (random + Faker)
#   - Resolve paths do projeto e configura logging
#   - (Sem geração de entidades ainda — feito nas próximas etapas)
# ===============================================================

from __future__ import annotations
import argparse
import random
from typing import Any
from faker import Faker
from datetime import datetime
from utils import resolve_paths, setup_logger, write_csv, to_iso

# -----------------------------
# Configurações padrão
# -----------------------------
DEFAULT_SEED = 42

# Lista base de categorias iniciais
CATEGORIA_BASE = [
  "Programação", "Dados", "Design", "Marketing",
  "DevOps", "Cloud", "Produto", "Segurança"
]


def parse_args() -> argparse.Namespace:
  """
  Constrói e interpreta os argumentos de linha de comando.

  Returns:
    argsparse.Namespace: objeto contendo os valores dos argumentos.
  """

  parser = argparse.ArgumentParser(
    description="Gerador de dados EduTech - etapa CLI + seed (mínima).",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
  )

  parser.add_argument(
    "--seed",
    type=int,
    default=DEFAULT_SEED,
    help="Seed para reprodutibilidade (controla random e Faker)"
  )

  parser.add_argument(
    "--categorias",
    type=int,
    default=8,
    help="Quantidade de categorias a gerar.",
  )

  return parser.parse_args()


def build_categorias(faker, count: int):
  """
  Gera uma lista de dicionários representando as categorias.

  Args:
      faker (Faker): instância do Faker configurada para pt_BR
      count (int): quantidade de categorias a gerar

  Returns:
      list[dict]: lista com registros de categorias
  """

  names = list(CATEGORIA_BASE)

  while len(names) < count:
    names.append(faker.unique.job().split(" ")[0])

  rows = []
  for idx in range(1, count + 1):
    nome = names[idx - 1]
    rows.append({
      "id": idx,
      "nome": nome,
      "descricao": f"Curso sobre {nome}",
      "created_at": to_iso(datetime.now()),
    })
  
  return rows

def gerar_alunos(quantidade):
  '''
  Gera dados de alunos com nomes, emails e datas realistas
  '''

def gerar_instrutores(quantidade):
  '''
  Gera dados de instrutores com especialidades
  '''

def gerar_cursos(quantidade):
  '''
  Gera cursos com títulos, descrições, preços variados
  '''

def gerar_aulas(curso_id, quantidade):
  '''
  Gera estrutura de módulos e aulas
  '''

def gerar_matriculas(quantidade):
  '''
  Gera matrículas distribuídas entre alunos e cursos
  '''

def exportar_para_csv():
  '''
  Exporta todos os dados gerados para arquivos CSV separados
  '''

def main() -> None:
  """
  Ponto de entrada do gerador (versão mínima).
  - Lê argumentos da CLI
  - Configura seed determinística
  - Instancia Faker em pt_BR
  - Resolve paths e configura logger
  - Exibe mensagens de diagnóstico
  """

  # 1. Ler argumentos
  args = parse_args()

  # 2. Seed determinística para reprodutividade dos dados
  rng = random.Random(args.seed)
  faker = Faker("pt_BR")
  Faker.seed(args.seed)

  # 3. Infra básica: paths e logger
  paths = resolve_paths()
  log = setup_logger()

  # 4. Logs de diagnóstico (confirmação)
  log.info(f"Seed: {args.seed}")
  log.info(f"Exportando CSVs para: {paths.data_dir}")
  log.info(f"CLI mínima pronta.")

  # 5. Gerar categorias
  categorias = build_categorias(faker, args.categorias)
  write_csv(paths.data_dir / "categorias.csv", categorias, categorias[0].keys())
  log.info(f"categorias.csv: {len(categorias)} registros gerados")


if __name__ == "__main__":
  main()