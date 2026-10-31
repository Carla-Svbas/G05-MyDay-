# Arquitetura MVC — MyDay (G05)

O projeto segue a organização da aula **"Modelos, MVC e organização de aplicações Flutter"** (Aulas 13‑14).

## 1. Estrutura de pastas

```
lib/
├── main.dart
├── models/        Model: classes de dados (sem material.dart)
├── data/          dados fictícios (mock), num único local
├── controllers/   Controller: estado e operações (ChangeNotifier)
├── screens/       View: um ficheiro por ecrã (*_page.dart)
└── widgets/       componentes reutilizáveis (cartões, botões, cores)
```

| Pasta | Ficheiros |
|---|---|
| `models/` | `utilizador.dart`, `registo.dart` (+ `Visibilidade`), `comentario.dart`, `projeto.dart`, `grupo_estudo.dart`, `local.dart`, `conquista.dart`, `definicoes.dart`, `denuncia.dart`, `acao_admin.dart` |
| `data/` | `utilizadores_demo.dart`, `registos_demo.dart`, `projetos_demo.dart`, `locais_demo.dart`, `comunidade_demo.dart` |
| `controllers/` | `sessao_controller.dart`, `registo_controller.dart`, `projeto_controller.dart`, `comunidade_controller.dart`, `perfil_controller.dart`, `admin_controller.dart`, `controladores.dart` |
| `screens/` | `login_page.dart`, `criar_conta_page.dart`, `inicio_page.dart`, `diario_page.dart`, `lista_page.dart`, `mapa_page.dart`, `calendario_page.dart`, `novo_registo_page.dart`, `registo_page.dart`, `projetos_page.dart`, `projeto_page.dart`, `comunidade_page.dart`, `perfil_page.dart`, `admin_page.dart` |
| `widgets/` | `registo_card.dart`, `projeto_card.dart`, `publicacao_card.dart`, `denuncia_card.dart`, `grupo_card.dart`, `barra_navegacao.dart`, `seletor.dart`, `botao_filtro.dart`, `etiqueta.dart`, `avatar.dart`, `titulo_secao.dart`, `mapa_fundo.dart`, `cores.dart`, `formatar_data.dart` |

## 2. Regras da aula aplicadas

| Regra (aula) | Como está no projeto |
|---|---|
| O modelo representa uma entidade e **não importa `material.dart`** | Todos os ficheiros de `models/` só usam Dart. |
| Atributos `final`, construtor com `required`, `const` quando possível | Ex.: `Utilizador`, `Comentario`, `Local`. |
| **getter** para valores calculados | `Registo.temFoto`, `Utilizador.primeiroNome`. |
| **copyWith** para criar uma nova versão sem modificar | `Registo`, `Projeto`, `Definicoes`, `Denuncia`. Ex.: comentar cria um novo `Registo` com a lista de comentários aumentada. |
| Dados mock **num único local** (`data/`) | As listas `...Demo` estão só em `data/`. |
| Evitar **listas globais mutáveis** | Cada controller faz uma cópia: `List.of(registosDemo)`. |
| O controller **guarda o estado e as ações**, não desenha widgets nem navega | Os controllers só importam `foundation.dart` e os modelos. |
| `List.unmodifiable` para expor a lista | `RegistoController.todos`, `SessaoController.utilizadores`, … |
| `notifyListeners()` avisa o ecrã | Em todas as ações que mudam dados. |
| O ecrã atualiza com **`addListener` + `setState`** e remove o listener no `dispose` | Ex.: `diario_page.dart`, `registo_page.dart`, `projetos_page.dart`. |
| **Widgets reutilizáveis** em vez de copiar cartões | `RegistoCard` é usado para todos os registos; `ProjetoCard` para todos os projetos. |
| **ListView/GridView.builder** para listas dinâmicas | `projetos_page.dart` (grelha de projetos). |
| **Navigator.push** para abrir o detalhe | Ex.: tocar num cartão abre `RegistoPage`. |
| Sem bibliotecas externas, bases de dados ou APIs | Só o Flutter. Os dados ficam em memória. |

## 3. Fluxo de um evento (exemplo: comentar um registo)

1. O utilizador escreve um comentário em `RegistoPage` e toca na seta.
2. O ecrã chama `app.registos.comentar(id, utilizador, texto)`.
3. O `RegistoController` valida e cria um novo `Registo` com `copyWith(comentarios: [...])`.
4. `notifyListeners()` avisa quem está a ouvir.
5. O `setState()` de `RegistoPage` (e do Diário) reconstrói a vista com o estado atual.

## 4. Os controllers e quem usa quem

```
SessaoController ....... quem está a usar a app (entrar, criar conta, convidado, sair)
RegistoController ...... registos, comentários, favoritos, mapa, calendário, denúncias
ProjetoController ───▶ RegistoController          (registos de cada projeto)
ComunidadeController ▶ Sessao + Registo            (feed, seguir, desafio)
PerfilController ────▶ Sessao + Registo + Projeto  (conquistas, definições, apagar conta)
AdminController ─────▶ Registo + Comunidade        (moderação, estatísticas, desafios)
```

`controladores.dart` junta os seis numa classe `Controladores`, criada uma vez em `main.dart` (`criarControladores()`) e passada aos ecrãs (`app`). Assim cada ecrã recebe um só parâmetro.

Os registos, projetos e denúncias são identificados por um `id`. Os ecrãs de detalhe recebem o `id` e pedem sempre a versão atual ao controller (`procurar(id)`), porque com `copyWith` o objeto antigo é substituído por um novo.

## 5. Navegação

- `main.dart` define a rota `'/'` (ecrã Entrar). "Terminar sessão" e "Sair" voltam lá com `pushNamedAndRemoveUntil('/')`.
- Depois de entrar: `InicioPage` com a barra inferior (Diário, Projetos, +, Comunidade, Perfil). O administrador vai para `AdminPage`.
- **Criar conta:** o botão "Criar conta" abre `CriarContaPage` (nome, email, curso, palavra-passe e confirmação). Se alguém tentar **Entrar** com um email que não tem conta, o `SessaoController` devolve o erro "Não existe nenhuma conta com este email" e marca `semConta = true`. O ecrã Entrar mostra o erro e abre logo `CriarContaPage`, com o email já preenchido. As validações (nome vazio, email inválido, palavra-passe curta, palavras-passe diferentes, email repetido) ficam no controller.
- Este ecrã **não existe no Figma**, por isso usa o mesmo estilo dos campos e botões do ecrã Entrar.
- O Diário troca entre `ListaPage`, `MapaPage` e `CalendarioPage`.
- Os detalhes (`RegistoPage`, `ProjetoPage`) abrem com `Navigator.push`.

Mapa completo em `navegacao.md`.

## 6. Decisões de protótipo

- **Imagem estática** no ecrã Entrar (sem animação).
- **Simulado:** câmara, microfone, GPS, mapa real, PDF, QR Code, email de recuperação, mensagens. O mapa é desenhado com `Container`s coloridos.
- Os ícones são os Material Icons do Flutter (exceto os do ecrã Entrar, exportados do Figma).
- Os números vêm dos dados de exemplo, por isso são mais pequenos que os do Figma.

## 7. Testes

`test/widget_test.dart` tem 13 testes (login, criar conta, dias seguidos, criar registo, comentar com `copyWith`, mapa e calendário, projetos, comunidade, perfil, administração e o ecrã Entrar). Correr com `flutter test`.

## 8. Contas de teste

| Email | Palavra-passe | Vai para |
|---|---|---|
| rodrigo@escola.pt | 123456 | Diário (utilizador principal) |
| admin@escola.pt | admin123 | Administração |
| cecilia@escola.pt, tiago@escola.pt, ines@escola.pt | 123456 | Colegas da Comunidade |
