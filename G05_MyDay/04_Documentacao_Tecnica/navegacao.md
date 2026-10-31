# Navegação entre ecrãs

Todos os ecrãs do Figma estão implementados (✔).

```
01 · Entrar ✔                        (rota '/', em main.dart)
 ├─ Entrar (estudante) ──────▶ Ecrã principal (barra inferior)
 ├─ Entrar (administrador) ──▶ 11 · Administração ✔
 ├─ Entrar (email sem conta) ▶ erro + Criar conta (com o email já escrito)
 ├─ Criar conta ─────────────▶ Criar conta ─ Criar ─▶ Ecrã principal
 │                                         └ "Já tens conta? Entrar" ─▶ volta ao Entrar
 └─ Continuar como convidado ▶ Ecrã principal (só conteúdo público)

Ecrã principal (barra inferior)
 ├─ Diário ─────▶ 02 · Lista ✔ / 07 · Mapa ✔ / 08 · Calendário ✔
 │                 ├─ cartão / marcador / dia ─▶ 04 · Registo ✔
 │                 └─ 04 · Registo "Ver no mapa" ─▶ 07 · Mapa, no local do registo
 ├─ Projetos ───▶ 05 · Projetos ✔
 │                 └─ projeto ─▶ 06 · Projeto ✔
 │                               ├─ + Registo ─▶ 03 · Novo registo (com o projeto)
 │                               └─ linha temporal ─▶ 04 · Registo
 ├─ [+] ────────▶ 03 · Novo registo ✔ (convidados: aviso)
 ├─ Comunidade ─▶ 09 · Comunidade ✔
 │                 ├─ cartão ─▶ 04 · Registo (comentar / denunciar)
 │                 └─ Desafio da semana ─▶ 03 · Novo registo
 └─ Perfil ─────▶ 10 · Perfil ✔
                   ├─ Terminar sessão ─▶ 01 · Entrar
                   └─ Apagar conta ────▶ 01 · Entrar (conta e registos apagados)

11 · Administração ✔
 ├─ Ocultar / Avisar autor / Ignorar ─▶ a denúncia sai da fila; fica no Registo de ações
 └─ Sair ─▶ 01 · Entrar

04 · Registo ─ ⋯ Denunciar ─▶ (fila de moderação do ecrã 11)
```
