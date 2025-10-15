"""
Criar script que valida arquivos CSV antes de importar no banco

Uso:
  python3 python/validador_csv.py

Validações obrigatórias:
  - Verificar se todos os campos obrigatórios estão preenchidos
  - Validar formato de email
  - Validar tipos de dados (números, datas)
  - Verificar valores dentro de ranges válidos (ex: notas entre 1-5)
  - Detectar duplicatas
  - Validar integridade referencial (IDs existentes)
  - Gerar relatório de erros encontrados
"""

