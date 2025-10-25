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

# Lista dos modelos de aulas
AULA_TIPOS = ["EAD", "hibrido", "presencial"]

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

  parser.add_argument(
    "--cursos",
    type=int,
    default=30,
    help="Quantidade de cursos a gerar."
  )

  parser.add_argument(
    "--modulos-min",
    type=int,
    default=3,
    help="Mínimo de módulos por curso"
  )

  parser.add_argument(
    "--modulos-max",
    type=int,
    default=6,
    help="Máximo de módulos por curso"
  )

  parser.add_argument(
    "--aulas-min",
    type=int,
    default=3,
    help="Mínimo de aulas por módulo"
  )

  parser.add_argument(
    "--aulas-max",
    type=int,
    default=6,
    help="Máximo de aulas por módulo"
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


def build_cursos(
  faker,
  count: int,
  rng,
  categoria_ids: list[int],
  instrutor_ids: list[int],
  nivel_ids: list[int],
) -> list[dict]:
  """
  Gera cursos compatíveis com o DDL:
  curso_id, curso_titulo, curso_descricao,
  curso_categoria_id (FK), curso_instrutor_id (FK), curso_nivel_id (FK),
  curso_carga_horaria, curso_preco, curso_data_criacao
  """

  rows: list[dict] = []
  used_titles: set[str] = set()
  now = datetime.now()

  for idx in range(1, count + 1):
    # título único (limite 100 chars)
    # faker.unique ajuda, mas garantimos via set também
    for _ in range(10):  # poucas tentativas
      t = faker.unique.catch_phrase()
      t = t[:100]
      if t not in used_titles:
          used_titles.add(t)
          titulo = t
          break
    else:
        titulo = f"Curso {idx}"

    descricao = faker.paragraph(nb_sentences=3)
    categoria_id = rng.choice(categoria_ids)
    instrutor_id = rng.choice(instrutor_ids)
    nivel_id = rng.choice(nivel_ids)

    carga_horaria = rng.randint(8, 120)
    preco = round(rng.uniform(49.9, 499.9), 2)
    created_at = now - timedelta(days=rng.randint(0, 730))

    rows.append({
      "curso_id": idx,
      "curso_titulo": titulo,
      "curso_descricao": descricao[:250],
      "curso_categoria_id": categoria_id,
      "curso_instrutor_id": instrutor_id,
      "curso_nivel_id": nivel_id,
      "curso_carga_horaria": carga_horaria,
      "curso_preco": f"{preco:.2f}",
      "curso_data_criacao": to_iso(created_at),
      # opcional: "curso_data_atualizacao": to_iso(created_at),
    })

  return rows


def build_modulos(
  faker,
  rng,
  cursos: list[dict],
  m_min: int,
  m_max: int,
) -> tuple[list[dict], dict[int, list[int]]]:
  """
  Gera modulos.csv compatível com DDL:
  - modulo_id, modulo_curso_id (FK), modulo_titulo, modulo_ordem, modulo_descricao, modulo_data_criacao
  Retorna (rows_modulos, mapa_curso->lista_modulo_id) para a próxima etapa (aulas)
  """
  rows: list[dict] = []
  curso_to_modulos: dict[int, list[int]] = {}
  now = datetime.now()
  modulo_id = 1

  for curso in cursos:
    curso_id = int(curso["curso_id"])
    qtd = rng.randint(m_min, m_max)
    curso_to_modulos[curso_id] = []
    for ordem in range(1, qtd + 1):
      titulo = f"Módulo {ordem}: {faker.bs().capitalize()}"
      rows.append({
        "modulo_id": modulo_id,
        "modulo_curso_id": curso_id,
        "modulo_titulo": titulo[:50],
        "modulo_ordem": ordem,                    # UNIQUE por curso com o par (curso,ordem)
        "modulo_descricao": faker.sentence(nb_words=12)[:250],
        "modulo_data_criacao": to_iso(now - timedelta(days=rng.randint(0, 730))),
      })
      curso_to_modulos[curso_id].append(modulo_id)
      modulo_id += 1

  return rows, curso_to_modulos


def build_aulas(
  faker,
  rng,
  curso_to_modulos: dict[int, list[int]],
  a_min: int,
  a_max: int,
) -> list[dict]:
  """
  Gera aulas.csv compatível com DDL:
  - aula_id, aula_modulo_id (FK), aula_titulo, aula_ordem, aula_duracao_min, aula_tipo, aula_data_criacao
  Respeita aula_tipo ∈ {'EAD','hibrido','presencial'} e UNIQUE (modulo, ordem).
  """
  rows: list[dict] = []
  aula_id = 1
  now = datetime.now()

  # distribuição levemente enviesada para EAD
  # (soma dos pesos = 10 → EAD 6/10, hibrido 3/10, presencial 1/10)
  pesos = [6, 3, 1]

  for mod_ids in curso_to_modulos.values():
    for modulo_id in mod_ids:
      qtd = rng.randint(a_min, a_max)
      for ordem in range(1, qtd + 1):
        tipo = rng.choices(AULA_TIPOS, weights=pesos, k=1)[0]
        duracao = rng.randint(8, 25) * 3   # múltiplos de 3 min (24–75)
        rows.append({
          "aula_id": aula_id,
          "aula_modulo_id": modulo_id,
          "aula_titulo": f"Aula {ordem}",
          "aula_ordem": ordem,           # UNIQUE por módulo com o par (modulo,ordem)
          "aula_duracao_min": duracao,
          "aula_tipo": tipo,
          "aula_data_criacao": to_iso(now - timedelta(days=rng.randint(0, 730))),
        })
        aula_id += 1

  return rows


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

  # 10. Gerar cursos
  cursos = build_cursos(
    faker=faker,
    count=args.cursos,
    rng=rng,
    categoria_ids=[c["categoria_id"] for c in categorias],
    instrutor_ids=[i["instrutor_id"] for i in instrutores],
    nivel_ids=[n["nivel_curso_id"] for n in nivel_cursos],
  )
  write_csv(paths.data_dir / "cursos.csv", cursos, cursos[0].keys())
  log.info(f"cursos.csv: {len(cursos)}")

  # 11. Módulos
  modulos, curso_to_modulos = build_modulos(
    faker=faker,
    rng=rng,
    cursos=cursos,
    m_min=args.modulos_min,
    m_max=args.modulos_max,
  )
  write_csv(paths.data_dir / "modulos.csv", modulos, modulos[0].keys() if modulos else
    ["modulo_id","modulo_curso_id","modulo_titulo","modulo_ordem","modulo_descricao","modulo_data_criacao"])
  log.info(f"modulos.csv: {len(modulos)}")

  # 12. Aulas
  aulas = build_aulas(
    faker=faker,
    rng=rng,
    curso_to_modulos=curso_to_modulos,
    a_min=args.aulas_min,
    a_max=args.aulas_max,
  )
  write_csv(paths.data_dir / "aulas.csv", aulas, aulas[0].keys() if aulas else
    ["aula_id","aula_modulo_id","aula_titulo","aula_ordem","aula_duracao_min","aula_tipo","aula_data_criacao"])
  log.info(f"aulas.csv: {len(aulas)}")


if __name__ == "__main__":
  main()