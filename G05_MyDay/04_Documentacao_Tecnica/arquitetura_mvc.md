# Arquitetura MVC do MyDay (G05)

O projeto segue a organização dada nas aulas 13 e 14, "Modelos, MVC e organização de aplicações Flutter".

## 1. Estrutura de pastas

    lib/
    ├── main.dart
    ├── models/        classes de dados (Model)
    ├── data/          dados de exemplo
    ├── controllers/   estado e operações (Controller)
    ├── screens/       um ficheiro por ecrã (View)
    └── widgets/       componentes reutilizáveis

Em models estão as entidades da app: utilizador, registo, comentario, projeto, grupo_estudo, local, conquista, definicoes, denuncia e acao_admin. A pasta data tem os dados de exemplo de utilizadores, registos, projetos, locais e comunidade.

Há um controller para cada área (sessão, registos, projetos, comunidade, perfil e administração) e um ficheiro controladores.dart que os junta. Em screens existe um ficheiro por ecrã, todos terminados em _page.dart, e em widgets ficam os cartões, a barra de navegação, os botões, as cores e outros componentes usados em vários ecrãs.

## 2. Regras da aula aplicadas

Os modelos usam só Dart, sem importar material.dart. Os atributos são final, os construtores usam required e const sempre que possível, e os valores calculados são getters, como Registo.temFoto ou Utilizador.primeiroNome. Quando um objeto muda cria-se uma nova versão com copyWith. Comentar um registo, por exemplo, gera um novo Registo com mais um comentário na lista.

Os dados de exemplo estão todos na pasta data e cada controller trabalha sobre uma cópia deles, para não haver listas globais a ser alteradas. Os controllers guardam o estado e as ações, mas não desenham widgets nem fazem navegação. As listas são expostas com List.unmodifiable e todas as ações que mudam dados chamam notifyListeners().

Nos ecrãs, a atualização é feita com addListener e setState, e o listener é removido no dispose. Os cartões são widgets reutilizáveis (o RegistoCard serve para todos os registos e o ProjetoCard para todos os projetos), as listas dinâmicas usam ListView.builder ou GridView.builder e os detalhes abrem com Navigator.push.

Não usamos bibliotecas externas, bases de dados nem APIs. Os dados ficam em memória.

## 3. Exemplo de um evento: comentar um registo

1. O utilizador escreve o comentário na RegistoPage e toca na seta.
2. O ecrã chama app.registos.comentar(id, utilizador, texto).
3. O RegistoController valida o texto e cria um novo Registo com copyWith.
4. O notifyListeners() avisa os ecrãs que estão a ouvir.
5. A RegistoPage e o Diário fazem setState e mostram o registo atualizado.

## 4. Controllers

O SessaoController trata de quem está a usar a app (entrar, criar conta, convidado e sair) e o RegistoController dos registos, comentários, favoritos, mapa, calendário e denúncias. Os restantes dependem destes: o ProjetoController usa os registos de cada projeto, o ComunidadeController usa a sessão e os registos para o feed e os desafios, o PerfilController junta sessão, registos e projetos para as conquistas e definições, e o AdminController usa os registos e a comunidade para a moderação e as estatísticas.

Os seis estão reunidos na classe Controladores, criada uma única vez no main.dart e passada aos ecrãs com o nome app, para que cada ecrã receba só um parâmetro. Como o copyWith substitui os objetos, os ecrãs de detalhe recebem apenas o id e pedem sempre a versão atual ao controller com procurar(id).

## 5. Navegação

A app abre no ecrã Entrar. Depois do login, o utilizador vai para a InicioPage, com a barra inferior (Diário, Projetos, +, Comunidade e Perfil), e o administrador vai para a AdminPage. Terminar sessão volta ao ecrã Entrar com pushNamedAndRemoveUntil.

Se alguém tentar entrar com um email que não tem conta, aparece o erro "Não existe nenhuma conta com este email" e a app abre logo a CriarContaPage com o email preenchido. As validações deste formulário estão no SessaoController. Este ecrã não existia no Figma, por isso reaproveita o estilo do ecrã Entrar.

O Diário alterna entre lista, mapa e calendário, e os detalhes de registos e projetos abrem com Navigator.push. O mapa completo da navegação está em navegacao.md.

## 6. Decisões do protótipo

O ecrã Entrar tem uma imagem fixa, sem animação. A câmara, o microfone, o GPS, o mapa, os PDF, o QR Code, o email de recuperação e as mensagens são simulados, e o mapa é desenhado com Containers coloridos. Os ícones são os Material Icons do Flutter, exceto os do ecrã Entrar, que vieram do Figma. Os números que aparecem vêm dos dados de exemplo, por isso são mais baixos do que os do Figma.

## 7. Testes

O ficheiro test/widget_test.dart tem 13 testes que cobrem o login, criar conta, registos, comentários, mapa e calendário, projetos, comunidade, perfil e administração. Correm com flutter test.

## 8. Contas de teste

O utilizador principal é rodrigo@escola.pt (123456) e a conta de administração é admin@escola.pt (admin123). As contas cecilia@escola.pt, tiago@escola.pt e ines@escola.pt, também com 123456, são os colegas que aparecem na Comunidade.