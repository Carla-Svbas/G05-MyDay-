import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../models/conquista.dart';
import '../models/utilizador.dart';
import '../widgets/cores.dart';

class PerfilPage extends StatefulWidget {
  final Controladores app;

  const PerfilPage({super.key, required this.app});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  @override
  void initState() {
    super.initState();
    widget.app.perfil.addListener(atualizar);
    widget.app.comunidade.addListener(atualizar);
    widget.app.registos.addListener(atualizar);
  }

  void atualizar() => setState(() {});

  @override
  void dispose() {
    widget.app.perfil.removeListener(atualizar);
    widget.app.comunidade.removeListener(atualizar);
    widget.app.registos.removeListener(atualizar);
    super.dispose();
  }

  void irParaLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (rota) => false);
  }

  void terminarSessao() {
    widget.app.sessao.sair();
    irParaLogin();
  }

  void apagarConta(Utilizador utilizador) {
    showDialog(
      context: context,
      builder: (contextoJanela) {
        return AlertDialog(
          title: const Text('Apagar conta?'),
          content: const Text('A conta e todos os teus registos vão ser apagados.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contextoJanela), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.pop(contextoJanela);
                widget.app.perfil.apagarConta(utilizador);
                irParaLogin();
              },
              child: const Text('Apagar', style: TextStyle(color: Cores.perigo)),
            ),
          ],
        );
      },
    );
  }

  void escolherHora(Utilizador utilizador) async {
    final d = widget.app.perfil.definicoesDe(utilizador);
    final escolhida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: d.hora, minute: d.minuto),
    );
    if (escolhida != null) {
      widget.app.perfil.mudarHora(utilizador, escolhida.hour, escolhida.minute);
    }
  }

  void mostrarQrCode(Utilizador utilizador) {
    showDialog(
      context: context,
      builder: (contextoJanela) {
        return AlertDialog(
          title: Text(utilizador.nome, textAlign: TextAlign.center),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_2, size: 160),
              Text('Mostra este código a um colega para te seguir (simulação).',
                  textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(contextoJanela), child: const Text('Fechar')),
          ],
        );
      },
    );
  }

  void mostrarPessoas(Utilizador utilizador, bool seguidores) {
    showModalBottomSheet(
      context: context,
      builder: (contextoFolha) {
        return StatefulBuilder(
          builder: (contextoFolha, atualizarFolha) {
            var pessoas = widget.app.comunidade.aSeguir(utilizador);
            var titulo = 'A seguir';
            if (seguidores) {
              pessoas = widget.app.comunidade.seguidores(utilizador);
              titulo = 'Seguidores';
            }
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(titulo,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                  if (pessoas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text('Ainda não há ninguém aqui.'),
                    ),
                  for (final pessoa in pessoas)
                    ListTile(
                      title: Text(pessoa.nome),
                      subtitle: Text(pessoa.curso),
                      trailing: TextButton(
                        onPressed: () {
                          widget.app.comunidade.alternarSeguir(utilizador, pessoa.email);
                          atualizarFolha(() {});
                        },
                        child: Text(
                          widget.app.comunidade.segue(utilizador, pessoa.email)
                              ? 'Deixar de seguir'
                              : 'Seguir',
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final utilizador = widget.app.sessao.utilizador;
    if (utilizador == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Estás a usar o MyDay como convidado.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: terminarSessao, child: const Text('Entrar ou criar conta')),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      children: [
        cabecalho(utilizador),
        const SizedBox(height: 20),
        tituloSecao('Dados Pessoais'),
        const SizedBox(height: 9),
        dadosPessoais(utilizador),
        const SizedBox(height: 12),
        tituloSecao('Gerir Seguidores'),
        const SizedBox(height: 9),
        cartaoSeguidores(utilizador),
        const SizedBox(height: 12),
        tituloSecao('Configurações'),
        const SizedBox(height: 9),
        configuracoes(utilizador),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: terminarSessao,
            child: const Text(
              'Terminar sessão',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Cores.textoCorpo),
            ),
          ),
        ),
      ],
    );
  }

  Widget cabecalho(Utilizador utilizador) {
    final palavras = utilizador.nome.split(' ');
    var iniciais = palavras.first[0];
    if (palavras.length > 1) {
      iniciais = iniciais + palavras.last[0];
    }
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Cores.primaria, shape: BoxShape.circle),
          child: Text(
            iniciais.toUpperCase(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                utilizador.nome,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Cores.tinta),
              ),
              Text(utilizador.curso, style: const TextStyle(fontSize: 13, color: Cores.texto2)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => mostrarQrCode(utilizador),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Cores.branco,
              border: Border.all(color: Cores.linha),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2, size: 20, color: Cores.tinta),
          ),
        ),
      ],
    );
  }

  Widget tituloSecao(String texto) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: Cores.primaria),
        const SizedBox(width: 8),
        Text(texto,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Cores.tinta)),
      ],
    );
  }

  Widget cartao(Widget filho) {
    return Container(
      decoration: BoxDecoration(
        color: Cores.branco,
        border: Border.all(color: Cores.linha),
        borderRadius: BorderRadius.circular(16),
      ),
      child: filho,
    );
  }

  Widget etiquetaPequena(String texto) {
    return Text(
      texto.toUpperCase(),
      style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: Cores.texto2),
    );
  }

  Widget dadosPessoais(Utilizador utilizador) {
    final total = widget.app.registos.total(utilizador);
    return cartao(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                etiquetaPequena('Registos'),
                Text(
                  total.toString().padLeft(2, '0'),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: Cores.tinta),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Cores.linha),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                etiquetaPequena('Conquistas'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final conquista in widget.app.perfil.conquistas(utilizador))
                      cartaoConquista(conquista),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cartaoConquista(Conquista conquista) {
    var icone = Icons.local_fire_department_outlined;
    var fundoIcone = Cores.laranja;
    var corIcone = Cores.tinta;
    if (!conquista.desbloqueada) {
      icone = Icons.lock_outline;
      fundoIcone = Cores.cinzaClaro;
      corIcone = Cores.texto2;
    } else if (conquista.tipo == 'projeto') {
      icone = Icons.public;
      fundoIcone = Cores.primaria;
      corIcone = Colors.white;
    }
    return Container(
      width: 100,
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: const Color(0xFFE8EAEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: fundoIcone, shape: BoxShape.circle),
            child: Icon(icone, size: 18, color: corIcone),
          ),
          const SizedBox(height: 6),
          Text(
            conquista.titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: conquista.desbloqueada ? Cores.tinta : Cores.texto2,
            ),
          ),
        ],
      ),
    );
  }

  Widget cartaoSeguidores(Utilizador utilizador) {
    return cartao(
      Row(
        children: [
          Expanded(
            child: numeroSeguidores(
                'Seguidores',
                widget.app.comunidade.seguidores(utilizador).length,
                () => mostrarPessoas(utilizador, true)),
          ),
          Container(width: 1, height: 44, color: Cores.linha),
          Expanded(
            child: numeroSeguidores('A seguir', widget.app.comunidade.aSeguir(utilizador).length,
                () => mostrarPessoas(utilizador, false)),
          ),
        ],
      ),
    );
  }

  Widget numeroSeguidores(String texto, int numero, VoidCallback aoTocar) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: aoTocar,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            etiquetaPequena(texto),
            Text('$numero',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Cores.tinta)),
          ],
        ),
      ),
    );
  }

  Widget configuracoes(Utilizador utilizador) {
    final d = widget.app.perfil.definicoesDe(utilizador);
    return cartao(
      Column(
        children: [
          linhaInterruptor('Localização', 'Só quando adicionas a um registo', d.localizacao,
              (valor) => widget.app.perfil.mudarLocalizacao(utilizador, valor), null),
          linhaInterruptor('Microfone', 'Para gravar áudio', d.microfone,
              (valor) => widget.app.perfil.mudarMicrofone(utilizador, valor), null),
          linhaInterruptor(
              'Lembretes diários',
              widget.app.perfil.textoLembrete(utilizador),
              d.lembretes,
              (valor) => widget.app.perfil.mudarLembretes(utilizador, valor),
              () => escolherHora(utilizador)),
          ListTile(
            title:
                const Text('Exportar os meus dados', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.file_download_outlined, size: 18),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Os teus dados foram exportados (simulação).')),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Apagar conta',
              style: TextStyle(fontWeight: FontWeight.w600, color: Cores.perigo),
            ),
            onTap: () => apagarConta(utilizador),
          ),
        ],
      ),
    );
  }

  Widget linhaInterruptor(
    String titulo,
    String subtitulo,
    bool valor,
    ValueChanged<bool> aoMudar,
    VoidCallback? aoTocar,
  ) {
    return ListTile(
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitulo, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
          value: valor,
          onChanged: aoMudar,
          activeColor: Colors.white,
          activeTrackColor: Cores.primaria),
      onTap: aoTocar,
    );
  }
}
