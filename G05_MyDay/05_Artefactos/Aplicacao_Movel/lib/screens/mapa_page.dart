import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../models/local.dart';
import '../models/registo.dart';
import '../widgets/cores.dart';
import '../widgets/formatar_data.dart';
import '../widgets/mapa_fundo.dart';
import 'registo_page.dart';

class MapaPage extends StatefulWidget {
  final Controladores app;
  final Widget seletor;
  final String? localInicial;
  final ValueChanged<String> verNoMapa;

  const MapaPage({
    super.key,
    required this.app,
    required this.seletor,
    required this.verNoMapa,
    this.localInicial,
  });

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  bool ultimos30Dias = true;
  String? localEscolhido;

  @override
  void initState() {
    super.initState();
    localEscolhido = widget.localInicial;
  }

  List<Registo> registosEm(Local local) {
    return widget.app.registos.registosNoLocal(widget.app.sessao.utilizador, local, ultimos30Dias);
  }

  Local? localAtivo(List<Local> locais) {
    for (final local in locais) {
      if (local.nome == localEscolhido) {
        return local;
      }
    }
    for (final registo in widget.app.registos.registosDe(widget.app.sessao.utilizador)) {
      final local = widget.app.registos.localDe(registo);
      if (local != null && locais.contains(local)) {
        return local;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final locais = widget.app.registos.locais.where((l) => registosEm(l).isNotEmpty).toList();
    final ativo = localAtivo(locais);
    return Stack(
      children: [
        const Positioned.fill(child: MapaFundo()),
        for (final local in locais) marcador(local, local == ativo),
        Positioned(top: 52, left: 16, right: 16, child: widget.seletor),
        Positioned(top: 110, left: 16, child: botaoPeriodo()),
        Positioned(top: 496, right: 16, child: botaoLocalizacao()),
        const Positioned(
          top: 544,
          left: 12,
          child: Text(
            '© contribuidores OpenStreetMap',
            style:
                TextStyle(fontSize: 10, color: Cores.textoCorpo, backgroundColor: Colors.white70),
          ),
        ),
        if (ativo != null) Positioned(left: 16, right: 16, bottom: 16, child: cartaoRegisto(ativo)),
      ],
    );
  }

  Widget marcador(Local local, bool ativo) {
    double tamanho = 40;
    if (ativo) {
      tamanho = 48;
    }
    return Positioned(
      left: local.x - tamanho / 2,
      top: local.y - tamanho / 2,
      child: GestureDetector(
        onTap: () => setState(() => localEscolhido = local.nome),
        child: Container(
          width: tamanho,
          height: tamanho,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ativo ? Cores.tinta : Cores.primaria,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Text(
            '${registosEm(local).length}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget botaoPeriodo() {
    var texto = 'Todos os registos';
    if (ultimos30Dias) {
      texto = 'Últimos 30 dias';
    }
    return GestureDetector(
      onTap: () => setState(() => ultimos30Dias = !ultimos30Dias),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Cores.branco, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: Cores.tinta),
            const SizedBox(width: 7),
            Text(texto,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Cores.tinta)),
          ],
        ),
      ),
    );
  }

  Widget botaoLocalizacao() {
    return GestureDetector(
      onTap: () {
        setState(() => localEscolhido = widget.app.registos.localAtual.nome);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Localização simulada: Biblioteca IADE.')),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: Cores.branco, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.my_location, size: 22, color: Cores.primaria),
      ),
    );
  }

  Widget cartaoRegisto(Local local) {
    final registos = registosEm(local);
    final registo = registos.first;
    var textoLocal = local.nome;
    if (registos.length > 1) {
      textoLocal = '${local.nome} · ${registos.length} registos';
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistoPage(
              app: widget.app,
              registoId: registo.id,
              verNoMapa: widget.verNoMapa,
            ),
          ),
        );
      },
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Cores.branco,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 16)],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
                  BoxDecoration(color: Cores.fotoVazia, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${hojeOntem(registo.data)} · ${hora(registo.data)}',
                    style: const TextStyle(fontSize: 12, color: Cores.texto2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    registo.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Cores.tinta),
                  ),
                  const SizedBox(height: 4),
                  Text(textoLocal, style: const TextStyle(fontSize: 13, color: Cores.texto2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
