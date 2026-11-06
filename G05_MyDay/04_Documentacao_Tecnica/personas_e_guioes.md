# Personas e guiões — MyDay

## Personas

### Inês, 21 anos — a estudante que regista tudo
- 3.º ano de Química na FCUL. Passa muitas horas no laboratório e usa o telemóvel para tudo.
- **Objetivo:** guardar o que faz em cada experiência (fotos, valores, erros) para escrever os relatórios e preparar os exames.
- **Frustração:** tem fotos do quadro na galeria, valores num caderno e áudios no WhatsApp. Quando precisa, não encontra nada.
- **Como usa o MyDay:** cria um registo no fim de cada aula, organiza-os no projeto da síntese e partilha os resultados com o grupo do laboratório.
- **Nos dados de exemplo:** utilizadora 1 (`ines.carvalho02@gmail.com`).

### Tiago, 22 anos — o colega que compara resultados
- Química na FCUL, no mesmo turno da Inês.
- **Objetivo:** comparar os seus valores com os dos colegas e tirar dúvidas rapidamente.
- **Frustração:** não quer publicar os resultados para toda a gente. Prefere partilhar só com quem conhece.
- **Como usa o MyDay:** põe o projeto em "só amigos", comenta os registos da Inês e troca mensagens.
- **Nos dados de exemplo:** utilizador 2.

### Beatriz, 20 anos — a estudante reservada
- Engenharia Química no IST.
- **Objetivo:** ter um diário privado do trabalho de laboratório, sem pressão para partilhar.
- **Frustração:** as redes sociais expõem demasiado. Também não quer que a app guarde a sua localização.
- **Como usa o MyDay:** projeto privado e sem consentimentos de localização ou áudio. Segue colegas para aprender com eles.
- **Nos dados de exemplo:** utilizadora 3.

### Sofia — a administradora
- Responsável pela comunidade do MyDay.
- **Objetivo:** manter a comunidade segura e motivada.
- **Como usa o MyDay:** revê denúncias, destaca bons projetos e cria o desafio do mês.
- **Nos dados de exemplo:** utilizadora 5 (`sofia.rebelo@myday.pt`).

### Visitante (convidado)
- Ainda não tem conta. Quer perceber se a app vale a pena.
- Vê só o conteúdo público e não pode criar, comentar nem seguir.

## Guiões

### Guião 1 — Registar uma aula de laboratório (Inês)
1. A Inês abre a app e entra com o email e a palavra-passe.
2. No Diário vê os registos anteriores e quantos dias seguidos já fez.
3. Toca em **+**, escreve "Refluxo – 1.ª tentativa", escolhe a disciplina Química Orgânica I e o projeto "Síntese do acetato de isoamilo".
4. Junta duas fotografias, a tag "destilação" e a localização (já deu consentimento).
5. Deixa a visibilidade como está: segue a do projeto, que é público.
6. Guarda. O registo aparece no Diário, no Mapa (Faculdade de Ciências) e no Calendário.

**API:** `POST /auth/login` → `GET /registos` → `POST /registos`.

### Guião 2 — Comparar resultados com um amigo (Tiago)
1. O Tiago entra e abre a Comunidade, no separador **A seguir**.
2. Vê o registo da Inês sobre a destilação e lê o rendimento (54%).
3. Comenta: "54% está dentro do esperado…".
4. A Inês vê o comentário no detalhe do registo.

**API:** `GET /comunidade/feed?separador=a-seguir` → `GET /registos/2` → `POST /registos/2/comentarios`.

### Guião 3 — Conta nova a partir do login (visitante)
1. Um visitante escreve um email que ainda não tem conta e toca em Entrar.
2. A app mostra "Não existe nenhuma conta com este email" e abre logo o ecrã **Criar conta**, com o email já preenchido.
3. O visitante escreve o nome, o curso e a palavra-passe, e cria a conta.
4. Entra diretamente no Diário (vazio) e pode começar a registar.

**API:** `POST /auth/login` (404, `semConta`) → `POST /auth/registar`.

### Guião 4 — Moderar uma denúncia (Sofia)
1. A Beatriz denuncia um registo: "acho que as fotos são do relatório de outra pessoa".
2. A Sofia entra como administradora e vê a denúncia na fila de moderação.
3. Confirma que as fotos são originais e **rejeita** a denúncia.
4. A decisão fica no Registo de ações, com o motivo.

**API:** `POST /registos/4/denuncias` → `GET /admin/denuncias` → `PATCH /admin/denuncias/:id` (procedimento `sp_tratar_denuncia`) → `GET /admin/acoes`.

### Guião 5 — Privacidade
1. A Beatriz cria um projeto privado e não dá consentimento de localização.
2. Os registos dela não aparecem a ninguém, nem aos amigos.
3. Se quiser sair da app, apaga a conta no Perfil: os registos, ficheiros e comentários são apagados com ela.

**API:** `POST /projetos` (`visibilidade: privado`) → `PATCH /utilizadores/eu/consentimentos` → `DELETE /utilizadores/eu` (procedimento `sp_apagar_conta`).
