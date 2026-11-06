-- MyDay - G05
-- Criação da base de dados (MySQL 8 ou superior)

drop database if exists myday;
create database myday character set utf8mb4 collate utf8mb4_0900_ai_ci;
use myday;

-- ---------------------------------------------------------------
-- Utilizadores e relações entre eles
-- ---------------------------------------------------------------

create table utilizador (
  id                  int unsigned not null auto_increment,
  email               varchar(255) not null,
  password_hash       varchar(255) not null,
  nome_utilizador     varchar(50)  not null,
  nome                varchar(120) not null,
  bio                 varchar(500) null,
  avatar_caminho      varchar(255) null,
  instituicao         varchar(150) null,
  curso               varchar(120) null,
  papel               enum('estudante', 'professor', 'administrador') not null default 'estudante',
  consent_localizacao boolean not null default false,
  consent_audio       boolean not null default false,
  consent_data        datetime null,
  criado_em           datetime not null default current_timestamp,
  primary key (id),
  unique key uk_utilizador_email (email),
  unique key uk_utilizador_nome (nome_utilizador)
);

create table seguimento (
  seguidor_id int unsigned not null,
  seguido_id  int unsigned not null,
  criado_em   datetime not null default current_timestamp,
  primary key (seguidor_id, seguido_id),
  key ix_seguimento_seguido (seguido_id),
  constraint fk_seguimento_seguidor foreign key (seguidor_id) references utilizador (id) on delete cascade,
  constraint fk_seguimento_seguido  foreign key (seguido_id)  references utilizador (id) on delete cascade
);

create table mensagem (
  id              int unsigned not null auto_increment,
  remetente_id    int unsigned not null,
  destinatario_id int unsigned not null,
  texto           text not null,
  lida_em         datetime null,
  criado_em       datetime not null default current_timestamp,
  primary key (id),
  key ix_mensagem_conversa (remetente_id, destinatario_id, criado_em),
  constraint fk_mensagem_remetente    foreign key (remetente_id)    references utilizador (id) on delete cascade,
  constraint fk_mensagem_destinatario foreign key (destinatario_id) references utilizador (id) on delete cascade
);

-- ---------------------------------------------------------------
-- Disciplinas e tags
-- ---------------------------------------------------------------

create table disciplina (
  id   int unsigned not null auto_increment,
  nome varchar(120) not null,
  area varchar(80)  null,
  primary key (id),
  unique key uk_disciplina_nome (nome)
);

create table tag (
  id   int unsigned not null auto_increment,
  nome varchar(50) not null,
  primary key (id),
  unique key uk_tag_nome (nome)
);

create table utilizador_segue_tag (
  utilizador_id int unsigned not null,
  tag_id        int unsigned not null,
  primary key (utilizador_id, tag_id),
  constraint fk_ust_utilizador foreign key (utilizador_id) references utilizador (id) on delete cascade,
  constraint fk_ust_tag        foreign key (tag_id)        references tag (id)        on delete cascade
);

create table utilizador_segue_disciplina (
  utilizador_id int unsigned not null,
  disciplina_id int unsigned not null,
  primary key (utilizador_id, disciplina_id),
  constraint fk_usd_utilizador foreign key (utilizador_id) references utilizador (id) on delete cascade,
  constraint fk_usd_disciplina foreign key (disciplina_id) references disciplina (id) on delete cascade
);

-- ---------------------------------------------------------------
-- Projetos, registos e ficheiros
-- ---------------------------------------------------------------

create table projeto (
  id            int unsigned not null auto_increment,
  utilizador_id int unsigned not null,
  disciplina_id int unsigned null,
  titulo        varchar(150) not null,
  descricao     text null,
  visibilidade  enum('privado', 'amigos', 'publico') not null default 'privado',
  criado_em     datetime not null default current_timestamp,
  primary key (id),
  key ix_projeto_utilizador (utilizador_id),
  constraint fk_projeto_utilizador foreign key (utilizador_id) references utilizador (id) on delete cascade,
  constraint fk_projeto_disciplina foreign key (disciplina_id) references disciplina (id) on delete set null
);

-- visibilidade null = o registo segue a visibilidade do projeto; sem projeto fica privado
create table registo (
  id              int unsigned not null auto_increment,
  uuid_cliente    char(36) not null,
  utilizador_id   int unsigned not null,
  projeto_id      int unsigned null,
  disciplina_id   int unsigned null,
  titulo          varchar(150) not null,
  texto           text null,
  visibilidade    enum('privado', 'amigos', 'publico') null,
  latitude        decimal(9, 6) null,
  longitude       decimal(9, 6) null,
  latitude_aprox  decimal(5, 2) null,
  longitude_aprox decimal(5, 2) null,
  morada          varchar(255) null,
  oculto          boolean not null default false,
  data_registo    datetime not null,
  criado_em       datetime not null default current_timestamp,
  primary key (id),
  unique key uk_registo_uuid (uuid_cliente),
  key ix_registo_utilizador_data (utilizador_id, data_registo),
  key ix_registo_local (latitude_aprox, longitude_aprox),
  constraint fk_registo_utilizador foreign key (utilizador_id) references utilizador (id) on delete cascade,
  constraint fk_registo_projeto    foreign key (projeto_id)    references projeto (id)    on delete set null,
  constraint fk_registo_disciplina foreign key (disciplina_id) references disciplina (id) on delete set null,
  constraint ck_registo_latitude   check (latitude is null or latitude between -90 and 90),
  constraint ck_registo_longitude  check (longitude is null or longitude between -180 and 180)
);

create table ficheiro (
  id            int unsigned not null auto_increment,
  registo_id    int unsigned not null,
  tipo          enum('foto', 'video', 'audio') not null,
  caminho       varchar(255) not null,
  mime_type     varchar(50) not null,
  tamanho_bytes bigint unsigned not null,
  duracao_seg   int unsigned null,
  ordem         tinyint unsigned not null default 0,
  criado_em     datetime not null default current_timestamp,
  primary key (id),
  key ix_ficheiro_registo (registo_id, ordem),
  constraint fk_ficheiro_registo foreign key (registo_id) references registo (id) on delete cascade
);

create table registo_tag (
  registo_id int unsigned not null,
  tag_id     int unsigned not null,
  primary key (registo_id, tag_id),
  key ix_registo_tag_tag (tag_id),
  constraint fk_rt_registo foreign key (registo_id) references registo (id) on delete cascade,
  constraint fk_rt_tag     foreign key (tag_id)     references tag (id)     on delete cascade
);

-- ---------------------------------------------------------------
-- Interação: comentários e favoritos (num registo ou num projeto)
-- ---------------------------------------------------------------

create table comentario (
  id            int unsigned not null auto_increment,
  utilizador_id int unsigned not null,
  registo_id    int unsigned null,
  projeto_id    int unsigned null,
  texto         varchar(1000) not null,
  criado_em     datetime not null default current_timestamp,
  primary key (id),
  key ix_comentario_registo (registo_id),
  key ix_comentario_projeto (projeto_id),
  constraint fk_comentario_utilizador foreign key (utilizador_id) references utilizador (id) on delete cascade,
  constraint fk_comentario_registo    foreign key (registo_id)    references registo (id)    on delete cascade,
  constraint fk_comentario_projeto    foreign key (projeto_id)    references projeto (id)    on delete cascade
);

create table favorito (
  id            int unsigned not null auto_increment,
  utilizador_id int unsigned not null,
  registo_id    int unsigned null,
  projeto_id    int unsigned null,
  criado_em     datetime not null default current_timestamp,
  primary key (id),
  unique key uk_favorito_registo (utilizador_id, registo_id),
  unique key uk_favorito_projeto (utilizador_id, projeto_id),
  constraint fk_favorito_utilizador foreign key (utilizador_id) references utilizador (id) on delete cascade,
  constraint fk_favorito_registo    foreign key (registo_id)    references registo (id)    on delete cascade,
  constraint fk_favorito_projeto    foreign key (projeto_id)    references projeto (id)    on delete cascade
);

-- ---------------------------------------------------------------
-- Grupos de estudo
-- ---------------------------------------------------------------

create table grupo (
  id         int unsigned not null auto_increment,
  criador_id int unsigned not null,
  nome       varchar(120) not null,
  descricao  varchar(500) null,
  criado_em  datetime not null default current_timestamp,
  primary key (id),
  constraint fk_grupo_criador foreign key (criador_id) references utilizador (id) on delete cascade
);

create table grupo_membro (
  grupo_id      int unsigned not null,
  utilizador_id int unsigned not null,
  papel         enum('dono', 'membro') not null default 'membro',
  entrou_em     datetime not null default current_timestamp,
  primary key (grupo_id, utilizador_id),
  constraint fk_gm_grupo      foreign key (grupo_id)      references grupo (id)      on delete cascade,
  constraint fk_gm_utilizador foreign key (utilizador_id) references utilizador (id) on delete cascade
);

create table grupo_registo (
  grupo_id       int unsigned not null,
  registo_id     int unsigned not null,
  partilhado_por int unsigned not null,
  partilhado_em  datetime not null default current_timestamp,
  primary key (grupo_id, registo_id),
  constraint fk_gr_grupo   foreign key (grupo_id)       references grupo (id)      on delete cascade,
  constraint fk_gr_registo foreign key (registo_id)     references registo (id)    on delete cascade,
  constraint fk_gr_autor   foreign key (partilhado_por) references utilizador (id) on delete cascade
);

-- ---------------------------------------------------------------
-- Hábito: lembretes e conquistas
-- ---------------------------------------------------------------

-- dias_semana: um bit por dia (1 = segunda ... 64 = domingo); 31 = dias úteis, 127 = todos
create table lembrete (
  id            int unsigned not null auto_increment,
  utilizador_id int unsigned not null,
  titulo        varchar(120) not null,
  hora          time not null,
  dias_semana   tinyint unsigned not null default 127,
  ativo         boolean not null default true,
  criado_em     datetime not null default current_timestamp,
  primary key (id),
  constraint fk_lembrete_utilizador foreign key (utilizador_id) references utilizador (id) on delete cascade,
  constraint ck_lembrete_dias check (dias_semana between 1 and 127)
);

create table conquista (
  id        int unsigned not null auto_increment,
  codigo    varchar(50)  not null,
  nome      varchar(80)  not null,
  descricao varchar(255) not null,
  primary key (id),
  unique key uk_conquista_codigo (codigo)
);

create table utilizador_conquista (
  utilizador_id int unsigned not null,
  conquista_id  int unsigned not null,
  obtida_em     datetime not null default current_timestamp,
  primary key (utilizador_id, conquista_id),
  constraint fk_uc_utilizador foreign key (utilizador_id) references utilizador (id) on delete cascade,
  constraint fk_uc_conquista  foreign key (conquista_id)  references conquista (id)  on delete cascade
);

-- ---------------------------------------------------------------
-- Moderação e administração
-- ---------------------------------------------------------------

create table denuncia (
  id             int unsigned not null auto_increment,
  denunciante_id int unsigned not null,
  registo_id     int unsigned null,
  projeto_id     int unsigned null,
  comentario_id  int unsigned null,
  motivo         varchar(500) not null,
  estado         enum('pendente', 'aceite', 'rejeitada') not null default 'pendente',
  tratada_por    int unsigned null,
  tratada_em     datetime null,
  criado_em      datetime not null default current_timestamp,
  primary key (id),
  key ix_denuncia_estado (estado, criado_em),
  constraint fk_denuncia_denunciante foreign key (denunciante_id) references utilizador (id) on delete cascade,
  constraint fk_denuncia_registo     foreign key (registo_id)     references registo (id)    on delete cascade,
  constraint fk_denuncia_projeto     foreign key (projeto_id)     references projeto (id)    on delete cascade,
  constraint fk_denuncia_comentario  foreign key (comentario_id)  references comentario (id) on delete cascade,
  constraint fk_denuncia_admin       foreign key (tratada_por)    references utilizador (id) on delete set null
);

create table desafio (
  id          int unsigned not null auto_increment,
  criado_por  int unsigned not null,
  titulo      varchar(150) not null,
  descricao   varchar(500) null,
  data_inicio date not null,
  data_fim    date not null,
  primary key (id),
  constraint fk_desafio_admin foreign key (criado_por) references utilizador (id) on delete cascade,
  constraint ck_desafio_datas check (data_fim >= data_inicio)
);

create table destaque (
  id            int unsigned not null auto_increment,
  registo_id    int unsigned null,
  projeto_id    int unsigned null,
  escolhido_por int unsigned not null,
  criado_em     datetime not null default current_timestamp,
  primary key (id),
  constraint fk_destaque_registo foreign key (registo_id)    references registo (id)    on delete cascade,
  constraint fk_destaque_projeto foreign key (projeto_id)    references projeto (id)    on delete cascade,
  constraint fk_destaque_admin   foreign key (escolhido_por) references utilizador (id) on delete cascade
);

create table registo_acoes (
  id            int unsigned not null auto_increment,
  admin_id      int unsigned not null,
  acao          varchar(50) not null,
  entidade_tipo varchar(30) not null,
  entidade_id   int unsigned not null,
  detalhes      json null,
  criado_em     datetime not null default current_timestamp,
  primary key (id),
  key ix_registo_acoes_data (criado_em),
  constraint fk_acoes_admin foreign key (admin_id) references utilizador (id) on delete cascade
);

-- respostas de serviços externos (ex.: geocodificação) guardadas por algum tempo
create table cache_api (
  chave     varchar(255) not null,
  resposta  json not null,
  expira_em datetime not null,
  criado_em datetime not null default current_timestamp,
  primary key (chave)
);

-- ---------------------------------------------------------------
-- Triggers: comentários, favoritos, denúncias e destaques apontam
-- para um alvo de cada vez (registo OU projeto)
-- ---------------------------------------------------------------

delimiter //

create trigger trg_comentario_alvo before insert on comentario for each row
begin
  if (new.registo_id is null) = (new.projeto_id is null) then
    signal sqlstate '45000' set message_text = 'O comentário tem de ser de um registo ou de um projeto.';
  end if;
end//

create trigger trg_favorito_alvo before insert on favorito for each row
begin
  if (new.registo_id is null) = (new.projeto_id is null) then
    signal sqlstate '45000' set message_text = 'O favorito tem de ser de um registo ou de um projeto.';
  end if;
end//

create trigger trg_destaque_alvo before insert on destaque for each row
begin
  if (new.registo_id is null) = (new.projeto_id is null) then
    signal sqlstate '45000' set message_text = 'O destaque tem de ser de um registo ou de um projeto.';
  end if;
end//

create trigger trg_denuncia_alvo before insert on denuncia for each row
begin
  if (new.registo_id is not null) + (new.projeto_id is not null) + (new.comentario_id is not null) <> 1 then
    signal sqlstate '45000' set message_text = 'A denúncia tem de ser de um registo, de um projeto ou de um comentário.';
  end if;
end//

create trigger trg_seguimento_proprio before insert on seguimento for each row
begin
  if new.seguidor_id = new.seguido_id then
    signal sqlstate '45000' set message_text = 'Um utilizador não se pode seguir a si próprio.';
  end if;
end//

delimiter ;

-- ---------------------------------------------------------------
-- Views
-- ---------------------------------------------------------------

-- visibilidade efetiva de cada registo (a do registo, senão a do projeto, senão privado)
create view v_registo as
select r.id, r.uuid_cliente, r.utilizador_id, u.nome as autor, u.nome_utilizador,
       r.projeto_id, p.titulo as projeto, r.disciplina_id, d.nome as disciplina,
       r.titulo, r.texto,
       coalesce(r.visibilidade, p.visibilidade, 'privado') as visibilidade,
       r.latitude_aprox, r.longitude_aprox, r.morada, r.oculto,
       r.data_registo, r.criado_em
from registo r
join utilizador u on u.id = r.utilizador_id
left join projeto p on p.id = r.projeto_id
left join disciplina d on d.id = r.disciplina_id;

-- o que qualquer pessoa (também convidados) pode ver
create view v_feed_publico as
select * from v_registo
where visibilidade = 'publico' and oculto = false;

-- números do perfil de cada utilizador
create view v_estatisticas_utilizador as
select u.id, u.nome, u.nome_utilizador,
       (select count(*) from registo r where r.utilizador_id = u.id) as registos,
       (select count(*) from projeto p where p.utilizador_id = u.id) as projetos,
       (select count(*) from seguimento s where s.seguido_id = u.id) as seguidores,
       (select count(*) from seguimento s where s.seguidor_id = u.id) as a_seguir,
       (select count(*) from utilizador_conquista c where c.utilizador_id = u.id) as conquistas
from utilizador u;

-- fila de moderação: denúncias por tratar, com o conteúdo denunciado
create view v_denuncias_pendentes as
select dn.id, dn.motivo, dn.criado_em, den.nome as denunciante,
       case
         when dn.registo_id is not null then 'registo'
         when dn.projeto_id is not null then 'projeto'
         else 'comentario'
       end as tipo,
       coalesce(r.titulo, p.titulo, c.texto) as conteudo
from denuncia dn
join utilizador den on den.id = dn.denunciante_id
left join registo r on r.id = dn.registo_id
left join projeto p on p.id = dn.projeto_id
left join comentario c on c.id = dn.comentario_id
where dn.estado = 'pendente';

-- ---------------------------------------------------------------
-- Stored procedures e funções
-- ---------------------------------------------------------------

delimiter //

-- dias seguidos com pelo menos um registo, a contar de hoje (ou de ontem)
create function fn_dias_seguidos(p_utilizador int unsigned) returns int
reads sql data
begin
  declare v_dia date;
  declare v_total int default 0;
  set v_dia = curdate();
  if not exists (select 1 from registo where utilizador_id = p_utilizador and date(data_registo) = v_dia) then
    set v_dia = v_dia - interval 1 day;
  end if;
  while exists (select 1 from registo where utilizador_id = p_utilizador and date(data_registo) = v_dia) do
    set v_total = v_total + 1;
    set v_dia = v_dia - interval 1 day;
  end while;
  return v_total;
end//

-- o administrador aceita ou rejeita uma denúncia; ao aceitar, o registo fica oculto
create procedure sp_tratar_denuncia(in p_denuncia int unsigned, in p_admin int unsigned, in p_estado varchar(10))
begin
  declare v_registo int unsigned;
  if p_estado not in ('aceite', 'rejeitada') then
    signal sqlstate '45000' set message_text = 'Estado inválido: use aceite ou rejeitada.';
  end if;
  if not exists (select 1 from utilizador where id = p_admin and papel = 'administrador') then
    signal sqlstate '45000' set message_text = 'Só um administrador pode tratar denúncias.';
  end if;

  start transaction;
  select registo_id into v_registo from denuncia where id = p_denuncia for update;
  update denuncia set estado = p_estado, tratada_por = p_admin, tratada_em = now() where id = p_denuncia;
  if p_estado = 'aceite' and v_registo is not null then
    update registo set oculto = true where id = v_registo;
  end if;
  insert into registo_acoes (admin_id, acao, entidade_tipo, entidade_id, detalhes)
  values (p_admin, concat(if(p_estado = 'aceite', 'aceitar', 'rejeitar'), '_denuncia'), 'denuncia', p_denuncia,
          json_object('registo_ocultado', p_estado = 'aceite' and v_registo is not null));
  commit;
end//

-- apagar a conta: as chaves estrangeiras com cascade apagam registos, ficheiros, comentários...
create procedure sp_apagar_conta(in p_utilizador int unsigned)
begin
  delete from utilizador where id = p_utilizador and papel <> 'administrador';
  select row_count() as apagados;
end//

delimiter ;
