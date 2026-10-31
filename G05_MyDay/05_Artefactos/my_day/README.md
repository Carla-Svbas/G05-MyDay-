# MyDay (G05)

## Elementos do grupo

- _(Nome do aluno 1 — número)_
- _(Nome do aluno 2 — número)_

## Tema do projeto

O **MyDay** é o diário do percurso de estudante. Permite registar o que se aprende (texto, foto, vídeo, áudio e local), organizar os registos em projetos e partilhar só o que se quiser (privado, só amigos ou público). Inclui uma área de comunidade e uma área de administração para moderar denúncias.

## Ecrãs disponíveis

1. **Entrar** — login, criar conta e entrada como convidado
2. **Criar conta**
3. **Diário · Lista** — registos agrupados por dia e contagem de dias seguidos
4. **Diário · Mapa** — registos por local
5. **Diário · Calendário** — registos por dia do mês
6. **Novo registo** — título, texto, disciplina, projeto, tags, multimédia e visibilidade
7. **Registo** — detalhe, comentários, ver no mapa, denunciar
8. **Projetos** — lista de projetos com filtros
9. **Projeto** — detalhe, linha temporal e adicionar registo
10. **Comunidade** — publicações públicas, desafio da semana e grupos de estudo
11. **Perfil** — estatísticas, conquistas, definições, terminar sessão e apagar conta
12. **Administração** — fila de denúncias, registo de ações e desafio da semana

Navegação: barra inferior (Diário, Projetos, +, Comunidade, Perfil) e `Navigator` (push/pop) para os ecrãs de detalhe. O mapa completo da navegação está em `../../04_Documentacao_Tecnica/navegacao.md`.

## Como executar

Na pasta do projeto (`my_day`):

```
flutter pub get
flutter run
```

A app arranca a partir de `lib/main.dart`. Não precisa de configurações extra nem de bibliotecas externas.

Contas de exemplo:

| Tipo | Email | Palavra-passe |
|---|---|---|
| Estudante | rodrigo@escola.pt | 123456 |
| Administrador | admin@escola.pt | admin123 |

Também é possível entrar como convidado. Testes: `flutter test`.

## Funcionalidades apenas simuladas

Nesta fase não há base de dados, API nem armazenamento persistente. Os dados vêm de listas Dart em `lib/data/` e perdem-se ao fechar a app.

- **Login e criação de conta**: validados contra utilizadores de exemplo, sem autenticação real.
- **Foto, vídeo e áudio**: só marcam o registo como tendo multimédia; a câmara e o microfone não são usados.
- **Localização e mapa**: os locais são fixos e o mapa é um fundo desenhado; não há GPS nem serviço de mapas.
- **Exportar PDF e exportar dados**: mostram só uma mensagem.
- **Códigos para seguir e partilhar projetos**: são simulados.
- **Pesquisa, notificações, mensagens e grupos de estudo**: mostram uma mensagem a indicar que ficam para uma próxima versão.
- **Denúncias e moderação**: funcionam apenas durante a sessão, sobre os dados de exemplo.

## Estrutura do código (MVC)

- `lib/models/` — classes de dados (Model)
- `lib/data/` — dados de exemplo (mock data)
- `lib/controllers/` — estado e operações (Controller)
- `lib/screens/` — ecrãs (View)
- `lib/widgets/` — componentes reutilizáveis (cartões, campos, botões, etiquetas, barra de navegação…)

Documentação completa: `../../04_Documentacao_Tecnica/`.
