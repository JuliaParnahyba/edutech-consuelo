# Conventional Commits — EduTech (versão simplificada)

## Regra única
`<tipo>(<escopo>): <descrição breve e objetiva>`

## Tipos aceitos
| Tipo       | Quando usar                                            |
| :--------- | :----------------------------------------------------- |
| `feat`     | nova funcionalidade SQL ou Python                      |
| `fix`      | correção de erro                                       |
| `docs`     | alterações em README ou documentação                   |
| `style`    | ajustes visuais ou formatação de código                |
| `refactor` | reestruturação sem mudança de comportamento            |
| `build`    | dependências, ambiente, Docker, venv etc.              |
| `chore`    | tarefas de manutenção (init, ajustes simples, configs) |

## Escopos
sql | python | docs | repo | data | infra

## Exemplo válidos:<br>
`feat(sql): create table cursos and aulas`
`fix(python): correct csv delimiter in data generator`
`docs(readme): update execution instructions`
`chore(repo): initialize folder structure`

## Regras gerais
- Tudo em **uma linha**
- Sempre em **inglês** e no **imperativo**
- Descrição curta e objetiva