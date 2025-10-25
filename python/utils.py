# ===============================================================
# EduTech | utils.py
# ---------------------------------------------------------------
# Propósito:
# Utilitários auxiliares para os scripts Python do projeto EduTech.
# Inclui:
#   - Gerenciamento de paths e diretórios do projeto
#   - Configuração de logging padronizado
#   - Escrita de arquivos CSV a partir de dicionários
#   - Formatação de datas no padrão ISO (PostgreSQL)
# ===============================================================

from __future__ import annotations
import csv, logging
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Dict, Any
from datetime import datetime

@dataclass(frozen=True) # Classe imutável, garantindo que nenhum dado seja alterado durante a exec.
class Paths:
    """
    Estrutura imutável contendo os diretórios principais do projeto.
    """
    project_root: Path
    python_dir: Path
    data_dir: Path


def resolve_paths() -> Paths:
    """
    Resolve e retorna os principais caminhos do projeto.

    - Determina o diretório atual (`python/`)
    - Sobe um nível para obter o diretório raiz
    - Garante a existência da pasta `data/` para saída de CSVs

    Returns:
        Paths: objeto com `project_root`, `python_dir` e `data_dir`
    """
    python_dir = Path(__file__).resolve().parent
    project_root = python_dir.parent
    data_dir = project_root / "data"
    data_dir.mkdir(parents=True, exist_ok=True)
    
    return Paths(project_root, python_dir, data_dir)


def setup_logger(name: str = "edutech.generator", level: int = logging.INFO) -> logging.Logger:
    """
    Cria e configura um logger padronizado para exibir mensagens no terminal.

    Args:
        name (str): nome do logger (default: 'edutech.generator')
        level (int): nível de log (ex: logging.INFO)

    Returns:
        logging.Logger: instância configurada pronta para uso
    """
    logger = logging.getLogger(name)
    logger.propagat = False
    logger.setLevel(level)

    fmt = logging.Formatter("[%(levelname)s] %(message)s")
    
    if logger.handlers:
        for h in logger.handlers:
            h.setLevel(level)
            h.setFormatter(fmt)
        return logger
    
    handler = logging.StreamHandler()
    handler.setLevel(level)
    handler.setFormatter(fmt)
    logger.addHandler(handler)

    return logger


def write_csv(path: Path, rows: Iterable[Dict[str, Any]], fieldnames: Iterable[str]) -> None:
    """
    Escreve uma sequência de dicionários em um arquivo CSV.

    Args:
        path (Path): caminho completo do arquivo de saída
        rows (Iterable[Dict[str, Any]]): registros a serem gravados
        fieldnames (Iterable[str]): lista de colunas/cabeçalhos
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(fieldnames))
        w.writeheader()
        for r in rows: w.writerow(r)


def to_iso(dt: datetime) -> str:
    """
    Converte um objeto datetime para o formato ISO compatível com PostgreSQL.

    Args:
        dt (datetime): data/hora a ser convertida

    Returns:
        str: string formatada no padrão 'YYYY-MM-DD HH:MM:SS'
    """
    return dt.strftime("%Y-%m-%d %H:%M:%S")


def formatar_dinheiro(valor):
    '''
    Formata valores monetários
    '''

def calcular_taxa_conclusao(aulas_concluidas, total_aulas):
    '''
    Calcula percentual
    '''

def validar_email(email):
    '''
    Valida formato de email
    '''

def gerar_senha_hash():
    '''
    Simula geração de senha (preparação para API futura)
    '''

def formatar_data(data):
    '''
    Padroniza formato de datas
    '''
