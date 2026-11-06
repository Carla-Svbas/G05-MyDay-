# Navegação entre ecrãs

Todos os ecrãs desenhados no Figma foram implementados. Os números entre parênteses correspondem à numeração dos ecrãs no Figma.

## Entrar (01)

É o ecrã inicial da app, definido como rota '/' no main.dart. A partir daqui:

• O estudante entra e vai para o ecrã principal.

• O administrador entra e vai para a Administração (11).

• Quem tenta entrar com um email sem conta vê um erro e é levado para Criar conta, já com o email preenchido.

• Criar conta abre o formulário de registo. Depois de criar a conta, a app segue para o ecrã principal. A opção "Já tens conta? Entrar" volta atrás.

• Continuar como convidado abre o ecrã principal, mas só com o conteúdo público.

## Ecrã principal

Tem uma barra inferior com cinco opções.

O Diário mostra os registos em lista (02), mapa (07) ou calendário (08). Tocar num cartão, num marcador do mapa ou num dia do calendário abre o Registo (04). Dentro do registo, o botão "Ver no mapa" abre o mapa já centrado no local desse registo.

Em Projetos (05) aparecem todos os projetos. Ao abrir um projeto (06) é possível criar um novo registo já associado a ele ou abrir qualquer registo da linha temporal.

O botão + abre o Novo registo (03). Os convidados não podem criar registos e veem um aviso.

Na Comunidade (09), tocar num cartão abre o Registo, onde se pode comentar ou denunciar. O Desafio da semana leva ao Novo registo.

No Perfil (10), tanto Terminar sessão como Apagar conta voltam ao ecrã Entrar. Ao apagar a conta, os registos do utilizador também são apagados.

## Administração (11)

Quando um registo é denunciado (no menu do Registo), a denúncia entra na fila de moderação deste ecrã. O administrador pode ocultar o registo, avisar o autor ou ignorar a denúncia. Em qualquer dos casos a denúncia sai da fila e fica guardada no registo de ações.

O botão Sair volta ao ecrã Entrar.