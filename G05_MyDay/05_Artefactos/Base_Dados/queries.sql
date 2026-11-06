-- MyDay - G05
-- Pesquisas mais relevantes sobre a base de dados

use myday;

-- 1. Diário de um estudante: os registos da Inês, do mais recente para o mais antigo,
--    com disciplina, projeto, tags e número de ficheiros de cada tipo
select r.id, r.data_registo, r.titulo, d.nome as disciplina, p.titulo as projeto,
       group_concat(distinct t.nome order by t.nome separator ', ') as tags,
       count(distinct case when f.tipo = 'foto'  then f.id end) as fotos,
       count(distinct case when f.tipo = 'video' then f.id end) as videos,
       count(distinct case when f.tipo = 'audio' then f.id end) as audios
from registo r
left join disciplina d on d.id = r.disciplina_id
left join projeto p on p.id = r.projeto_id
left join registo_tag rt on rt.registo_id = r.id
left join tag t on t.id = rt.tag_id
left join ficheiro f on f.registo_id = r.id
where r.utilizador_id = 1
group by r.id, r.data_registo, r.titulo, d.nome, p.titulo
order by r.data_registo desc;

-- 2. Feed "A seguir" da Inês: registos públicos ou só para amigos de quem ela segue
--    (amigos = seguem-se um ao outro), sem conteúdo oculto
select v.id, v.autor, v.titulo, v.visibilidade, v.data_registo
from v_registo v
join seguimento s on s.seguido_id = v.utilizador_id and s.seguidor_id = 1
where v.oculto = false
  and (v.visibilidade = 'publico'
       or (v.visibilidade = 'amigos'
           and exists (select 1 from seguimento s2
                       where s2.seguidor_id = v.utilizador_id and s2.seguido_id = 1)))
order by v.data_registo desc;

-- 3. Feed público (o que vê um convidado), usando a view
select autor, titulo, disciplina, projeto, data_registo
from v_feed_publico
order by data_registo desc;

-- 4. Pesquisa por texto: registos e projetos que falam de "acético",
--    no título ou no texto, com a origem do resultado
select 'registo' as origem, r.id, r.titulo, u.nome as autor
from registo r join utilizador u on u.id = r.utilizador_id
where r.titulo like '%acétic%' or r.texto like '%acétic%'
union all
select 'projeto', p.id, p.titulo, u.nome
from projeto p join utilizador u on u.id = p.utilizador_id
where p.titulo like '%acétic%' or p.descricao like '%acétic%';

-- 5. Mapa: quantos registos há em cada local aproximado, e de quantos estudantes
select latitude_aprox, longitude_aprox, any_value(morada) as local,
       count(*) as registos, count(distinct utilizador_id) as estudantes
from registo
where latitude_aprox is not null
group by latitude_aprox, longitude_aprox
order by registos desc;

-- 6. Calendário: registos por dia em outubro de 2026 para um estudante
select date(data_registo) as dia, count(*) as registos
from registo
where utilizador_id = 1 and data_registo >= '2026-10-01' and data_registo < '2026-11-01'
group by date(data_registo)
order by dia;

-- 7. Disciplinas mais trabalhadas: total de registos por disciplina e a percentagem de cada uma
select d.nome as disciplina, count(r.id) as registos,
       round(100 * count(r.id) / sum(count(r.id)) over (), 1) as percentagem
from disciplina d
left join registo r on r.disciplina_id = d.id
group by d.id, d.nome
order by registos desc;

-- 8. Perfil: estatísticas de cada utilizador (view) com os dias seguidos (função)
select nome, registos, projetos, seguidores, a_seguir, conquistas,
       fn_dias_seguidos(id) as dias_seguidos
from v_estatisticas_utilizador
order by registos desc;

-- 9. Linha temporal de um projeto: registos numerados por ordem e tempo desde o anterior
select p.titulo as projeto, r.titulo as registo, r.data_registo,
       row_number() over (partition by p.id order by r.data_registo) as passo,
       timestampdiff(minute,
                     lag(r.data_registo) over (partition by p.id order by r.data_registo),
                     r.data_registo) as minutos_desde_o_anterior
from projeto p
join registo r on r.projeto_id = p.id
order by p.id, r.data_registo;

-- 10. Projetos mais populares: comentários e favoritos, incluindo os dos seus registos
select p.titulo, u.nome as autor, p.visibilidade,
       (select count(*) from comentario c where c.projeto_id = p.id)
         + (select count(*) from comentario c join registo r on r.id = c.registo_id where r.projeto_id = p.id) as comentarios,
       (select count(*) from favorito f where f.projeto_id = p.id)
         + (select count(*) from favorito f join registo r on r.id = f.registo_id where r.projeto_id = p.id) as favoritos
from projeto p
join utilizador u on u.id = p.utilizador_id
order by comentarios + favoritos desc;

-- 11. Sugestões de quem seguir para a Beatriz (id 3): pessoas que seguem as mesmas tags
--     ou disciplinas, que ela ainda não segue
select u.nome, count(*) as interesses_em_comum
from (
  select ust2.utilizador_id as outro
  from utilizador_segue_tag ust1
  join utilizador_segue_tag ust2 on ust2.tag_id = ust1.tag_id and ust2.utilizador_id <> ust1.utilizador_id
  where ust1.utilizador_id = 3
  union all
  select usd2.utilizador_id
  from utilizador_segue_disciplina usd1
  join utilizador_segue_disciplina usd2 on usd2.disciplina_id = usd1.disciplina_id and usd2.utilizador_id <> usd1.utilizador_id
  where usd1.utilizador_id = 3
) comuns
join utilizador u on u.id = comuns.outro
where comuns.outro not in (select seguido_id from seguimento where seguidor_id = 3)
group by u.id, u.nome
order by interesses_em_comum desc;

-- 12. Tags mais usadas e quantas pessoas as seguem
select t.nome,
       (select count(*) from registo_tag rt where rt.tag_id = t.id) as registos,
       (select count(*) from utilizador_segue_tag ust where ust.tag_id = t.id) as seguidores
from tag t
order by registos desc, seguidores desc;

-- 13. Mensagens: conversa entre a Inês e o Tiago, com o tempo até ser lida
select rem.nome as de, dst.nome as para, m.texto, m.criado_em,
       timestampdiff(minute, m.criado_em, m.lida_em) as minutos_ate_ler
from mensagem m
join utilizador rem on rem.id = m.remetente_id
join utilizador dst on dst.id = m.destinatario_id
where (m.remetente_id, m.destinatario_id) in ((1, 2), (2, 1))
order by m.criado_em;

-- 14. Mensagens por ler de cada utilizador
select u.nome, count(m.id) as por_ler
from utilizador u
left join mensagem m on m.destinatario_id = u.id and m.lida_em is null
group by u.id, u.nome
having por_ler > 0;

-- 15. Lembretes ativos para hoje (dias_semana é um mapa de bits: 1 = segunda ... 64 = domingo)
select u.nome, l.titulo, l.hora
from lembrete l
join utilizador u on u.id = l.utilizador_id
where l.ativo = true
  and (l.dias_semana & (1 << weekday(curdate()))) > 0
order by l.hora;

-- 16. Conquistas: quem já tem e quem ainda não tem cada uma
select c.nome as conquista,
       group_concat(u.nome order by uc.obtida_em separator ', ') as obtida_por,
       (select count(*) from utilizador where papel = 'estudante') - count(uc.utilizador_id) as em_falta
from conquista c
left join utilizador_conquista uc on uc.conquista_id = c.id
left join utilizador u on u.id = uc.utilizador_id
group by c.id, c.nome;

-- 17. Grupos de estudo: membros e registos partilhados
select g.nome as grupo,
       (select count(*) from grupo_membro gm where gm.grupo_id = g.id) as membros,
       (select count(*) from grupo_registo gr where gr.grupo_id = g.id) as registos_partilhados,
       (select group_concat(r.titulo separator ' | ')
          from grupo_registo gr join registo r on r.id = gr.registo_id
         where gr.grupo_id = g.id) as titulos
from grupo g;

-- 18. Espaço ocupado pelos ficheiros de cada estudante (em MB) e duração total de áudio/vídeo
select u.nome,
       round(sum(f.tamanho_bytes) / 1024 / 1024, 2) as mb,
       coalesce(sum(f.duracao_seg), 0) as segundos_de_media
from ficheiro f
join registo r on r.id = f.registo_id
join utilizador u on u.id = r.utilizador_id
group by u.id, u.nome
order by mb desc;

-- 19. Administração: fila de moderação (view) e histórico de ações, lendo campos do JSON
select * from v_denuncias_pendentes;

select a.criado_em, u.nome as administrador, a.acao, a.entidade_tipo, a.entidade_id,
       a.detalhes ->> '$.motivo' as motivo,
       a.detalhes ->> '$.seccao' as seccao
from registo_acoes a
join utilizador u on u.id = a.admin_id
order by a.criado_em desc;

-- 20. Desafio ativo e quem já participou (pelo menos um registo durante o desafio)
select d.titulo, d.data_inicio, d.data_fim,
       count(distinct r.utilizador_id) as participantes
from desafio d
left join registo r on r.data_registo between d.data_inicio and d.data_fim + interval 1 day
where curdate() between d.data_inicio and d.data_fim
group by d.id, d.titulo, d.data_inicio, d.data_fim;

-- 21. Cache de serviços externos ainda válida
select chave, resposta ->> '$.display_name' as local, expira_em
from cache_api
where expira_em > now();

-- 22. Stored procedure: o administrador rejeita uma denúncia (fica no registo de ações)
-- call sp_tratar_denuncia(1, 5, 'rejeitada');
