# Memória descritiva — MyDay

> **MyDay — o diário do percurso de estudante.**
> Uma app móvel onde o estudante regista o que aprende, organiza esses registos em projetos e partilha só o que quiser.

---

## 1. Objetivo da app

O MyDay quer ajudar o estudante a **guardar, num só sítio, o que aprende todos os dias** e a ver a sua evolução ao longo do curso.

Em concreto, a app pretende:

- tornar **rápido e simples** registar uma aprendizagem (texto, foto, vídeo, áudio e local);
- **organizar** os registos por disciplina e por projeto, para mais tarde os encontrar com facilidade;
- **motivar** o estudante a registar com regularidade (dias seguidos, conquistas, lembrete diário e desafio da semana);
- permitir **partilhar com controlo**: cada registo pode ser privado, só para amigos ou público;
- criar uma **comunidade de estudantes** que aprendem uns com os outros, num espaço moderado e seguro.

---

## 2. Público-alvo

| Grupo | Quem é | O que procura na app |
|---|---|---|
| **Principal** | Estudantes do ensino superior (ex.: Eng. Informática no IADE), entre os 18 e os 25 anos, habituados a usar o telemóvel no dia a dia | Um diário de estudo rápido de usar, que organize o trabalho e mostre o progresso |
| **Secundário** | Colegas de turma e grupos de estudo | Ver o que os outros aprendem, comentar e partilhar materiais |
| **Visitantes** | Quem ainda não tem conta (modo convidado) | Espreitar o conteúdo público antes de se registar |
| **Administração** | Moderadores da plataforma | Rever denúncias, ocultar conteúdo impróprio e acompanhar a atividade |

---

## 3. Problema que resolve

Os estudantes aprendem muito todos os dias, mas esse conhecimento **perde-se ou fica espalhado**:

- **Notas dispersas** — apontamentos no caderno, fotos do quadro na galeria, áudios no WhatsApp, links no browser. Mais tarde é difícil encontrar o que se aprendeu numa aula ou num projeto.
- **Falta de visão do progresso** — o estudante não tem forma simples de ver quanto já aprendeu, em que disciplinas e com que regularidade.
- **Pouca motivação para registar** — sem um hábito, os registos ficam esquecidos e só se lembram deles na véspera do exame.
- **Partilhar é "tudo ou nada"** — nas redes sociais ou se publica para todos ou não se publica. O estudante não controla com facilidade quem vê cada coisa.
- **Portefólio difícil de montar** — no fim de um projeto ou do curso, é trabalhoso juntar as provas do que se fez.

O MyDay junta tudo num **diário único, organizado e privado por defeito**, que o estudante pode partilhar quando e com quem quiser.

---

## 4. Principais funcionalidades

### 4.1 Conta e acesso
- **Entrar** com email e palavra-passe.
- **Criar conta** (nome, email, curso e palavra-passe). Se alguém tentar entrar com um email sem conta, a app mostra o erro e abre o ecrã Criar conta com o email já preenchido.
- **Continuar como convidado** — vê só o conteúdo público, sem poder criar, comentar ou seguir.
- Seletor de **idioma** no ecrã inicial.

### 4.2 Diário (três vistas)
- **Lista** — registos por ordem de data, cada um com disciplina, tags e anexos.
- **Mapa** — registos agrupados pelo local onde foram feitos (ex.: Biblioteca, Laboratório).
- **Calendário** — dias com registos, total do mês e registos por disciplina.
- Contador de **dias seguidos** a registar.

### 4.3 Novo registo
- Título, texto, disciplina e **tags**.
- Anexar **fotos, vídeo, áudio e localização**.
- Associar a um **projeto**.
- Escolher a **visibilidade**: privado, só amigos ou público.

### 4.4 Detalhe do registo
- Ver o conteúdo completo, os anexos e o local ("Ver no mapa").
- **Comentar**, marcar como favorito e **denunciar** conteúdo impróprio.

### 4.5 Projetos
- Criar, renomear e filtrar projetos por visibilidade.
- Cada projeto mostra a **linha temporal** dos seus registos.
- **Grupos de estudo** com colegas.

### 4.6 Comunidade
- Separadores **A seguir** e **Descobrir**, com pesquisa.
- **Seguir** colegas e ver os registos públicos deles.
- **Desafio da semana** para motivar novos registos.

### 4.7 Perfil
- Dados pessoais, número de registos e **conquistas** (ex.: 7 dias seguidos, 1.º projeto, 30 dias).
- Seguidores e pessoas a seguir, e um **código QR** para um colega te seguir.
- **Configurações**: localização, microfone e **lembrete diário** com hora à escolha.
- **Exportar os meus dados**, terminar sessão e **apagar conta** (apaga também os registos).

### 4.8 Administração
- **Fila de moderação** com as denúncias.
- Ações: **ocultar**, avisar o autor ou ignorar.
- **Registo de ações** dos moderadores e estatísticas da plataforma.

---

## 5. Notas sobre o protótipo

- A app foi feita em **Flutter/Dart**, com a arquitetura **MVC** dada nas aulas (ver `04_Documentacao_Tecnica/arquitetura_mvc.md`).
- Os dados são **fictícios** e ficam em memória (não há base de dados nem servidor).
- A câmara, o microfone, o GPS, o mapa real, os lembretes, o código QR e a exportação de dados são **simulados**, por se tratar de um protótipo.
- O design segue os 11 ecrãs feitos no **Figma**.
