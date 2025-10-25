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
from typing import Any, Set
from faker import Faker
from datetime import datetime, timedelta
from utils import resolve_paths, setup_logger, write_csv, to_iso

# -----------------------------
# Configurações padrão
# -----------------------------
DEFAULT_SEED = 42

# Lista de nível de cursos
NIVEIS = ["iniciante", "intermediário", "avançado"]

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

  parser.add_argument(
    "--especialidades",
    type=int,
    default=12,
    help="Quantidade de especialidades a gerar.", 
  )

  parser.add_argument(
    "--instrutores",
    type=int,
    default=12,
    help="Quantidade de instrutores a gerar.",
  )


  return parser.parse_args()


def build_categorias(faker, count: int) -> list[dict]:
  """
  Gera categorias compatíveis com o DDL:
  categoria_id, categoria_nome, categoria_descricao, categoria_data_criacao

  Args:
    faker (Faker): instância do Faker configurada para pt_BR
    count (int): quantidade de categorias a gerar

  Returns:
    list[dict]: lista com registros de categorias
  """

  names = list(CATEGORIA_BASE)

  while len(names) < count:
    names.append(faker.unique.job().split(" ")[0])

  rows: list[dict] = []
  now_iso = to_iso(datetime.now())

  for idx in range(1, count + 1):
    nome = names[idx - 1]
    rows.append({
      "categoria_id": idx,
      "categoria_nome": nome,
      "categoria_descricao": f"Categoria de cursos sobre {nome}",
      "categoria_data_criacao": now_iso,
      "categoria_data_atualizacao": now_iso,
    })
  
  return rows

def build_especialidades(faker, count: int) -> list[dict]:
  """
  Gera especialidades compatíveis com o DDL:
  especialidade_id, especialidade_nome (UNIQUE), especialidade_descricao, especialidade_data_criacao

  Args:
    faker (Faker): instância do Faker configurada para pt_BR
    count (int): quantidade de categorias a gerar
  
  Returns:
      list[dict]: lista com registros de especialidades
  """

  base = ["Python", "SQL", "DevOps", "UI/UX", "Cloud", "Segurança", "Dados", "Agile"]
  nomes = list(dict.fromkeys(base))

  while len(nomes) < count:
    nomes.append(faker.unique.job().split(" ")[0][:50])

  now_iso = to_iso(datetime.now())
  rows = []
  
  for idx in range(1, count + 1):
    nome = nomes[idx - 1]
    rows.append({
      "especialidade_id": idx,
      "especialidade_nome": nome,
      "especialidade_descricao": f"Especialidade em {nome}",
      "especialidade_data_criacao": now_iso,
    })

  return rows


def build_nivel_cursos() -> list[dict]:
  """
  Gera nivel_cursos compatíveis com o DDL:
  nivel_curso_id, nivel_curso_nome (UNIQUE), nivel_curso_descricao, nivel_curso_data_criacao

  Returns:
    list[dict]: lista com registros dos noveis de cursos
  """
  niveis = [
      (1, "iniciante", "Fundamentos para iniciantes"),
      (2, "intermediário", "Aprofundamento prático"),
      (3, "avançado", "Tópicos avançados e projetos"),
  ]
  now_iso = to_iso(datetime.now())

  return [{
      "nivel_curso_id": nid,
      "nivel_curso_nome": nome,
      "nivel_curso_descricao": desc,
      "nivel_curso_data_criacao": now_iso,
  } for (nid, nome, desc) in niveis]


def build_situacoes_matricula() -> list[dict]:
  """
  Gera situacoes_matricula compatíveis com o DDL:
  situacao_matricula_id, situacao_matricula_tipo (UNIQUE), situacao_matricula_descricao, situacao_matricula_data_criacao
  
  Returns:
  list[dict]: lista com registros dos tipos de situação de matrícula
  """
  tipos = [
    (1, "ativa", "Matrícula ativa"),
    (2, "concluída", "Curso concluído"),
    (3, "cancelada", "Matrícula cancelada"),
    (4, "pendente", "Aguardando pagamento/validação"),
  ]
  now_iso = to_iso(datetime.now())
  return [{
    "situacao_matricula_id": sid,
    "situacao_matricula_tipo": nome,
    "situacao_matricula_descricao": desc,
    "situacao_matricula_data_criacao": now_iso,
  } for (sid, nome, desc) in tipos]


def split_first_last(full_name: str) -> tuple[str, str]:
  """
  Separa nome e sobrenome

  Args:
    full_name(str): nome completo gerado pelo Faker
  
  Retorno:
    Array com nome e sobrenome.
  """

  parts = full_name.strip().split()
  if len(parts) == 1:
      return parts[0], ""
  return " ".join(parts[:-1]), parts[-1]


def unique_email(faker, existing: Set[str]) -> str:
  """
  Gera um email único usando o Faker, garantindo que não repita
  """
  while True:
    e = faker.unique.email()
    if e not in existing:
      existing.add(e)
      return e


def build_instrutores(faker, count: int, rng, especialidade_ids: list[int]) -> tuple[list[dict], list[dict]]:
  """
  Gera registros de instrutores com e-mails únicos e datas realistas.
    - instrutores.csv: instrutor_id, instrutor_primeiro_nome, instrutor_ultimo_nome, instrutor_email, instrutor_especial_principal_id, instrutor_biografia, instrutor_data_criacao
    - instrutor_especialidades.csv: (N:N) ie_instrutor_id, ie_especialidade_id, timestamps

  Args:
    faker (Faker): instância pt_BR
    count (int): quantidade de instrutores
    rng (random.Random): gerador pseudo-aleatório com seed fixa

  Returns:
    tuple[list[dict], list[dict]]: registros de instrutores_rows, instrutor_especialidades_rows
  """

  rows_instrutores: list[dict] = []
  rows_ie: list[dict] = []
  seen_emails: Set[str] = set()
  now = datetime.now()

  for idx in range(1, count + 1):
    nome = faker.name()
    first, last = split_first_last(nome)
    email = unique_email(faker, seen_emails)
    bio = faker.sentence(nb_words=12)
    created_at = now - timedelta(days=rng.randint(0, 800))

    # especialidade principal (FK obrigatória)
    principal_id = rng.choice(especialidade_ids)

    rows_instrutores.append({
      "instrutor_id": idx,
      "instrutor_primeiro_nome": first[:50],
      "instrutor_ultimo_nome": last[:50],
      "instrutor_email": email,
      "instrutor_especial_principal_id": principal_id,
      "instrutor_biografia": bio[:300],
      "instrutor_data_criacao": to_iso(created_at),
    })

    # Especialidades extras (0–2) — N:N
    extras = set()
    k = rng.randint(0, 2)

    while len(extras) < k:
      e = rng.choice(especialidade_ids)
      if e != principal_id:
          extras.add(e)

    for e in extras:
      rows_ie.append({
          "ie_instrutor_id": idx,
          "ie_especialidade_id": e,
          "ie_data_criacao": to_iso(created_at),
        })

  return rows_instrutores, rows_ie

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

  # 6. especialidades
  especialidades = build_especialidades(faker, args.especialidades)
  write_csv(paths.data_dir / "especialidades.csv", especialidades, especialidades[0].keys())
  log.info(f"especialidades.csv: {len(especialidades)}")

  # 7. niveis (fixos 3)
  nivel_cursos = build_nivel_cursos()
  write_csv(paths.data_dir / "nivel_cursos.csv", nivel_cursos, nivel_cursos[0].keys())
  log.info(f"nivel_cursos.csv: {len(nivel_cursos)}")

  # 8. situacoes_matricula (fixas 4)
  situacoes = build_situacoes_matricula()
  write_csv(paths.data_dir / "situacoes_matricula.csv", situacoes, situacoes[0].keys())
  log.info(f"situacoes_matricula.csv: {len(situacoes)}")

  # 9. Gerar instrutores
  instrutores, instrutor_especialidades = build_instrutores(
    faker=faker,
    count=args.instrutores,
    rng=rng,
    especialidade_ids=[e["especialidade_id"] for e in especialidades],
  )
  write_csv(paths.data_dir / "instrutores.csv", instrutores, instrutores[0].keys())
  log.info(f"instrutores.csv: {len(instrutores)}")

  write_csv(paths.data_dir / "instrutor_especialidades.csv", instrutor_especialidades, 
    instrutor_especialidades[0].keys() if instrutor_especialidades else ["ie_instrutor_id","ie_especialidade_id","ie_data_criacao"])
  log.info(f"instrutor_especialidades.csv: {len(instrutor_especialidades)} links")


if __name__ == "__main__":
  main()