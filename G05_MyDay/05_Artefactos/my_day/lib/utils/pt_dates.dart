/// Pequenas funções para escrever datas em português,
/// sem precisar de bibliotecas externas.

const List<String> _weekdays = [
  'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo',
];

const List<String> _months = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

/// "Quarta, 28 de outubro"
String formatLongDate(DateTime date) {
  return '${_weekdays[date.weekday - 1]}, ${date.day} de ${_months[date.month - 1]}';
}

/// "Outubro 2026"
String formatMonthYear(DateTime date) {
  final month = _months[date.month - 1];
  return '${month[0].toUpperCase()}${month.substring(1)} ${date.year}';
}

/// "28 de outubro"
String formatDayMonth(DateTime date) {
  return '${date.day} de ${_months[date.month - 1]}';
}

/// "24 out"
String formatShortDayMonth(DateTime date) {
  return '${date.day} ${_months[date.month - 1].substring(0, 3)}';
}

/// "28 out 2026 · 10:42"
String formatShortDateTime(DateTime date) {
  final month = _months[date.month - 1].substring(0, 3);
  return '${date.day} $month ${date.year} · ${formatTime(date)}';
}

/// "agora", "5 min", "1 h", "3 d"
String formatTimeAgo(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return 'agora';
  if (difference.inHours < 1) return '${difference.inMinutes} min';
  if (difference.inDays < 1) return '${difference.inHours} h';
  return '${difference.inDays} d';
}

/// "10:42"
String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Só o dia (sem horas), para comparar datas.
DateTime onlyDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// Soma (ou subtrai) dias de calendário.
/// Não usamos Duration(days: 1) porque, no dia da mudança da hora,
/// um dia tem 23 ou 25 horas e o resultado ficaria errado.
DateTime addDays(DateTime date, int days) {
  return DateTime(date.year, date.month, date.day + days);
}

/// Número de dias de calendário entre duas datas (ignora as horas).
int daysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// "Hoje", "Ontem" ou "26 de outubro"
String formatRelativeDay(DateTime date) {
  final difference = daysBetween(date, DateTime.now());
  if (difference == 0) return 'Hoje';
  if (difference == 1) return 'Ontem';
  return formatDayMonth(date);
}
