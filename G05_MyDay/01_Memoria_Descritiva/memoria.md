# Memória descritiva do MyDay

O MyDay é uma app para telemóvel que funciona como diário do percurso de estudante. Serve para registar o que se aprende, organizar esses registos em projetos e partilhar apenas o que se quiser.

## 1. Objetivo

A ideia principal é que o estudante tenha um único sítio onde guarda o que aprende todos os dias e onde consegue ver a sua evolução ao longo do curso.

Para isso, a app procura:

• Tornar rápido registar uma aprendizagem, seja em texto, foto, vídeo, áudio ou com a localização;

• Organizar os registos por disciplina e por projeto, para serem fáceis de encontrar mais tarde;

• Motivar o estudante a registar com regularidade, através dos dias seguidos, das conquistas e do desafio da semana;

• Dar controlo sobre a partilha, já que cada registo pode ser privado, só para amigos ou público;

• Criar uma comunidade de estudantes que aprendem uns com os outros, num espaço moderado.

## 2. Público-alvo

O público principal são estudantes do ensino superior, entre os 18 e os 25 anos, como os de Engenharia Informática do IADE. Usam o telemóvel todos os dias e querem um diário de estudo rápido, que os ajude a organizar o trabalho e a ver o progresso.

Os colegas de turma são um público secundário, interessado em ver o que os outros aprendem e comentar. Quem ainda não tem conta pode entrar como convidado e ver o conteúdo público antes de se registar.

Por fim, há os moderadores, que usam a área de administração para rever denúncias, ocultar conteúdo impróprio e acompanhar a atividade da plataforma.

## 3. Problema que resolve

Os estudantes aprendem muito todos os dias, mas grande parte disso perde-se. Os apontamentos ficam no caderno, as fotos do quadro na galeria, os áudios no WhatsApp e os links no browser, e mais tarde é difícil encontrar o que se aprendeu numa aula ou num projeto.

Além disso, não existe uma forma simples de ver quanto já se aprendeu, em que disciplinas e com que regularidade. Sem o hábito de registar, as coisas acabam esquecidas até à véspera do exame. Também é trabalhoso juntar, no fim de um projeto ou do curso, as provas do que se fez.

Nas redes sociais, partilhar é quase sempre tudo ou nada: ou se publica para todos ou não se publica.

O MyDay junta tudo num diário único e organizado, privado por defeito, que o estudante partilha quando e com quem quiser.

## 4. Funcionalidades

A app tem 12 ecrãs: os 11 desenhados no Figma e o ecrã de criar conta, que foi acrescentado durante a implementação.

### Conta e acesso

O utilizador entra com email e palavra-passe, ou cria uma conta com nome, email, curso e palavra-passe. Se tentar entrar com um email que não tem conta, a app avisa e abre o ecrã de criar conta com o email já preenchido. Também é possível continuar como convidado, mas nesse caso só se vê o conteúdo público, sem criar, comentar ou seguir.

### Diário

Os registos podem ser vistos de três formas:

• Lista: agrupados por dia, com a disciplina, as tags e os anexos de cada um.

• Mapa: agrupados pelo local onde foram feitos, como a biblioteca ou o laboratório.

• Calendário: com os dias em que houve registos, o total do mês e a divisão por disciplina.

O diário mostra também quantos dias seguidos o estudante já registou.

### Novo registo e detalhe

Cada registo tem título, texto, disciplina e tags, e pode incluir multimédia (foto, vídeo ou áudio) e localização. Pode ser associado a um projeto e tem uma visibilidade à escolha (privado, só amigos ou público).

Ao abrir um registo vê-se o conteúdo completo, os comentários e o local no mapa. É possível comentar e denunciar conteúdo impróprio.

### Projetos

Os projetos aparecem numa lista que pode ser filtrada. Ao abrir um projeto vê-se a linha temporal dos seus registos e é possível adicionar um novo registo já associado a ele.

### Comunidade

Mostra as publicações públicas dos colegas, que se podem seguir, e o desafio da semana, que serve para incentivar novos registos. Os grupos de estudo também aparecem neste ecrã, embora ainda não estejam funcionais.

### Perfil

Mostra as estatísticas do estudante e as conquistas (por exemplo, 7 dias seguidos, primeiro projeto ou 30 dias). Tem ainda as definições e as opções para terminar sessão e apagar a conta, o que apaga também todos os registos.

### Administração

O administrador tem uma fila com as denúncias recebidas e pode ocultar o conteúdo, avisar o autor ou ignorar a denúncia. As ações ficam guardadas num registo, e é também aqui que se gere o desafio da semana.

## 5. Notas sobre o protótipo

A app foi feita em Flutter, com a arquitetura MVC dada nas aulas (descrita em 04_Documentacao_Tecnica/arquitetura_mvc.md).

Por ser um protótipo, não há base de dados, API nem armazenamento. Os dados são fictícios, vêm de listas em lib/data e perdem-se quando se fecha a app. O login é validado contra utilizadores de exemplo, a câmara, o microfone e o GPS não são usados e o mapa é um fundo desenhado.

Algumas opções mostram apenas uma mensagem: exportar PDF e dados, os códigos para seguir colegas e partilhar projetos, a pesquisa, as notificações, as mensagens e os grupos de estudo. Estas ficam para uma próxima versão.