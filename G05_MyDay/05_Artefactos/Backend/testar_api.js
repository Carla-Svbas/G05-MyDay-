// Teste rápido da API: correr com o servidor ligado (npm start) e depois "npm run testar"
const BASE = process.env.API || 'http://localhost:3000/api';
let falhas = 0;

async function pedido(metodo, caminho, corpo, token) {
  const resposta = await fetch(BASE + caminho, {
    method: metodo,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: corpo ? JSON.stringify(corpo) : undefined,
  });
  const texto = await resposta.text();
  return { estado: resposta.status, dados: texto ? JSON.parse(texto) : null };
}

function verificar(nome, condicao, extra = '') {
  console.log(`${condicao ? 'OK ' : 'FALHOU'}  ${nome} ${extra}`);
  if (!condicao) falhas++;
}

(async () => {
  let r = await pedido('GET', '/saude');
  verificar('servidor e base de dados', r.estado === 200 && r.dados.utilizadores >= 5);

  r = await pedido('POST', '/auth/login', { email: 'naoexiste@escola.pt', password: 'x' });
  verificar('email sem conta dá 404 e semConta', r.estado === 404 && r.dados.semConta === true);

  r = await pedido('POST', '/auth/login', { email: 'ines.carvalho02@gmail.com', password: 'errada' });
  verificar('palavra-passe errada dá 401', r.estado === 401);

  r = await pedido('POST', '/auth/login', { email: 'ines.carvalho02@gmail.com', password: 'myday123' });
  verificar('login da Inês', r.estado === 200 && r.dados.token, r.dados.utilizador && r.dados.utilizador.nome);
  const ines = r.dados.token;

  r = await pedido('GET', '/registos', null, ines);
  verificar('diário da Inês tem 3 registos', r.estado === 200 && r.dados.length === 3);

  r = await pedido('GET', '/registos/3', null);
  verificar('convidado não vê registo só para amigos', r.estado === 404);

  r = await pedido('GET', '/registos/3', null, ines);
  verificar('a Inês vê o registo do Tiago (amigos)', r.estado === 200 && r.dados.titulo === 'Padronização do NaOH');

  r = await pedido('GET', '/registos/5', null, ines);
  verificar('a Inês não vê o registo privado da Beatriz', r.estado === 404);

  r = await pedido('GET', '/comunidade/feed?separador=a-seguir', null, ines);
  verificar('feed a seguir da Inês', r.estado === 200 && r.dados.length === 2);

  r = await pedido('GET', '/comunidade/feed');
  verificar('feed público para convidados', r.estado === 200 && r.dados.every((x) => x.visibilidade === 'publico'));

  r = await pedido('POST', '/registos', { titulo: '', texto: 'x' }, ines);
  verificar('registo sem título dá erro', r.estado === 400);

  r = await pedido('POST', '/registos', {
    titulo: 'Teste da API', texto: 'Criado pelo testar_api.js', projetoId: 1, disciplinaId: 1,
    tags: ['destilação', 'teste-api'], latitude: 38.75682, longitude: -9.15803, morada: 'Faculdade de Ciências',
  }, ines);
  verificar('criar registo com tags e local', r.estado === 201 && r.dados.tags.includes('teste-api'));
  const novo = r.dados.id;

  r = await pedido('POST', `/registos/${novo}/comentarios`, { texto: 'Comentário de teste' }, ines);
  verificar('comentar', r.estado === 201);

  r = await pedido('POST', `/registos/${novo}/favorito`, null, ines);
  verificar('favorito liga', r.estado === 200 && r.dados.favorito === true);

  r = await pedido('GET', `/registos/${novo}`, null, ines);
  verificar('detalhe com comentário e favorito', r.dados.listaComentarios.length === 1 && r.dados.favorito === true);

  r = await pedido('GET', '/projetos', null, ines);
  verificar('projetos da Inês', r.estado === 200 && r.dados.length === 1);

  r = await pedido('GET', '/projetos/1', null);
  verificar('projeto público com linha temporal', r.estado === 200 && r.dados.linhaTemporal.length >= 3);

  r = await pedido('GET', '/utilizadores/eu', null, ines);
  verificar('perfil com estatísticas e conquistas', r.estado === 200 && r.dados.conquistas.length === 3);

  r = await pedido('GET', '/disciplinas');
  verificar('disciplinas', r.estado === 200 && r.dados.length === 5);

  r = await pedido('GET', '/admin/denuncias', null, ines);
  verificar('estudante não entra na administração', r.estado === 403);

  r = await pedido('POST', `/registos/${novo}/denuncias`, { motivo: 'Teste de denúncia' }, ines);
  verificar('denunciar', r.estado === 201);
  const denuncia = r.dados.id;

  r = await pedido('POST', '/auth/login', { email: 'sofia.rebelo@myday.pt', password: 'myday123' });
  const sofia = r.dados.token;
  r = await pedido('GET', '/admin/denuncias', null, sofia);
  verificar('fila de moderação', r.estado === 200 && r.dados.some((d) => d.id === denuncia));

  r = await pedido('PATCH', `/admin/denuncias/${denuncia}`, { estado: 'rejeitada' }, sofia);
  verificar('rejeitar denúncia (stored procedure)', r.estado === 200);

  r = await pedido('GET', '/admin/acoes', null, sofia);
  verificar('ação ficou registada', r.dados[0].acao === 'rejeitar_denuncia');

  r = await pedido('DELETE', `/registos/${novo}`, null, ines);
  verificar('apagar o registo de teste', r.estado === 204);

  console.log(falhas ? `\n${falhas} teste(s) falharam.` : '\nTodos os testes passaram.');
  process.exit(falhas ? 1 : 0);
})().catch((erro) => {
  console.error('Não foi possível falar com a API:', erro.message);
  process.exit(1);
});
