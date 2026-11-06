# Dicionário de Dados — MyDay

Base de dados `myday` (MySQL, utf8mb4). Gerado a partir do `information_schema`, com a descrição de cada campo.

Legenda: **PK** chave primária · **FK** chave estrangeira · **UQ** valor único · **Nulo** = pode ficar vazio.

## Índice

- [utilizador](#utilizador) — Contas da app: estudantes, professores e administradores.
- [seguimento](#seguimento) — Quem segue quem. Duas pessoas que se seguem uma à outra são "amigos".
- [mensagem](#mensagem) — Mensagens privadas entre dois utilizadores.
- [disciplina](#disciplina) — Disciplinas usadas para classificar registos e projetos.
- [tag](#tag) — Etiquetas livres associadas aos registos.
- [utilizador_segue_tag](#utilizador_segue_tag) — Tags que cada utilizador acompanha.
- [utilizador_segue_disciplina](#utilizador_segue_disciplina) — Disciplinas que cada utilizador acompanha.
- [projeto](#projeto) — Conjunto de registos sobre o mesmo tema (o portefólio do estudante).
- [registo](#registo) — Cada entrada do diário: o que o estudante aprendeu num momento.
- [ficheiro](#ficheiro) — Fotografias, vídeos e áudios anexados a um registo.
- [registo_tag](#registo_tag) — Tags de cada registo (relação N:N).
- [comentario](#comentario) — Comentários num registo ou num projeto (um dos dois).
- [favorito](#favorito) — Registos ou projetos guardados por um utilizador.
- [grupo](#grupo) — Grupos de estudo.
- [grupo_membro](#grupo_membro) — Membros de cada grupo.
- [grupo_registo](#grupo_registo) — Registos partilhados num grupo.
- [lembrete](#lembrete) — Lembretes para criar o hábito de registar.
- [conquista](#conquista) — Conquistas que se podem desbloquear.
- [utilizador_conquista](#utilizador_conquista) — Conquistas obtidas por cada utilizador.
- [denuncia](#denuncia) — Denúncias de conteúdo impróprio (registo, projeto ou comentário).
- [desafio](#desafio) — Desafios propostos pela administração (ex.: desafio da semana).
- [destaque](#destaque) — Registos ou projetos destacados pela administração.
- [registo_acoes](#registo_acoes) — Histórico das ações dos administradores (auditoria).
- [cache_api](#cache_api) — Respostas de serviços externos guardadas por algum tempo (ex.: geocodificação).

## utilizador

Contas da app: estudantes, professores e administradores. Linhas nos dados de exemplo: 5.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador do utilizador |
| email | varchar(255) | UQ | não |  | Email de acesso (único) |
| password_hash | varchar(255) |  | não |  | Palavra-passe cifrada com bcrypt |
| nome_utilizador | varchar(50) | UQ | não |  | Nome público curto (único) |
| nome | varchar(120) |  | não |  | Nome completo |
| bio | varchar(500) |  | sim |  | Pequena descrição do perfil |
| avatar_caminho | varchar(255) |  | sim |  | Caminho da fotografia de perfil |
| instituicao | varchar(150) |  | sim |  | Escola ou faculdade |
| curso | varchar(120) |  | sim |  | Curso que frequenta |
| papel | enum('estudante','professor','administrador') |  | não | estudante | Tipo de conta: estudante, professor ou administrador |
| consent_localizacao | tinyint(1) |  | não | 0 | Autorizou guardar a localização |
| consent_audio | tinyint(1) |  | não | 0 | Autorizou gravar áudio |
| consent_data | datetime |  | sim |  | Quando deu (ou mudou) os consentimentos |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data de criação da conta |

## seguimento

Quem segue quem. Duas pessoas que se seguem uma à outra são "amigos". Linhas nos dados de exemplo: 5.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| seguidor_id | int unsigned | PK, FK → utilizador.id | não |  | Utilizador que segue |
| seguido_id | int unsigned | PK, FK → utilizador.id | não |  | Utilizador seguido |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Quando começou a seguir |

## mensagem

Mensagens privadas entre dois utilizadores. Linhas nos dados de exemplo: 3.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador da mensagem |
| remetente_id | int unsigned | FK → utilizador.id | não |  | Quem enviou |
| destinatario_id | int unsigned | FK → utilizador.id | não |  | Quem recebe |
| texto | text |  | não |  | Conteúdo |
| lida_em | datetime |  | sim |  | Quando foi lida (vazio = por ler) |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Quando foi enviada |

## disciplina

Disciplinas usadas para classificar registos e projetos. Linhas nos dados de exemplo: 5.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador da disciplina |
| nome | varchar(120) | UQ | não |  | Nome da disciplina (único) |
| area | varchar(80) |  | sim |  | Área científica |

## tag

Etiquetas livres associadas aos registos. Linhas nos dados de exemplo: 6.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador da tag |
| nome | varchar(50) | UQ | não |  | Texto da tag (único) |

## utilizador_segue_tag

Tags que cada utilizador acompanha. Linhas nos dados de exemplo: 6.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| utilizador_id | int unsigned | PK, FK → utilizador.id | não |  | Utilizador |
| tag_id | int unsigned | PK, FK → tag.id | não |  | Tag seguida |

## utilizador_segue_disciplina

Disciplinas que cada utilizador acompanha. Linhas nos dados de exemplo: 5.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| utilizador_id | int unsigned | PK, FK → utilizador.id | não |  | Utilizador |
| disciplina_id | int unsigned | PK, FK → disciplina.id | não |  | Disciplina seguida |

## projeto

Conjunto de registos sobre o mesmo tema (o portefólio do estudante). Linhas nos dados de exemplo: 4.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador do projeto |
| utilizador_id | int unsigned | FK → utilizador.id | não |  | Dono do projeto |
| disciplina_id | int unsigned | FK → disciplina.id | sim |  | Disciplina principal |
| titulo | varchar(150) |  | não |  | Nome do projeto |
| descricao | text |  | sim |  | Objetivo ou resumo |
| visibilidade | enum('privado','amigos','publico') |  | não | privado | privado, amigos ou publico |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data de criação |

## registo

Cada entrada do diário: o que o estudante aprendeu num momento. Linhas nos dados de exemplo: 7.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador do registo |
| uuid_cliente | char(36) | UQ | não |  | Identificador gerado no telemóvel, para sincronizar sem duplicar |
| utilizador_id | int unsigned | FK → utilizador.id | não |  | Autor |
| projeto_id | int unsigned | FK → projeto.id | sim |  | Projeto a que pertence (opcional) |
| disciplina_id | int unsigned | FK → disciplina.id | sim |  | Disciplina (opcional) |
| titulo | varchar(150) |  | não |  | Título |
| texto | text |  | sim |  | Descrição do que aprendeu |
| visibilidade | enum('privado','amigos','publico') |  | sim |  | Visibilidade própria; vazio = herda a do projeto, ou privado se não tiver projeto |
| latitude | decimal(9,6) |  | sim |  | Latitude exata (só com consentimento) |
| longitude | decimal(9,6) |  | sim |  | Longitude exata (só com consentimento) |
| latitude_aprox | decimal(5,2) |  | sim |  | Latitude arredondada a 2 casas (~1 km), usada no mapa e nas pesquisas |
| longitude_aprox | decimal(5,2) |  | sim |  | Longitude arredondada a 2 casas |
| morada | varchar(255) |  | sim |  | Nome do local |
| oculto | tinyint(1) |  | não | 0 | Ocultado pela moderação |
| data_registo | datetime |  | não |  | Quando aconteceu |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Quando foi gravado no servidor |

## ficheiro

Fotografias, vídeos e áudios anexados a um registo. Linhas nos dados de exemplo: 7.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador do ficheiro |
| registo_id | int unsigned | FK → registo.id | não |  | Registo a que pertence |
| tipo | enum('foto','video','audio') |  | não |  | foto, video ou audio |
| caminho | varchar(255) |  | não |  | Caminho no servidor |
| mime_type | varchar(50) |  | não |  | Tipo do ficheiro (ex.: image/jpeg) |
| tamanho_bytes | bigint unsigned |  | não |  | Tamanho em bytes |
| duracao_seg | int unsigned |  | sim |  | Duração em segundos (vídeo e áudio) |
| ordem | tinyint unsigned |  | não | 0 | Posição na galeria do registo |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data de envio |

## registo_tag

Tags de cada registo (relação N:N). Linhas nos dados de exemplo: 6.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| registo_id | int unsigned | PK, FK → registo.id | não |  | Registo |
| tag_id | int unsigned | PK, FK → tag.id | não |  | Tag |

## comentario

Comentários num registo ou num projeto (um dos dois). Linhas nos dados de exemplo: 4.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador do comentário |
| utilizador_id | int unsigned | FK → utilizador.id | não |  | Autor do comentário |
| registo_id | int unsigned | FK → registo.id | sim |  | Registo comentado |
| projeto_id | int unsigned | FK → projeto.id | sim |  | Projeto comentado |
| texto | varchar(1000) |  | não |  | Texto do comentário |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data |

## favorito

Registos ou projetos guardados por um utilizador. Linhas nos dados de exemplo: 3.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador |
| utilizador_id | int unsigned | FK → utilizador.id | não |  | Quem guardou |
| registo_id | int unsigned | FK → registo.id | sim |  | Registo guardado |
| projeto_id | int unsigned | FK → projeto.id | sim |  | Projeto guardado |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data |

## grupo

Grupos de estudo. Linhas nos dados de exemplo: 1.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador do grupo |
| criador_id | int unsigned | FK → utilizador.id | não |  | Quem criou |
| nome | varchar(120) |  | não |  | Nome do grupo |
| descricao | varchar(500) |  | sim |  | Descrição |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data de criação |

## grupo_membro

Membros de cada grupo. Linhas nos dados de exemplo: 2.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| grupo_id | int unsigned | PK, FK → grupo.id | não |  | Grupo |
| utilizador_id | int unsigned | PK, FK → utilizador.id | não |  | Membro |
| papel | enum('dono','membro') |  | não | membro | dono ou membro |
| entrou_em | datetime |  | não | CURRENT_TIMESTAMP | Data de entrada |

## grupo_registo

Registos partilhados num grupo. Linhas nos dados de exemplo: 2.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| grupo_id | int unsigned | PK, FK → grupo.id | não |  | Grupo |
| registo_id | int unsigned | PK, FK → registo.id | não |  | Registo partilhado |
| partilhado_por | int unsigned | FK → utilizador.id | não |  | Quem partilhou |
| partilhado_em | datetime |  | não | CURRENT_TIMESTAMP | Data |

## lembrete

Lembretes para criar o hábito de registar. Linhas nos dados de exemplo: 3.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador |
| utilizador_id | int unsigned | FK → utilizador.id | não |  | Dono do lembrete |
| titulo | varchar(120) |  | não |  | Texto do lembrete |
| hora | time |  | não |  | Hora do aviso |
| dias_semana | tinyint unsigned |  | não | 127 | Mapa de bits dos dias (1 = segunda ... 64 = domingo; 31 = dias úteis; 127 = todos) |
| ativo | tinyint(1) |  | não | 1 | Se está ligado |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data de criação |

## conquista

Conquistas que se podem desbloquear. Linhas nos dados de exemplo: 3.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador |
| codigo | varchar(50) | UQ | não |  | Código interno (único) |
| nome | varchar(80) |  | não |  | Nome mostrado |
| descricao | varchar(255) |  | não |  | Como se obtém |

## utilizador_conquista

Conquistas obtidas por cada utilizador. Linhas nos dados de exemplo: 4.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| utilizador_id | int unsigned | PK, FK → utilizador.id | não |  | Utilizador |
| conquista_id | int unsigned | PK, FK → conquista.id | não |  | Conquista |
| obtida_em | datetime |  | não | CURRENT_TIMESTAMP | Quando foi obtida |

## denuncia

Denúncias de conteúdo impróprio (registo, projeto ou comentário). Linhas nos dados de exemplo: 1.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador |
| denunciante_id | int unsigned | FK → utilizador.id | não |  | Quem denunciou |
| registo_id | int unsigned | FK → registo.id | sim |  | Registo denunciado |
| projeto_id | int unsigned | FK → projeto.id | sim |  | Projeto denunciado |
| comentario_id | int unsigned | FK → comentario.id | sim |  | Comentário denunciado |
| motivo | varchar(500) |  | não |  | Motivo indicado |
| estado | enum('pendente','aceite','rejeitada') |  | não | pendente | pendente, aceite ou rejeitada |
| tratada_por | int unsigned | FK → utilizador.id | sim |  | Administrador que tratou |
| tratada_em | datetime |  | sim |  | Quando foi tratada |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data da denúncia |

## desafio

Desafios propostos pela administração (ex.: desafio da semana). Linhas nos dados de exemplo: 1.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador |
| criado_por | int unsigned | FK → utilizador.id | não |  | Administrador |
| titulo | varchar(150) |  | não |  | Título |
| descricao | varchar(500) |  | sim |  | Descrição |
| data_inicio | date |  | não |  | Primeiro dia |
| data_fim | date |  | não |  | Último dia |

## destaque

Registos ou projetos destacados pela administração. Linhas nos dados de exemplo: 1.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador |
| registo_id | int unsigned | FK → registo.id | sim |  | Registo destacado |
| projeto_id | int unsigned | FK → projeto.id | sim |  | Projeto destacado |
| escolhido_por | int unsigned | FK → utilizador.id | não |  | Administrador |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data |

## registo_acoes

Histórico das ações dos administradores (auditoria). Linhas nos dados de exemplo: 2.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| id | int unsigned | PK | não | auto_increment | Identificador |
| admin_id | int unsigned | FK → utilizador.id | não |  | Administrador |
| acao | varchar(50) |  | não |  | Ação feita (ex.: rejeitar_denuncia) |
| entidade_tipo | varchar(30) |  | não |  | Tipo do alvo |
| entidade_id | int unsigned |  | não |  | Id do alvo |
| detalhes | json |  | sim |  | Informação extra em JSON |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data |

## cache_api

Respostas de serviços externos guardadas por algum tempo (ex.: geocodificação). Linhas nos dados de exemplo: 2.

| Campo | Tipo | Chave | Nulo | Por omissão | Descrição |
|---|---|---|---|---|---|
| chave | varchar(255) | PK | não |  | Pedido feito (ex.: geocode:38.76,-9.16) |
| resposta | json |  | não |  | Resposta em JSON |
| expira_em | datetime |  | não |  | Até quando é válida |
| criado_em | datetime |  | não | CURRENT_TIMESTAMP | Data |
