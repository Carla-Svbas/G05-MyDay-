class Utilizador {
  final String nome;
  final String email;
  final String palavraPasse;
  final String curso;
  final bool admin;

  const Utilizador({
    required this.nome,
    required this.email,
    required this.palavraPasse,
    required this.curso,
    this.admin = false,
  });

  String get primeiroNome => nome.split(' ').first;
}
