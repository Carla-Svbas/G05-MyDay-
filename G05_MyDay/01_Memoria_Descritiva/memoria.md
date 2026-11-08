# Memória descritiva do MyDay

## a. Identificação

- **Nome do projeto:** MyDay — o diário do percurso de estudante
- **Grupo:** G05 (Carla Sebastião, Cristiano Zanzala, Lurdes Ferraz e Rodrigo Rodrigues)
- **Ano letivo:** 2026/2027
- **Semestre:** 1.º semestre (3.º semestre da Licenciatura em Engenharia Informática)
- **Unidades curriculares e docentes (projeto multidisciplinar):**
  - Projeto de Desenvolvimento Móvel — Fábio Guilherme
  - Redes e Comunicações de Dados — Nathan Campos e Pedro Rosa
  - Programação de Dispositivos Móveis — João Pedro Duarte Barros Monge
  - Bases de Dados — Miguel Boavida
  - Interfaces e Usabilidade — Paula Neves
  - Matemática Discreta — André da Cunha Torcato e Ricardo Manuel Freitas de Sousa
- **Repositório:** https://github.com/Carla-Svbas/G05-MyDay-
- **Design (Figma):** https://www.figma.com/design/Z10SqibLprkXmmXoTZuEwg/G05_MyDay_D01?node-id=5-2

## b. Resumo

O MyDay é uma aplicação móvel que funciona como diário do percurso de estudante. Permite registar o que se aprende, em texto, fotografia, vídeo, áudio ou com a localização, organizar esses registos por disciplina e em projetos, e partilhar apenas o que se quiser.

O projeto nasce de um problema comum: os estudantes aprendem muito todos os dias, mas esse conhecimento fica espalhado por cadernos, pela galeria do telemóvel, por mensagens e por separadores do browser. Mais tarde, é difícil encontrar o que se aprendeu numa aula, ver a evolução ao longo do curso ou juntar as provas do trabalho feito num projeto. Nas redes sociais, partilhar é quase sempre tudo ou nada.

O MyDay responde com um diário único e organizado, privado por defeito. Cada registo ou projeto pode ser privado, visível só para amigos (pessoas que se seguem mutuamente) ou público. A aplicação inclui ainda três vistas do diário (lista, mapa e calendário), dias seguidos e conquistas para criar o hábito de registar, uma comunidade onde se seguem colegas, se comenta e se participa no desafio da semana, e uma área de administração para moderar denúncias.

O desenvolvimento seguiu um processo incremental, organizado pelas entregas da unidade curricular. Primeiro, foram definidos o problema, as personas e o modelo do domínio, e desenhados os ecrãs e o guia de estilo no Figma. Depois, foi construído um protótipo em Flutter com dados de exemplo, organizado segundo o padrão MVC. Na versão alfa, a aplicação passou a comunicar com uma API REST em Node.js com Express, que guarda os dados numa base de dados MySQL com 24 tabelas, views, triggers e procedimentos. A sessão usa tokens JWT, as palavras-passe são cifradas e as regras de visibilidade são verificadas no servidor.

Nesta fase, o login, a criação de conta, o diário, a comunidade, os projetos, os novos registos e os comentários já são lidos e gravados na base de dados. O projeto é acompanhado por testes automáticos da API e da aplicação, pela documentação técnica (BD Report, Dicionário de Dados, documentação REST, diagrama de classes) e por um plano de trabalhos.

Os próximos passos, até à versão final, são o envio de fotografias, vídeo e áudio, o mapa real com geocodificação através de APIs públicas, a moderação ligada à API e os testes com estudantes reais.

## c. Contexto

### i. Problema abordado

Os estudantes aprendem muito todos os dias, mas grande parte disso perde-se. Os apontamentos ficam no caderno, as fotos do quadro na galeria, os áudios no WhatsApp e os links no browser, e mais tarde é difícil encontrar o que se aprendeu numa aula ou num projeto.

Além disso, não existe uma forma simples de ver quanto já se aprendeu, em que disciplinas e com que regularidade. Sem o hábito de registar, as coisas acabam esquecidas até à véspera do exame. Também é trabalhoso juntar, no fim de um projeto ou do curso, as provas do que se fez.

Nas redes sociais, partilhar é quase sempre tudo ou nada: ou se publica para todos ou não se publica.

### ii. Motivação

A motivação é dupla:

- **Individual:** a aprendizagem tende a ser mais eficaz quando o estudante consegue ver e compreender o seu próprio percurso, o que favorece a reflexão e o acompanhamento da evolução.
- **Comunitária:** partilhar o percurso com colegas que estudam o mesmo cria motivação, troca de ideias e uma comunidade de estudantes de várias instituições.

Para o grupo, o projeto é também uma oportunidade de juntar num único produto o que se aprende em várias unidades curriculares: programação de dispositivos móveis, bases de dados, redes e comunicações de dados, interfaces e usabilidade, e matemática discreta.

### iii. Objetivos

A ideia principal é que o estudante tenha um único sítio onde guarda o que aprende todos os dias e onde consegue ver a sua evolução ao longo do curso. Para isso, a app procura:

- tornar rápido registar uma aprendizagem, seja em texto, foto, vídeo, áudio ou com a localização;
- organizar os registos por disciplina e por projeto, para serem fáceis de encontrar mais tarde;
- motivar o estudante a registar com regularidade, através dos dias seguidos, das conquistas e do desafio da semana;
- dar controlo sobre a partilha, já que cada registo pode ser privado, só para amigos ou público;
- criar uma comunidade de estudantes que aprendem uns com os outros, num espaço moderado;
- cumprir o RGPD: a localização e o áudio só são usados com autorização, e é possível apagar os registos e a conta.

**Público-alvo.** O público principal são estudantes do ensino superior, entre os 18 e os 25 anos, que usam o telemóvel todos os dias e querem um diário de estudo rápido. Os colegas de turma são um público secundário, interessado em ver o que os outros aprendem e comentar. Quem ainda não tem conta pode entrar como convidado e ver o conteúdo público. Por fim, os moderadores usam a área de administração para rever denúncias e acompanhar a atividade da plataforma. As personas detalhadas estão em `04_Documentacao_Tecnica/personas_e_guioes.md`.

## d. Processo

### i. Metodologia utilizada

O projeto segue um desenvolvimento **incremental**, organizado pelas entregas da unidade curricular:

1. **Proposta (semanas 1 a 5):** definição do problema, pesquisa de mercado, personas, modelo do domínio, mockups no Figma e planificação.
2. **Protótipo (semanas 6 a 8):** aplicação Flutter com os ecrãs do Figma, navegação completa e dados de exemplo, organizada em MVC.
3. **Versão alfa (semanas 8 a 9):** base de dados MySQL, API REST e ligação da aplicação à API; documentação técnica.
4. **Versão beta (semanas 10 a 12):** ficheiros multimédia, mapa real, moderação ligada à API e testes com utilizadores.
5. **Versão final (semanas 12 a 14):** correções, relatório final e demonstração.

Em cada fase, o núcleo do produto (registos, projetos e visibilidade) teve prioridade sobre as funcionalidades secundárias. O trabalho é acompanhado por reuniões semanais do grupo e por um plano de trabalhos com diagrama de Gantt (`04_Documentacao_Tecnica/plano_de_trabalhos.xlsx`).

### ii. Ferramentas utilizadas

| Ferramenta | Para que serviu |
|---|---|
| Figma | Ecrãs, protótipo e guia de estilo |
| Visual Studio Code | Desenvolvimento da aplicação e da API |
| Flutter SDK e emulador / Chrome | Correr e testar a aplicação |
| MySQL Server e MySQL Workbench | Criar e consultar a base de dados |
| Node.js e npm | Correr a API e instalar dependências |
| Git e GitHub | Controlo de versões e colaboração |
| PowerPoint e Excel | Apresentações e plano de trabalhos |

### iii. Tecnologias utilizadas

- **Aplicação móvel:** Dart com Flutter (arquitetura MVC: models, data, controllers, screens, widgets) e o pacote `http` para comunicar com a API.
- **Backend:** Node.js com Express; autenticação com JWT; palavras-passe cifradas com bcrypt; acesso à base de dados com mysql2.
- **Base de dados:** MySQL, com chaves estrangeiras, views, triggers, uma função e procedimentos armazenados.
- **Comunicação:** HTTP com pedidos REST em JSON.
- **Previstas para a versão beta:** APIs públicas OpenStreetMap, Nominatim, Wikipédia e PubChem.

### iv. Estrutura da equipa

| Elemento | Área de referência |
|---|---|
| Carla Sebastião | Frontend (aplicação móvel) |
| Lurdes Ferraz | Bases de dados |
| Rodrigo Rodrigues | Backend (API) |
| Cristiano Zanzala | Interfaces e usabilidade |

As áreas servem de referência, mas nesta fase todos os elementos participaram em todas elas, nos testes e na documentação.

## e. Resultados

### i. Descrição da solução desenvolvida

A solução tem três partes: uma aplicação móvel em Flutter, uma API REST em Node.js com Express e uma base de dados MySQL. A aplicação pede os dados à API; a API valida a sessão, aplica as regras de visibilidade e é a única que acede à base de dados. Quando o servidor não está disponível, a aplicação continua a funcionar com dados de exemplo.

A arquitetura, o modelo de dados e a documentação da API estão descritos em `04_Documentacao_Tecnica` e no relatório do projeto (`04_Documentacao_Tecnica/relatorio/`).

### ii. Funcionalidades principais

A app tem 12 ecrãs: os 11 desenhados no Figma e o ecrã de criar conta, que foi acrescentado durante a implementação.

**Conta e acesso.** O utilizador entra com email e palavra-passe, ou cria uma conta com nome, email, curso e palavra-passe. Se tentar entrar com um email que não tem conta, a app avisa e abre o ecrã de criar conta com o email já preenchido. Também é possível continuar como convidado, mas nesse caso só se vê o conteúdo público, sem criar, comentar ou seguir.

**Diário.** Os registos podem ser vistos de três formas: em lista, agrupados por dia, com a disciplina, as tags e os anexos de cada um; no mapa, agrupados pelo local onde foram feitos; e no calendário, com os dias em que houve registos, o total do mês e a divisão por disciplina. O diário mostra também quantos dias seguidos o estudante já registou.

**Novo registo e detalhe.** Cada registo tem título, texto, disciplina e tags, e pode incluir multimédia (foto, vídeo ou áudio) e localização. Pode ser associado a um projeto e tem uma visibilidade à escolha (privado, só amigos ou público). Ao abrir um registo vê-se o conteúdo completo, os comentários e o local no mapa. É possível comentar e denunciar conteúdo impróprio.

**Projetos.** Os projetos aparecem numa lista que pode ser filtrada. Ao abrir um projeto vê-se a linha temporal dos seus registos e é possível adicionar um novo registo já associado a ele.

**Comunidade.** Mostra as publicações dos colegas que se podem ver, quem se segue e o desafio da semana, que serve para incentivar novos registos.

**Perfil.** Mostra as estatísticas do estudante e as conquistas. Tem ainda as definições e as opções para terminar sessão e apagar a conta, o que apaga também todos os registos.

**Administração.** O administrador tem uma fila com as denúncias recebidas e pode ocultar o conteúdo, avisar o autor ou ignorar a denúncia. As ações ficam guardadas num registo, e é também aqui que se gere o desafio da semana.

**Estado na versão alfa.** Com a API ligada, o login, a criação de conta, o diário, a comunidade, os projetos, os novos registos e os comentários são lidos e gravados na base de dados. Ainda são simulados: a câmara, o microfone e o envio de ficheiros; o GPS e o mapa real; a exportação para PDF e os códigos QR; a pesquisa, as notificações e as mensagens na aplicação; e a moderação no ecrã de administração (que já existe na API).

### iii. Contributos relevantes

- **Privacidade por defeito, aplicada no servidor:** um registo sem visibilidade própria segue a do projeto e, sem projeto, fica privado. A API nunca devolve conteúdo que o utilizador não pode ver.
- **Partilha "só amigos" sem tabela de amizades:** a amizade resulta de duas pessoas se seguirem mutuamente.
- **Localização com privacidade:** o mapa e as pesquisas usam apenas uma posição aproximada (cerca de 1 km).
- **Base de dados preparada para o trabalho offline:** cada registo tem um identificador gerado no telemóvel, para não ficar duplicado quando é enviado mais tarde.
- **Moderação auditável:** cada decisão de um administrador fica registada, com o autor e a data.

## f. Reflexão

### i. Lições aprendidas

- Definir cedo o modelo de dados e o contrato da API facilitou ligar a aplicação ao servidor sem mudar os ecrãs.
- Separar a aplicação em MVC permitiu trocar os dados de exemplo pelos dados do servidor alterando sobretudo os controllers.
- As regras de privacidade têm de ser verificadas no servidor; esconder conteúdo apenas na interface não é suficiente.
- Ter testes automáticos (API, aplicação e pesquisas SQL) deu confiança para fazer alterações sem estragar o que já funcionava.
- Organizar o repositório e a documentação desde o início poupou tempo nas entregas.

### ii. Limitações

- Nesta fase, o servidor corre apenas localmente; ainda não está alojado nem usa HTTPS.
- As fotografias, os vídeos e os áudios ainda não são enviados para o servidor.
- O mapa é desenhado e a morada é fixa; a geocodificação com APIs públicas ainda não está feita.
- O ecrã de administração da aplicação ainda usa dados de exemplo, embora a moderação já exista na API.
- A aplicação ainda não foi testada com utilizadores reais.

### iii. Trabalho futuro

- Envio de fotografias, vídeo e áudio para o servidor.
- Mapa real com OpenStreetMap e moradas com Nominatim, usando a cache da API.
- Moderação, mensagens e grupos de estudo ligados à API.
- Exportação de registos e projetos para PDF e partilha por QR Code.
- Alojamento do servidor com HTTPS.
- Testes com, no mínimo, dois utilizadores reais e correções a partir dos resultados.
