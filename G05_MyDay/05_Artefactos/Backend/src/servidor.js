require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bd = require('./bd');

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/api/saude', async (req, res) => {
  const [linhas] = await bd.query('select count(*) as utilizadores from utilizador');
  res.json({ estado: 'ok', baseDeDados: 'ligada', utilizadores: linhas[0].utilizadores });
});

app.get('/api/disciplinas', async (req, res) => {
  const [linhas] = await bd.query('select id, nome, area from disciplina order by nome');
  res.json(linhas);
});

app.get('/api/tags', async (req, res) => {
  const [linhas] = await bd.query(
    `select t.id, t.nome, (select count(*) from registo_tag rt where rt.tag_id = t.id) as registos
     from tag t order by registos desc, t.nome`);
  res.json(linhas);
});

app.use('/api/auth', require('./rotas/auth'));
app.use('/api/registos', require('./rotas/registos'));
app.use('/api/projetos', require('./rotas/projetos'));
app.use('/api/comunidade', require('./rotas/comunidade'));
app.use('/api/utilizadores', require('./rotas/utilizadores'));
app.use('/api/admin', require('./rotas/admin'));

app.use((req, res) => res.status(404).json({ erro: 'Rota não encontrada.' }));

app.use((erro, req, res, next) => {
  console.error(erro);
  if (erro.sqlState === '45000') return res.status(400).json({ erro: erro.sqlMessage });
  if (erro.code === 'ECONNREFUSED' || erro.code === 'ER_ACCESS_DENIED_ERROR') {
    return res.status(503).json({ erro: 'Sem ligação à base de dados.' });
  }
  res.status(500).json({ erro: 'Ocorreu um erro no servidor.' });
});

const porta = Number(process.env.PORTA || 3000);
app.listen(porta, '0.0.0.0', () => console.log(`API do MyDay em http://localhost:${porta}/api`));
