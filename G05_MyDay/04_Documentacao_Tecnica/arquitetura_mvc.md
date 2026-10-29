# Arquitetura MVC — MyDay (G05)

## 1. O que é o MVC nesta app

A aplicação está dividida em três camadas, cada uma numa pasta de `05_Artefactos/my_day/lib/`:

| Camada | Pasta | Responsabilidade | Exemplo |
|---|---|---|---|
| **Model** | `models/` | Descreve os dados. Não desenha nada nem toma decisões. | `User` tem nome, email, curso... |
| **View** | `views/` | Desenha o ecrã e recebe os toques do utilizador. Não decide nada: pede ao Controller. | `LoginView` desenha o ecrã de Entrar |
| **Controller** | `controllers/` | Contém as regras e o estado. Recebe pedidos da View e atualiza os Models. | `AuthController.login()` verifica o email e a palavra-passe |

Fluxo de uma ação:

```
Utilizador toca em "Entrar"
      ↓
LoginView  ──chama──▶  AuthController.login(email, palavra-passe)
                              ↓ procura em sampleUsers (Models)
LoginView  ◀─devolve─  true / false (+ mensagem de erro)
      ↓
Abre o ecrã seguinte, ou mostra a mensagem
```

### Os 6 Controllers e quem usa quem

```
main.dart cria todos os Controllers (uma vez) e entrega-os aos ecrãs.

AuthController ......... quem está a usar a app (login, convidado, sair)
EntryController ........ registos, comentários, favoritos, mapa, calendário, denúncias
ProjectController ──usa──▶ EntryController      (contar registos de cada projeto)
CommunityController ─usa─▶ EntryController      (feed com registos de outras pessoas)
ProfileController ──usa──▶ Auth + Entry + Project (conquistas, apagar conta)
AdminController ────usa──▶ Entry + Community     (moderação, desafios)
```

Cada Controller estende `ChangeNotifier`. Quando muda alguma coisa, chama `notifyListeners()`. As Views que o estão a ouvir (`ListenableBuilder`) redesenham-se sozinhas.

## 2. Outras pastas

| Pasta | Para que serve |
|---|---|
| `theme/app_theme.dart` | Cores e fonte do Guia de estilo do Figma. Assim, cada cor só está escrita num sítio. |
| `data/sample_data.dart` | Dados de exemplo (iguais ao Figma). Fazem o papel de base de dados no protótipo. |
| `views/widgets/` | Peças visuais usadas pelas Views (ex.: animação do topo do Entrar). |
| `utils/pt_dates.dart` | Funções de apoio para datas em português. Não pertence a nenhuma camada do MVC: é usado por Controllers e Views. |
| `assets/` | Fonte Plus Jakarta Sans, ícones e imagens exportados do Figma. |

## 3. Decisões tomadas (e porquê)

1. **Sem bibliotecas externas.** Só usamos o Flutter. O `pubspec.yaml` não tem dependências além do próprio Flutter. Isto torna o código mais fácil de explicar e de correr.
2. **Controllers criados uma vez em `main.dart` e passados por construtor.** É a forma mais simples de partilhar o mesmo Controller entre ecrãs, sem padrões avançados (Provider, BLoC...).
3. **`ChangeNotifier`** (classe do próprio Flutter) nos Controllers: permite avisar os ecrãs quando os dados mudam. Vai ser usado a partir do ecrã Diário.
4. **Dados em memória.** Os dados vivem em listas. Ao fechar a app, os dados novos perdem-se. É suficiente para um protótipo.
5. **Ícones como imagens PNG exportadas do Figma.** O Flutter não lê SVG sem bibliotecas externas, por isso os ícones foram convertidos em PNG (3x, para ficarem nítidos).
6. **Navegação com `Navigator`.** `pushReplacement` depois do login, para o botão "voltar" não regressar ao ecrã de Entrar.

## 4. Ecrãs desenvolvidos

### Ecrã 01 · Entrar

| Ficheiro | Camada | O que faz |
|---|---|---|
| `models/user.dart` | Model | Dados de um utilizador (nome, email, palavra-passe, curso, se é administrador). |
| `data/sample_data.dart` | Dados | Dois utilizadores de exemplo: um estudante e um administrador. |
| `controllers/auth_controller.dart` | Controller | `login()`, `register()`, `continueAsGuest()`, `logout()`. Valida os campos e guarda o utilizador atual. |
| `views/login_view.dart` | View | Desenha o fundo, a barra de topo, o cartão branco com o formulário e os botões. |
| `views/widgets/login_header.dart` | View | Luzes desfocadas, ilustração e partículas com a animação de flutuar do Figma. |

**Funcionalidades:**
- **Entrar:** valida os campos; se o email e a palavra-passe estiverem certos, abre o Diário (ou a Administração, se for administrador). Se não, mostra a mensagem de erro.
- **Criar conta:** cria um utilizador com o email e a palavra-passe escritos (mínimo de 6 caracteres) e entra logo. O Figma não tem ecrã de registo, por isso usámos o mesmo formulário.
- **Continuar como convidado:** entra sem conta.
- **Esqueci-me da palavra-passe** e **seletor de idioma:** mostram uma mensagem (não há servidor de email nem outras línguas no protótipo).

**Animação:** no Figma, a ilustração sobe 5 px e as partículas sobem ou descem 4 px, em ciclo, com *ease-in-out*. Em Flutter usámos um `AnimationController` que vai de 0 a 1 e volta (`repeat(reverse: true)`), multiplicado pelo deslocamento de cada elemento.

### Ecrã 02 · Diário (Lista) e barra de navegação

| Ficheiro | Camada | O que faz |
|---|---|---|
| `models/entry.dart` | Model | Um registo (disciplina, título, texto, data, visibilidade, local/áudio/vídeo/foto) e o `enum EntryVisibility` (Privado, Só amigos, Público). |
| `data/sample_data.dart` | Dados | 13 registos do Rodrigo, um por dia nos últimos 12 dias. As datas são calculadas a partir de hoje, por isso aparecem sempre "Hoje" e "Ontem", como no Figma. |
| `controllers/entry_controller.dart` | Controller | `entriesFor()` (registos que cada utilizador pode ver), `streakDays()` (dias seguidos), `weekActivity()` (barras da semana), `entriesThisWeek()`, `addEntry()`. |
| `utils/pt_dates.dart` | Apoio | Datas em português ("Quarta, 28 de outubro", "Hoje", "Ontem") sem bibliotecas externas. |
| `views/main_view.dart` | View | Guarda o separador escolhido e mostra-o com `IndexedStack`; liga o botão "+". |
| `views/diary/diary_view.dart` | View | Troca entre Lista, Mapa e Calendário; redesenha quando há registos novos (`ListenableBuilder`). |
| `views/diary/diary_list_tab.dart` | View | Saudação, cartão dos dias seguidos e lista agrupada por dia. |
| `views/widgets/bottom_nav_bar.dart` | View | Barra inferior com o botão azul "+" ao centro. |
| `views/widgets/entry_card.dart` | View | Cartão de um registo. |
| `views/widgets/tag_chip.dart` | View | Etiquetas de disciplina e de visibilidade, com as cores do Figma. |
| `views/widgets/segmented_control.dart` | View | Seletor "Lista / Mapa / Calendário" (vai ser reutilizado noutros ecrãs). |

**Funcionalidades:**
- Os números do cartão escuro (dias seguidos, registos desta semana, barras dos dias) são **calculados** pelo Controller a partir dos registos, e não escritos à mão.
- Cada utilizador só vê os seus registos. Um **convidado** só vê registos públicos e não tem o cartão de dias seguidos.
- O botão **+** abre o Novo registo, mas um convidado recebe o aviso "Cria uma conta para fazeres registos".
- **Pesquisar** e **Notificações** mostram uma mensagem (não há ecrã desenhado para eles).
- Tocar num registo abre o ecrã 04; Mapa e Calendário são os ecrãs 07 e 08.

**Problema encontrado e resolvido (mudança da hora):** no início, a app mostrava "3 dias seguidos" em vez de 12. A 25 de outubro muda a hora, por isso esse dia tem 25 horas. Subtrair `Duration(days: 1)` (24 horas) à meia-noite de dia 26 dava a 1h de dia 25 e não a meia-noite, e a comparação falhava. A solução foi a função `addDays()`, que soma dias de calendário (`DateTime(ano, mês, dia + n)`) em vez de horas. Há um teste que confirma os 12 dias.

**Diferenças em relação ao Figma (por causa do limite do plano gratuito do Figma):**
- Os **ícones** deste ecrã são os Material Icons, que já vêm com o Flutter. São muito parecidos com os do Figma, mas não iguais, porque não foi possível exportá-los.
- As **cores** foram medidas diretamente na imagem do ecrã exportada do Figma.
- O Figma mostra "3 registos esta semana"; a app mostra o valor calculado a partir dos dados de exemplo (4).

### Ecrã 03 · Novo registo

| Ficheiro | Camada | O que faz |
|---|---|---|
| `models/entry.dart` | Model | Ganhou `project`, `tags`, `locationAddress` e `photoCount` (número de fotografias). |
| `data/sample_data.dart` | Dados | Listas de disciplinas e de projetos que se podem escolher. |
| `controllers/entry_controller.dart` | Controller | `createEntry()` valida (título e disciplina obrigatórios), cria o registo e chama `notifyListeners()`; `parseTags()` transforma o texto das tags numa lista. |
| `views/new_entry_view.dart` | View | Formulário: título, texto, fotografias, Foto/Vídeo/Áudio/Local, disciplina, projeto, tags e visibilidade. |
| `views/widgets/dashed_box.dart` | View | Caixa tracejada "adicionar fotografia", desenhada com `CustomPainter`, porque o Flutter não tem contorno tracejado pronto. |

**Como funciona (MVC):**
1. Enquanto o utilizador preenche, a View guarda o estado do formulário (variáveis com `setState`). Esse estado é temporário e só existe enquanto o ecrã está aberto.
2. Em **Guardar**, a View entrega os dados ao `EntryController.createEntry()`.
3. O Controller **valida**. Se faltar algo, devolve a mensagem de erro e a View mostra-a. Se estiver tudo certo, cria o `Entry` (Model) e chama `notifyListeners()`.
4. O Diário está a ouvir o Controller (`ListenableBuilder`), por isso **redesenha-se sozinho** e o registo novo aparece no topo. A contagem da semana também é atualizada.

**Funcionalidades:**
- **Foto** e a caixa **+** acrescentam uma fotografia; tocar numa fotografia remove-a.
- **Vídeo** e **Áudio** ligam e desligam uma gravação.
- **Local** mostra o cartão do local; o **×** remove-o.
- **Disciplina** e **Projeto** abrem uma lista de opções que sobe do fundo do ecrã (`showModalBottomSheet`). **Tags** abre uma caixa de texto (aceita "#a b, c").
- A **visibilidade** é Privado por defeito, como diz o Figma. O texto de ajuda muda conforme a opção escolhida.
- **Cancelar** volta ao Diário sem guardar.

**Simulações (sem bibliotecas externas não há acesso a câmara, microfone nem GPS):**
- Fotografias, vídeo e áudio não são gravados de verdade: o registo guarda apenas que existem (número de fotos, duração de exemplo).
- O local é sempre "Biblioteca IADE, Av. Dom Carlos I, Lisboa".

**Diferenças em relação ao Figma:**
- O Figma mostra o formulário já preenchido, como exemplo. A app abre o formulário vazio, com textos de ajuda ("Título do registo", "O que aprendeste hoje?").
- Os projetos possíveis são os do ecrã 05 (Matemática Discreta, App MyDay, Redes, Bases de Dados). O "Mobile" que aparece no Figma não existe nesse ecrã.
- Os ícones são os Material Icons do Flutter (mesmo motivo do ecrã 02).

### Ecrã 04 · Registo

| Ficheiro | Camada | O que faz |
|---|---|---|
| `models/comment.dart` | Model | Um comentário (autor, texto, data). |
| `models/entry.dart` | Model | Ganhou a lista `comments`. |
| `controllers/entry_controller.dart` | Controller | `toggleFavorite()` / `isFavorite()`, `addComment()` (convidados não podem comentar), `isOwner()` e `deleteEntry()`. |
| `utils/pt_dates.dart` | Apoio | "28 out 2026 · 10:42" e "agora / 5 min / 1 h / 3 d". |
| `views/entry_detail_view.dart` | View | Fotografia, etiquetas, título, texto, local, tags, ações, comentários e caixa para comentar. |
| `views/widgets/initials_avatar.dart` | View | Círculo com as iniciais (ex.: "CZ"); a cor é escolhida a partir do nome. |

**Funcionalidades:**
- Abre ao tocar num cartão do Diário. O botão **‹** volta atrás.
- **Favoritar:** marca ou desmarca; o botão fica azul e passa a dizer "Favorito".
- **Comentar:** escreve-se em baixo e envia-se com a seta (ou com Enter). O comentário aparece logo e o contador sobe. Os convidados veem a caixa desativada.
- **Ícone dos comentários:** põe o cursor na caixa de comentário.
- **⋯ (mais opções):** o autor pode **apagar** o registo (com confirmação); os outros utilizadores podem **denunciar**.
- **PDF** e **Ver no mapa** mostram uma mensagem por agora. O mapa é o ecrã 07.
- O ecrã usa `ListenableBuilder`: quando o Controller muda (favorito ou comentário novo), o ecrã redesenha-se.

**Decisão de layout:** se o nome do projeto for comprido, a etiqueta "Projeto · …" encolhe e acaba em "…" (`Expanded` + `TextOverflow.ellipsis`). Sem isto, a etiqueta "Privado" saía do ecrã.

**Diferenças em relação ao Figma:**
- O contador de comentários mostra o número real (o Figma mostra "2" com só um comentário visível).
- A cor do círculo das iniciais é calculada a partir do nome, por isso pode não coincidir com a do Figma.
- A denúncia ainda não chega à Administração; vai ser ligada no ecrã 11.

### Ecrãs 07 · Mapa e 08 · Calendário e estatísticas

| Ficheiro | Camada | O que faz |
|---|---|---|
| `models/map_place.dart` | Model | Um local do mapa (nome, morada e posição do marcador). |
| `data/sample_data.dart` | Dados | 5 locais (os do Figma); 12 dos 13 registos passaram a ter local. |
| `controllers/entry_controller.dart` | Controller | Mapa: `places`, `entriesAtPlace()` (com filtro dos últimos 30 dias), `placeOf()`. Calendário: `entriesOnDay()`, `totalEntries()`, `entriesPerSubject()`. |
| `views/diary/diary_map_tab.dart` | View | Mapa com marcadores, filtro "Últimos 30 dias", botão de localização e cartão do registo. |
| `views/widgets/map_background.dart` | View | O desenho do mapa (ruas, parques, rio) feito com `CustomPainter`. |
| `views/diary/diary_calendar_tab.dart` | View | Calendário do mês, 3 cartões de estatísticas e barras por disciplina. |
| `views/widgets/segmented_control.dart` | View | Ganhou o estilo escuro, usado por cima do mapa. |
| `views/diary/diary_view.dart` | View | Liga as três vistas e trata o "Ver no mapa". |

**Mapa:**
- Cada marcador mostra **quantos registos** foram feitos nesse local. O número é calculado pelo Controller e dá os mesmos valores do Figma: 3, 1, 1, 5 e 2.
- Tocar num marcador escolhe esse local: o marcador fica maior e escuro, e o cartão de baixo mostra o registo mais recente desse local. Tocar no cartão abre o Registo.
- **Últimos 30 dias** alterna para "Todos os registos".
- O botão de **localização** escolhe a Biblioteca IADE (localização simulada).
- **Ver no mapa** (no ecrã Registo) volta ao Diário e abre o Mapa já com o local desse registo escolhido. Para isso, o `DiaryView` passa uma função (`onShowOnMap`) aos ecrãs que precisam dela.

**Calendário:**
- O mês é construído com uma grelha de 7 colunas (`GridView`), em que a semana começa à segunda-feira. Antes do dia 1 ficam células vazias.
- Os dias com registos têm um ponto laranja. O dia de hoje fica num quadrado azul com ponto azul, e os dias futuros ficam a cinzento.
- Os botões **‹ ›** mudam de mês. Tocar num dia com registos abre a lista desse dia, e tocar num registo abre-o.
- Os 3 cartões (esta semana, dias seguidos, total) e as barras das disciplinas são **calculados** pelo Controller. Cada barra é proporcional à disciplina com mais registos.

**Diferenças em relação ao Figma:**
- **O mapa é um desenho**, não um mapa real: sem bibliotecas externas não é possível mostrar mapas reais com GPS. O desenho imita o do Figma (mesmas cores e disposição aproximada das ruas, parques e rio), porque o desenho original não pôde ser exportado (limite do plano gratuito do Figma).
- Os números do Calendário (86 registos, 33 de Matemática, …) vêm dos **dados de exemplo** da app (13 registos), por isso são mais pequenos.
- Como agora quase todos os registos têm local, os cartões do Diário mostram o local em vez do vídeo/áudio quando o registo tem os dois.

### Ecrãs 05 · Projetos e 06 · Projeto

| Ficheiro | Camada | O que faz |
|---|---|---|
| `models/project.dart` | Model | `Project` (dono, nome, descrição, visibilidade, data de criação, cor da capa) e `StudyGroup` (grupo de estudo). |
| `data/sample_data.dart` | Dados | 4 projetos e 1 grupo de estudo. Cada registo de exemplo passou a pertencer a um projeto. |
| `controllers/project_controller.dart` | Controller | **Novo.** `projectsFor()` (com filtro de visibilidade), `entriesOf()`, `subjectCount()`, `createProject()`, `editProject()`, `setVisibility()`. |
| `controllers/entry_controller.dart` | Controller | `projectNamesFor()` (projetos do utilizador para o Novo registo) e `renameProject()`. |
| `views/projects/projects_view.dart` | View | Ecrã 05: título, "+ Novo", filtros, grelha de projetos, grupos de estudo. |
| `views/projects/project_detail_view.dart` | View | Ecrã 06: dados do projeto, visibilidade, Exportar PDF / QR Code / + Registo, linha temporal. |
| `views/projects/project_widgets.dart` | View | Cores das capas e etiqueta de visibilidade por cima da capa. |
| `views/new_entry_view.dart` | View | Aceita um projeto já escolhido (`initialProject`). |

**Um Controller que usa outro:** o `ProjectController` recebe o `EntryController` no construtor, porque precisa dos registos para contar os de cada projeto. Em `main.dart` é criado com `late final`, para ser criado só depois do `EntryController` já existir. As Views destes ecrãs ouvem os dois Controllers ao mesmo tempo com `Listenable.merge([...])`.

**Ecrã 05 · Projetos:**
- **Filtros** Todos / Privados / Só amigos / Públicos (estado da View; a filtragem é feita no Controller).
- Cada cartão mostra o número de registos e a última atividade ("hoje", "ontem", "3 dias"), calculados a partir dos registos.
- **+ Novo** pede o nome e cria o projeto (o Controller valida nomes vazios ou repetidos).
- O **convidado** só vê projetos públicos e não vê grupos de estudo.
- O cartão do **grupo de estudo** mostra uma mensagem, porque o ecrã do grupo não existe no Figma.

**Ecrã 06 · Projeto:**
- O texto "5 registos · 2 disciplinas · desde 5 out" é calculado.
- **Quem pode ver este projeto:** só o dono pode mudar a visibilidade, e o texto de ajuda muda conforme a opção.
- **Editar (lápis):** muda o nome e a descrição. Os registos do projeto passam a usar o nome novo (`renameProject`).
- **+ Registo** abre o Novo registo com este projeto já escolhido. **QR Code** mostra um ícone de QR (simulação) e **Exportar PDF** mostra uma mensagem.
- **Linha temporal:** registos do projeto, do mais recente para o mais antigo. O ponto é azul se o registo for da última semana e cinzento se for mais antigo. Tocar abre o registo.

**Decisão de layout:** nos filtros e nas etiquetas das capas, o `Container` não tem `alignment`. Com `alignment`, um `Container` estica até à largura disponível; sem ele, fica só com o tamanho do texto. Este erro foi encontrado na verificação no browser.

**Diferenças em relação ao Figma:**
- Os números (registos por projeto, membros) vêm dos dados de exemplo, por isso são mais pequenos que os do Figma.
- O nome "Matemática Discreta" é comprido e é cortado com "…" no cartão (no Figma o projeto chama-se "Cálculo I").

### Ecrã 09 · Comunidade

| Ficheiro | Camada | O que faz |
|---|---|---|
| `data/sample_data.dart` | Dados | 3 colegas (Cecília, Tiago, Inês) com registos; quem segue quem (`sampleFollowing`); o desafio da semana. |
| `controllers/community_controller.dart` | Controller | **Novo.** `feed()` (A seguir / Descobrir + pesquisa), `canSee()` (regra de visibilidade), `isFollowing()` / `toggleFollow()`, contagens de seguidores, `authorName()`. |
| `controllers/entry_controller.dart` | Controller | `allEntries`: dá à Comunidade todos os registos (só para leitura). |
| `views/community_view.dart` | View | Título, mensagens, pesquisa, separadores, desafio da semana e cartões dos registos. |
| `views/widgets/pill_chip.dart` | View | **Partilhado.** Botão de filtro redondo (Projetos e Comunidade). |
| `views/widgets/study_group_card.dart` | View | **Partilhado.** Cartão de grupo de estudo (Projetos e Comunidade). |
| `views/widgets/tag_chip.dart` | View | A etiqueta de visibilidade pode aparecer sem ícone (`withIcon: false`). |

**A regra de visibilidade (no Controller, `canSee`):**
- **Público:** todos veem, incluindo convidados.
- **Só amigos:** só quem segue o autor vê. No protótipo, "amigo" quer dizer "pessoa que eu sigo".
- **Privado:** só o autor vê. Nunca aparece na Comunidade.

**Separadores:**
- **A seguir:** registos das pessoas que o utilizador segue.
- **Descobrir:** registos públicos de pessoas que ainda não segue.
- **Grupos:** os grupos de estudo.
- A **pesquisa** filtra enquanto se escreve, por título, texto, disciplina, autor ou tag.

**Outras funcionalidades:**
- Tocar num cartão abre o Registo (ecrã 04). Aí pode-se comentar e, como o registo não é do utilizador, o **⋯** mostra "Denunciar".
- **Favoritar** funciona diretamente no cartão.
- O **Desafio da semana** abre um Novo registo. O botão de **mensagens** e os **grupos** mostram uma mensagem, porque não há ecrãs desenhados para eles.

**Reutilização:** o botão de filtro e o cartão de grupo passaram a ser widgets próprios em `views/widgets/`, usados por dois ecrãs. Assim evita-se código repetido.

**Diferenças em relação ao Figma:**
- A lupa da pesquisa aparece a cinzento. No Figma está branca sobre fundo branco e por isso não se vê.
- A cor das miniaturas alterna pela ordem dos cartões, e a cor dos círculos das iniciais é calculada a partir do nome. Pode não coincidir com o Figma.

### Ecrã 10 · Perfil e privacidade

| Ficheiro | Camada | O que faz |
|---|---|---|
| `models/profile.dart` | Model | `Achievement` (conquista) e `UserSettings` (localização, microfone, lembretes e hora). |
| `controllers/profile_controller.dart` | Controller | **Novo.** `achievementsOf()` (calculadas), `settingsOf()` e os `set...()` das configurações, `reminderText()`, `deleteAccount()`. |
| `controllers/community_controller.dart` | Controller | `followersOf()` / `followingOf()` (listas de pessoas). |
| `controllers/auth_controller.dart` | Controller | `deleteAccount()`. |
| `controllers/entry_controller.dart` | Controller | `deleteEntriesOf()` (apaga os registos de quem apaga a conta). |
| `views/profile_view.dart` | View | Cabeçalho, Dados Pessoais, Gerir Seguidores, Configurações, Terminar sessão. |
| `views/widgets/toggle_switch.dart` | View | Interruptor com o tamanho do Figma (48 × 28), feito com `AnimatedContainer`. |

**Funcionalidades:**
- **Registos:** total de registos do utilizador.
- **Conquistas:** calculadas a partir dos dados. "7 dias seguidos" desbloqueia com 7 ou mais dias seguidos, "1.º projeto público" com um projeto público e "30 dias seguidos" com 30. As bloqueadas aparecem com cadeado e contorno tracejado.
- **Seguidores / A seguir:** os números vêm do `CommunityController`. Tocar abre a lista de pessoas, com o botão Seguir / Deixar de seguir. Os números e a Comunidade atualizam-se logo.
- **Configurações:** os interruptores guardam o valor no Controller. Tocar na linha "Lembretes diários" abre o relógio do Flutter (`showTimePicker`) para mudar a hora.
- **Exportar os meus dados** é simulado. **QR Code** mostra um QR de exemplo.
- **Apagar conta** pede confirmação e depois apaga o utilizador e todos os seus registos, volta ao ecrã de Entrar e deixa de ser possível entrar com essa conta.
- **Terminar sessão** volta ao ecrã de Entrar com `pushAndRemoveUntil`, que apaga o histórico de ecrãs, para o botão "voltar" não regressar à conta.
- O **convidado** vê uma mensagem com o botão "Entrar ou criar conta".

**Nota sobre os Controllers:** os Controllers são criados em `main.dart` e passados de ecrã em ecrã pelo construtor. A lista de parâmetros fica comprida, mas é a forma mais simples e explícita de o fazer. Alternativas como `InheritedWidget` ou Provider foram evitadas de propósito, para não acrescentar complexidade.

**Diferenças em relação ao Figma:**
- O Figma mostra "Ana Lopes" no cabeçalho e "Rodrigo" no Diário. A app mostra sempre o utilizador que entrou.
- Os números (registos, seguidores) vêm dos dados de exemplo.
- Os interruptores de localização e microfone guardam a preferência, mas ainda não bloqueiam os botões "Local" e "Áudio" do Novo registo (possível melhoria).

### Ecrã 11 · Administração

| Ficheiro | Camada | O que faz |
|---|---|---|
| `models/report.dart` | Model | `Report` (denúncia a um registo ou comentário, motivo, nº de pessoas) e `AdminAction` (linha do registo de ações). |
| `models/entry.dart` | Model | Ganhou `hidden` (registo ocultado pela administração). |
| `data/sample_data.dart` | Dados | As 2 denúncias do Figma, o registo de ações, os utilizadores `estudante_10` e `estudante_45`. O desafio passou a poder ser mudado. |
| `controllers/entry_controller.dart` | Controller | `reportEntry()` (denunciar; denúncias iguais somam pessoas), `openReports`, `closeReport()`, `hideEntry()`, `removeComment()`. Os registos ocultados deixam de aparecer aos outros. |
| `controllers/admin_controller.dart` | Controller | **Novo.** `hide()` / `warnAuthor()` / `ignore()`, registo de ações, estatísticas, tags, `publishChallenge()`. |
| `views/admin_view.dart` | View | Cabeçalho escuro com separadores, estatísticas, fila de moderação e registo de ações. |
| `views/entry_detail_view.dart` | View | "Denunciar registo" pede o motivo e envia a denúncia para a fila. |

**O percurso completo de uma denúncia (testado no browser):**
1. Um estudante abre um registo de outra pessoa, toca em **⋯**, escolhe **Denunciar registo** e o motivo.
2. O `EntryController` junta a denúncia à fila (ou soma uma pessoa, se já existir igual).
3. A administradora entra (`admin@escola.pt`) e vê a denúncia na **Fila de moderação**.
4. **Ocultar:** o registo deixa de aparecer na Comunidade (ou o comentário é apagado). **Avisar autor:** o conteúdo fica, e o aviso é simulado. **Ignorar:** nada muda. Em todos os casos a denúncia sai da fila e a ação fica no **Registo de ações**.

**Outros separadores** (não desenhados no Figma, por isso em versão simples):
- **Estatísticas:** número de utilizadores, total de registos e registos de hoje.
- **Tags:** tags usadas e quantas vezes.
- **Desafios:** mostra o desafio atual. **Publicar novo desafio** muda o desafio que aparece na Comunidade.

**Rota com nome para "Terminar sessão" / "Sair":** em `main.dart`, o ecrã de Entrar é a rota `'/'`. Para sair, os ecrãs fazem `Navigator.pushNamedAndRemoveUntil('/', ...)`. Assim não precisam de conhecer todos os Controllers só para voltar ao Entrar.

**Problema encontrado e resolvido:** duas ações registadas no mesmo instante apareciam por ordem errada, porque eram ordenadas pela hora e esta era igual. Agora cada ação nova é guardada no início da lista. O teste da Administração apanhou este erro.

**Diferenças em relação ao Figma:**
- Os números (utilizadores ativos, registos hoje) vêm dos dados de exemplo.
- Os separadores Estatísticas, Tags e Desafios não têm design no Figma; foram feitos com o mesmo estilo dos outros ecrãs.

## 5. Resumo final

- **11 ecrãs** do Figma implementados (o 12 é o Guia de estilo, usado em `app_theme.dart`).
- **6 Controllers, 7 ficheiros de Models, nenhuma biblioteca externa.**
- **12 testes automáticos** em `test/widget_test.dart` (correr com `flutter test`).
- Todos os ecrãs foram comparados com o Figma no browser. As capturas estão em `02_Imagens` (`figma_XX` e `app_XX`).

**Simulado (precisaria de bibliotecas externas ou de um servidor):** câmara, microfone, GPS e mapa real, PDF, QR Code, email de recuperação, mensagens, envio de avisos. Os dados ficam em memória e perdem-se ao fechar a app.

**Possíveis melhorias:**
- Guardar os dados no telemóvel ou num servidor.
- Usar os interruptores de privacidade do Perfil para bloquear os botões Local e Áudio.
- Exportar os ícones originais do Figma (quando o limite do plano o permitir).
- Criar os ecrãs de grupos e mensagens.

**Contas de teste:**

| Email | Palavra-passe | Vai para |
|---|---|---|
| rodrigo@escola.pt | 123456 | Diário |
| admin@escola.pt | admin123 | Administração |
| cecilia@escola.pt, tiago@escola.pt, ines@escola.pt | 123456 | Diário (colegas da Comunidade) |
