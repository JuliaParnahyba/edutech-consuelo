# ===============================================================
# EduTech | utils_email.py
# ---------------------------------------------------------------
# Propósito:
# Utilitários auxiliares para os scripts Python do projeto EduTech.
# Inclui:
#   - Padronização de emails
# ===============================================================

from __future__ import annotations
from typing import Set
from datetime import date
import unicodedata, re

# -----------------------------
# Configurações padrão
# -----------------------------
EDUTECH_DOMAIN = "edutech.edu"


def _strip_accents(s: str) -> str:
    nfkd = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in nfkd if not unicodedata.combining(c)).lower()
    s = re.sub(r"[^a-z0-9\s\-']", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s


def _first_token(name: str) -> str:
    tokens = _strip_accents(name).split()
    if not tokens:
        return "user"
    stop = {"de", "da", "do", "dos", "das"}
    for t in tokens:
        if t not in stop:
            return t
    return tokens[0]


def _last_token(name: str) -> str:
    tokens = _strip_accents(name).split()
    if not tokens:
        return "user"
    stop = {"de","da","do","dos","das"}
    for t in reversed(tokens):
        if t not in stop:
            return t
    return tokens[-1]


def ensure_unique_email(candidate: str, existing: Set[str]) -> str:
    if candidate not in existing:
        existing.add(candidate)
        return candidate
    local, _, domain = candidate.partition("@")
    i = 2
    while True:
        trial = f"{local}.{i}@{domain}"
        if trial not in existing:
            existing.add(trial)
            return trial
        i += 1


def aluno_email_from_birthyear(last_name: str, birthdate: date, existing: Set[str]) -> str:
    """
    Padrão: ultimonome.YYYY@edutech.com.br
    (YYYY = ano de nascimento)
    """
    last = _last_token(last_name)
    yyyy = birthdate.year
    candidate = f"{last}.{yyyy}@{EDUTECH_DOMAIN}"
    return ensure_unique_email(candidate, existing)

def instrutor_email_from_name(first_name: str, last_name: str, existing: Set[str]) -> str:
    """
    Padrão: primeironome.ultimonome@edutech.com.br
    """
    first = _first_token(first_name)
    last = _last_token(last_name)
    candidate = f"{first}.{last}@{EDUTECH_DOMAIN}"
    return ensure_unique_email(candidate, existing)