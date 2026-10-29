/// Model: um local onde se podem fazer registos.
/// Como o protótipo não usa um mapa real, a posição é guardada em
/// pixels no mapa desenhado (ecrã de 390 de largura, como no Figma).
class MapPlace {
  final String name;
  final String address;
  final double x; // centro do marcador, a contar da esquerda
  final double y; // centro do marcador, a contar do topo

  const MapPlace({
    required this.name,
    required this.address,
    required this.x,
    required this.y,
  });
}
