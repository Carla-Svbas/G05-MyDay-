const diasSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

const meses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

String dataLonga(DateTime data) {
  return '${diasSemana[data.weekday - 1]}, ${data.day} de ${meses[data.month - 1]}';
}

String diaMes(DateTime data) {
  return '${data.day} de ${meses[data.month - 1]}';
}

String diaMesCurto(DateTime data) {
  return '${data.day} ${meses[data.month - 1].substring(0, 3)}';
}

String mesAno(DateTime data) {
  final mes = meses[data.month - 1];
  return '${mes[0].toUpperCase()}${mes.substring(1)} ${data.year}';
}

String hora(DateTime data) {
  final h = data.hour.toString().padLeft(2, '0');
  final m = data.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String dataCompleta(DateTime data) {
  return '${diaMesCurto(data)} ${data.year} · ${hora(data)}';
}

int diasDesde(DateTime data) {
  final hoje = DateTime.now();
  final a = DateTime.utc(data.year, data.month, data.day);
  final b = DateTime.utc(hoje.year, hoje.month, hoje.day);
  return b.difference(a).inDays;
}

String hojeOntem(DateTime data) {
  final dias = diasDesde(data);
  if (dias == 0) {
    return 'Hoje';
  }
  if (dias == 1) {
    return 'Ontem';
  }
  return diaMes(data);
}

String haQuantoTempo(DateTime data) {
  final diferenca = DateTime.now().difference(data);
  if (diferenca.inMinutes < 1) {
    return 'agora';
  }
  if (diferenca.inHours < 1) {
    return '${diferenca.inMinutes} min';
  }
  if (diferenca.inDays < 1) {
    return '${diferenca.inHours} h';
  }
  return '${diferenca.inDays} d';
}
