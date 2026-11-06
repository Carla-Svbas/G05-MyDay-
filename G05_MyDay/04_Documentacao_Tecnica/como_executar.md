# Como executar o MyDay

O projeto tem três partes, todas dentro de `05_Artefactos/`:

| Pasta | O que é | Tecnologia |
|---|---|---|
| `Base_Dados/` | Criação da BD, dados de exemplo e pesquisas | MySQL 8 ou superior |
| `Backend/` | API REST usada pela app | Node.js 18+ com Express |
| `Aplicacao_Movel/` | A app | Flutter 3.13 / Dart 3.1 |

## 1. Base de dados (MySQL)

No terminal, a partir da pasta `05_Artefactos/Base_Dados` (pede a palavra-passe do root do MySQL):

```
mysql -u root -p < create.sql
mysql -u root -p < populate.sql
mysql -u root -p < criar_utilizador_app.sql
```

No PowerShell, o `<` não funciona. Em vez disso usem, por exemplo:

```
cmd /c "mysql -u root -p < create.sql"
```

- `create.sql` apaga e volta a criar a base de dados `myday` (24 tabelas, 4 views, 5 triggers, 1 função e 2 procedimentos).
- `populate.sql` insere os dados de exemplo.
- `criar_utilizador_app.sql` cria a conta `myday` do MySQL que a API usa.
- `queries.sql` tem 22 pesquisas para mostrar o que se pode tirar da BD.

O `create.sql` tem de ser corrido como root (ou por um utilizador com o privilégio SUPER), porque o MySQL pede esse privilégio para criar triggers e funções quando o registo binário está ligado.

## 2. API (Node.js + Express)

Na pasta `05_Artefactos/Backend`:

```
npm install
copy .env.example .env
npm start
```

A API fica em `http://localhost:3000/api`. Para confirmar, abram `http://localhost:3000/api/saude` no browser.

Com a API ligada, noutro terminal:

```
npm run testar
```

Isto corre 25 verificações (login, visibilidade, registos, comentários, projetos, perfil e administração).

A documentação de cada rota está em `documentacao_api.md`.

## 3. App (Flutter)

Na pasta `05_Artefactos/Aplicacao_Movel`:

```
flutter pub get
flutter run
flutter test
```

A app procura a API em `http://localhost:3000/api` (Chrome e Windows) ou em `http://10.0.2.2:3000/api` (emulador Android). Num telemóvel verdadeiro, indiquem o IP do computador:

```
flutter run --dart-define=API=http://192.168.1.50:3000/api
```

### Contas de teste

Com a API ligada (dados da BD, palavra-passe `myday123` em todas):

| Email | Papel |
|---|---|
| ines.carvalho02@gmail.com | Estudante (tem projetos, registos e segue o Tiago) |
| tiagofgomes@hotmail.com | Estudante |
| beatriz.antunes@tecnico.ulisboa.pt | Estudante |
| diogo.sequeira@campus.fct.unl.pt | Estudante |
| sofia.rebelo@myday.pt | Administradora |

Sem a API ligada, a app continua a funcionar com os dados de exemplo do protótipo (`rodrigo@escola.pt` / `123456`, `admin@escola.pt` / `admin123`).

**Nota (Windows):** se a pasta tiver um caminho muito longo, o Flutter pode falhar a compilar ("Directory listing failed"). Nesse caso copiem o projeto para uma pasta com caminho curto, por exemplo `C:\projetos\myday`.
