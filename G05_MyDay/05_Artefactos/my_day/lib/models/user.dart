/// Model: representa um utilizador da aplicação.
/// Só guarda dados; não tem ecrã nem regras.
class User {
  final String name;
  final String email;
  final String password; // Só para demonstração: numa app real nunca se guarda em texto.
  final String course;
  final bool isAdmin;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.course,
    this.isAdmin = false,
  });
}
