import '../models/acao_admin.dart';
import '../models/denuncia.dart';
import 'registos_demo.dart';

const desafioDemo = 'Explica um conceito em 60 segundos de vídeo';

const seguirDemo = {
  'rodrigo@escola.pt': ['cecilia@escola.pt', 'tiago@escola.pt'],
  'cecilia@escola.pt': ['rodrigo@escola.pt'],
  'tiago@escola.pt': ['rodrigo@escola.pt', 'ines@escola.pt'],
};

const denunciasDemo = [
  Denuncia(id: 1, registoId: 17, motivo: 'Conteúdo copiado', pessoas: 2),
  Denuncia(id: 2, registoId: 15, comentarioId: 99, motivo: 'Linguagem ofensiva'),
];

final acoesDemo = [
  AcaoAdmin(admin: 'lurdes.admin', descricao: 'publicou um desafio', data: diasAtras(0, 11, 20)),
  AcaoAdmin(
      admin: 'lurdes.admin', descricao: 'aprovou a tag #listasligadas', data: diasAtras(0, 10, 2)),
];
