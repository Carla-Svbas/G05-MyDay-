const bd = require('./bd');

// Colunas devolvidas para cada registo (a partir da view v_registo, alias v)
const COLUNAS_REGISTO = `
  v.id, v.titulo, v.texto, v.visibilidade, v.disciplina, v.disciplina_id as disciplinaId,
  v.projeto, v.projeto_id as projetoId, v.morada, v.latitude_aprox as latitude, v.longitude_aprox as longitude,
  v.data_registo as dataRegisto, v.oculto,
  v.utilizador_id as autorId, v.autor, v.nome_utilizador as autorNomeUtilizador,
  (select group_concat(t.nome order by t.nome separator ',') from registo_tag rt join tag t on t.id = rt.tag_id where rt.registo_id = v.id) as tags,
  (select count(*) from ficheiro f where f.registo_id = v.id and f.tipo = 'foto') as fotos,
  (select count(*) from ficheiro f where f.registo_id = v.id and f.tipo = 'video') as videos,
  (select count(*) from ficheiro f where f.registo_id = v.id and f.tipo = 'audio') as audios,
  (select count(*) from comentario c where c.registo_id = v.id) as comentarios,
  (select count(*) from favorito fv where fv.registo_id = v.id) as favoritos`;

// Condição SQL: o que o utilizador ? pode ver (dono, público, ou amigos que se seguem um ao outro)
const PODE_VER = `(
  v.utilizador_id = ?
  or (v.oculto = false and v.visibilidade = 'publico')
  or (v.oculto = false and v.visibilidade = 'amigos'
      and exists (select 1 from seguimento a where a.seguidor_id = ? and a.seguido_id = v.utilizador_id)
      and exists (select 1 from seguimento b where b.seguidor_id = v.utilizador_id and b.seguido_id = ?))
)`;

function paramsPodeVer(utilizador) {
  const id = utilizador ? utilizador.id : 0;
  return [id, id, id];
}

function arrumar(linha) {
  return {
    ...linha,
    oculto: Boolean(linha.oculto),
    latitude: linha.latitude === null ? null : Number(linha.latitude),
    longitude: linha.longitude === null ? null : Number(linha.longitude),
    tags: linha.tags ? linha.tags.split(',') : [],
  };
}

async function procurarRegisto(id, utilizador) {
  const admin = utilizador && utilizador.papel === 'administrador';
  const [linhas] = await bd.query(
    `select ${COLUNAS_REGISTO} from v_registo v where v.id = ? ${admin ? '' : `and ${PODE_VER}`}`,
    [id, ...(admin ? [] : paramsPodeVer(utilizador))],
  );
  return linhas.length ? arrumar(linhas[0]) : null;
}

module.exports = { COLUNAS_REGISTO, PODE_VER, paramsPodeVer, arrumar, procurarRegisto };
