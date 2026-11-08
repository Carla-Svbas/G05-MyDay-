# MyDay (G05)

## Elementos do grupo

Nomes:
Carla Sebastião - Nº 20251243
Cristiano Zanzala - Nº 20251017
Lurdes Ferraz - Nº 20251345
Rodrigo Rodrigues - Nº 20250480

## Tema do projeto

O MyDay é um diário do percurso de estudante. Na app regista-se o que se aprende, em texto, foto, vídeo, áudio ou com a localização, e esses registos podem ser organizados em projetos. Cada registo pode ser privado, só para amigos ou público. A app tem ainda uma área de comunidade e uma área de administração onde se moderam as denúncias.

## Design (Figma)

Os ecrãs e o guia de estilo foram desenhados no Figma: https://www.figma.com/design/Z10SqibLprkXmmXoTZuEwg/G05_MyDay_D01?node-id=5-2

## Ecrãs

1. Entrar: login, acesso à criação de conta e entrada como convidado
2. Criar conta
3. Diário em lista: registos agrupados por dia e contagem de dias seguidos
4. Diário em mapa: registos por local
5. Diário em calendário: registos por dia do mês
6. Novo registo: título, texto, disciplina, projeto, tags, multimédia e visibilidade
7. Registo: detalhe, comentários, ver no mapa e denunciar
8. Projetos: lista de projetos com filtros
9. Projeto: detalhe, linha temporal e adicionar registo
10. Comunidade: publicações públicas, desafio da semana e grupos de estudo
11. Perfil: estatísticas, conquistas, definições, terminar sessão e apagar conta
12. Administração: fila de denúncias, registo de ações e desafio da semana

A navegação principal é feita pela barra inferior (Diário, Projetos, +, Comunidade e Perfil), e os ecrãs de detalhe abrem e fecham com o Navigator. O mapa completo está em 04_Documentacao_Tecnica/navegacao.md.

## Organização do código (05_Artefactos)

- Aplicacao_Movel: a app em Flutter/Dart
- Backend: a API REST em Node.js com Express
- Base_Dados: create.sql, populate.sql e queries.sql (MySQL)
- Apresentacoes: os slides de cada apresentação

## Como executar

São três passos: criar a base de dados no MySQL, ligar a API (npm install e npm start, na pasta Backend) e correr a app (flutter pub get e flutter run, na pasta Aplicacao_Movel). As instruções completas estão em 04_Documentacao_Tecnica/como_executar.md.

Com a API ligada, entra-se com as contas da base de dados (por exemplo ines.carvalho02@gmail.com, palavra-passe myday123; administradora sofia.rebelo@myday.pt). Sem a API, a app continua a funcionar com os dados de exemplo do protótipo: estudante rodrigo@escola.pt (123456) e administrador admin@escola.pt (admin123). Também é possível entrar como convidado.

## O que já usa o servidor e o que ainda é simulado

Com a API ligada, o login, a criação de conta, o diário, a comunidade, os projetos, os novos registos e os comentários são lidos e gravados na base de dados MySQL.

Continua simulado:

• Anexar foto, vídeo ou áudio apenas marca o registo como tendo multimédia. A câmara e o microfone não chegam a ser usados.

• Os locais são fixos e o mapa é um fundo desenhado, sem GPS nem serviço de mapas.

• Exportar PDF, exportar dados e os códigos para seguir colegas ou partilhar projetos mostram apenas uma mensagem.

• A pesquisa, as notificações, as mensagens e os grupos de estudo indicam que ficam para uma próxima versão.

• Na app, as denúncias e a moderação ainda usam os dados de exemplo. A API já tem as rotas de denúncia e de moderação, ligadas à base de dados.

## Estrutura do código

O código segue o padrão MVC. Os modelos estão em lib/models, os dados de exemplo em lib/data, os controllers em lib/controllers, os ecrãs em lib/screens e os componentes reutilizáveis (cartões, campos, botões, barra de navegação) em lib/widgets.

A documentação completa está na pasta 04_Documentacao_Tecnica.