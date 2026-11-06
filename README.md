# MyDay (G05)

## Elementos do grupo

Nomes:
Carla Sebastião - Nº 20251243
Cristiano Zanzala - Nº 20251017
Lurdes Ferraz - Nº 20251345
Rodrigo Rodrigues - Nº 20250480

## Tema do projeto

O MyDay é um diário do percurso de estudante. Na app regista-se o que se aprende, em texto, foto, vídeo, áudio ou com a localização, e esses registos podem ser organizados em projetos. Cada registo pode ser privado, só para amigos ou público. A app tem ainda uma área de comunidade e uma área de administração onde se moderam as denúncias.

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

## Como executar

Dentro da pasta my_day:

    flutter pub get
    flutter run

A app arranca a partir do lib/main.dart e não precisa de configurações nem bibliotecas extra. Os testes correm com flutter test.

Para entrar podem usar a conta de estudante rodrigo@escola.pt (123456) ou a de administrador admin@escola.pt (admin123). Também é possível entrar como convidado.

## O que é simulado

Nesta fase não há base de dados, API nem armazenamento. Os dados vêm de listas em lib/data e perdem-se quando se fecha a app.

• O login e a criação de conta são validados contra os utilizadores de exemplo, sem autenticação real.

• Anexar foto, vídeo ou áudio apenas marca o registo como tendo multimédia. A câmara e o microfone não chegam a ser usados.

• Os locais são fixos e o mapa é um fundo desenhado, sem GPS nem serviço de mapas.

• Exportar PDF, exportar dados e os códigos para seguir colegas ou partilhar projetos mostram apenas uma mensagem.

• A pesquisa, as notificações, as mensagens e os grupos de estudo indicam que ficam para uma próxima versão.

• As denúncias e a moderação só funcionam durante a sessão, sobre os dados de exemplo.

## Estrutura do código

O código segue o padrão MVC. Os modelos estão em lib/models, os dados de exemplo em lib/data, os controllers em lib/controllers, os ecrãs em lib/screens e os componentes reutilizáveis (cartões, campos, botões, barra de navegação) em lib/widgets.

A documentação completa está na pasta 04_Documentacao_Tecnica.