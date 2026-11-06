# Documentação REST — API do MyDay

API em Node.js com Express e MySQL (`05_Artefactos/Backend`). O endereço base é `http://localhost:3000/api`.

- Os pedidos e as respostas usam JSON.
- **Autenticação:** `POST /auth/login` devolve um `token` (JWT, válido 7 dias). Nas rotas protegidas, envia-se o cabeçalho `Authorization: Bearer <token>`.
- **Erros:** respondem sempre com `{ "erro": "mensagem em português" }` e o código HTTP adequado (400 dados inválidos, 401 sem sessão, 403 sem permissão, 404 não encontrado, 409 duplicado, 503 sem base de dados).
- **Legenda:** 🔓 público · 🔐 precisa de sessão · 🛡️ só administradores.

## Resumo

| Método | Rota | Acesso | Descrição |
|---|---|---|---|
| GET | `/saude` | 🔓 | Estado do servidor e da BD |
| POST | `/auth/login` | 🔓 | Entrar |
| POST | `/auth/registar` | 🔓 | Criar conta |
| GET | `/auth/eu` | 🔐 | Dados de quem tem a sessão |
| GET | `/registos` | 🔐 | O meu diário (filtros: `disciplina`, `projeto`, `pesquisa`) |
| GET | `/registos/:id` | 🔓/🔐 | Detalhe, se o utilizador o puder ver |
| POST | `/registos` | 🔐 | Novo registo |
| DELETE | `/registos/:id` | 🔐 | Apagar um registo meu |
| POST | `/registos/:id/comentarios` | 🔐 | Comentar |
| POST | `/registos/:id/favorito` | 🔐 | Ligar ou desligar o favorito |
| POST | `/registos/:id/denuncias` | 🔐 | Denunciar |
| GET | `/projetos` | 🔐 | Os meus projetos (filtro: `visibilidade`) |
| GET | `/projetos/:id` | 🔓/🔐 | Projeto e linha temporal |
| POST | `/projetos` | 🔐 | Criar projeto |
| PATCH | `/projetos/:id` | 🔐 | Mudar nome, descrição ou visibilidade |
| GET | `/comunidade/feed` | 🔓/🔐 | Feed (`separador=a-seguir`, `pesquisa`) |
| GET | `/comunidade/seguimentos` | 🔐 | Quem sigo e quem me segue |
| POST | `/comunidade/seguir/:id` | 🔐 | Seguir ou deixar de seguir |
| GET | `/comunidade/desafio` | 🔓 | Desafio em curso |
| GET | `/comunidade/grupos` | 🔐 | Os meus grupos de estudo |
| GET | `/utilizadores/:id` | 🔐 | Perfil (`eu` para o próprio) |
| PATCH | `/utilizadores/eu/consentimentos` | 🔐 | Consentimentos de localização e áudio |
| GET | `/utilizadores/eu/lembretes` | 🔐 | Os meus lembretes |
| DELETE | `/utilizadores/eu` | 🔐 | Apagar a conta |
| GET | `/disciplinas` | 🔓 | Lista de disciplinas |
| GET | `/tags` | 🔓 | Tags e número de registos |
| GET | `/admin/denuncias` | 🛡️ | Fila de moderação |
| PATCH | `/admin/denuncias/:id` | 🛡️ | Aceitar ou rejeitar |
| GET | `/admin/acoes` | 🛡️ | Registo de ações |
| GET | `/admin/estatisticas` | 🛡️ | Números gerais |

## Regras de visibilidade

Um registo pode ser visto:
- pelo autor;
- por qualquer pessoa, se for público;
- se for "só amigos", por quem segue o autor e é seguido por ele.

Um registo oculto pela moderação só é visto pelo autor e pelos administradores. A regra está em `src/visibilidade.js` e usa a view `v_registo`.

## Exemplos

### POST /auth/login

Pedido:
```json
{ "email": "ines.carvalho02@gmail.com", "password": "myday123" }
```
Resposta `200`:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "utilizador": {
    "id": 1, "email": "ines.carvalho02@gmail.com", "nomeUtilizador": "inesmcarvalho",
    "nome": "Inês Marques Carvalho", "curso": "Química", "papel": "estudante",
    "consentLocalizacao": 1, "consentAudio": 1, "criadoEm": "2026-09-21 18:42:10"
  }
}
```
Erros:
- `404 { "erro": "Não existe nenhuma conta com este email. Cria uma conta.", "semConta": true }`. A app usa o campo `semConta` para abrir logo o ecrã Criar conta.
- `401 { "erro": "Palavra-passe incorreta." }`

### POST /auth/registar

```json
{ "nome": "Nova Aluna", "email": "nova@escola.pt", "password": "123456", "curso": "Design" }
```
Responde `201` com o mesmo formato do login. Erros: `400` (nome, email ou palavra-passe inválidos) e `409` (email já usado).

### GET /registos

Resposta `200` (lista):
```json
[{
  "id": 1, "titulo": "Refluxo - 1.ª tentativa", "texto": "15 mL de álcool isoamílico...",
  "visibilidade": "publico", "disciplina": "Química Orgânica I", "disciplinaId": 1,
  "projeto": "Síntese do acetato de isoamilo", "projetoId": 1,
  "morada": "Faculdade de Ciências, Campo Grande, Lisboa", "latitude": 38.76, "longitude": -9.16,
  "dataRegisto": "2026-10-08 10:12:00", "oculto": false,
  "autorId": 1, "autor": "Inês Marques Carvalho", "autorNomeUtilizador": "inesmcarvalho",
  "tags": ["destilação"], "fotos": 2, "videos": 0, "audios": 0, "comentarios": 0, "favoritos": 1
}]
```
As coordenadas devolvidas são sempre as aproximadas (2 casas decimais).

### GET /registos/:id

Devolve os mesmos campos e ainda:
```json
{
  "ficheiros": [{ "id": 1, "tipo": "foto", "caminho": "uploads/registos/1/IMG_...jpg", "mimeType": "image/jpeg", "tamanhoBytes": 2843117, "duracaoSeg": null }],
  "listaComentarios": [{ "id": 1, "texto": "...", "criadoEm": "2026-10-08 18:20:44", "autorId": 2, "autor": "Tiago Ferreira Gomes" }],
  "favorito": true
}
```
Responde `404` se o registo não existir **ou** se o utilizador não o puder ver. Assim não se revela que um registo privado existe.

### POST /registos

```json
{
  "titulo": "TLC do produto", "texto": "Duas manchas...", "disciplinaId": 5, "projetoId": 1,
  "tags": ["cromatografia"], "visibilidade": "publico",
  "latitude": 38.75682, "longitude": -9.15803, "morada": "Faculdade de Ciências",
  "uuidCliente": "f1c5a9b3-...", "dataRegisto": "2026-10-27 11:05:00"
}
```
Só o `titulo` é obrigatório.
- Se `visibilidade` faltar, o registo segue a visibilidade do projeto.
- As tags novas são criadas automaticamente.
- Tudo corre numa transação.
- Ao primeiro registo, a conquista "Primeira experiência" é atribuída.

Responde `201` com o registo criado.

### POST /registos/:id/comentarios

`{ "texto": "Boa!" }` → `201 { "id": 5, "texto": "Boa!", "criadoEm": "...", "autorId": 1, "autor": "Inês Marques Carvalho" }`

### GET /comunidade/feed?separador=a-seguir&pesquisa=vinagre

Devolve uma lista de registos (o mesmo formato de `GET /registos`) de outras pessoas que o utilizador pode ver, no máximo 50. Sem sessão, devolve só registos públicos.

### GET /utilizadores/eu

```json
{
  "id": 1, "nome": "Inês Marques Carvalho", "registos": 3, "projetos": 1, "seguidores": 3, "aSeguir": 1,
  "diasSeguidos": 0, "euSigo": false,
  "conquistas": [{ "codigo": "primeiro_registo", "nome": "Primeira experiência", "obtidaEm": "2026-10-08 10:14:27", "desbloqueada": true }]
}
```

### PATCH /admin/denuncias/:id

`{ "estado": "aceite" }` ou `{ "estado": "rejeitada" }`.

Chama o procedimento `sp_tratar_denuncia`. Ao aceitar, o registo fica oculto, e a ação fica sempre em `registo_acoes`. Responde `404` se a denúncia já tiver sido tratada.

## Testes

`npm run testar`, com o servidor ligado, faz 25 verificações automáticas sobre estas rotas (`testar_api.js`).
