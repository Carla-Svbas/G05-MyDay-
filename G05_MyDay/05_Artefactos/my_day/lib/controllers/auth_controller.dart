import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/user.dart';

/// Controller da autenticação: decide quem está a usar a app.
/// As Views chamam estes métodos e mostram o resultado.
///
/// Estende ChangeNotifier (vem com o Flutter) para que, mais tarde,
/// outros ecrãs possam ser avisados quando o utilizador muda.
class AuthController extends ChangeNotifier {
  User? currentUser;
  bool isGuest = false;

  /// Mensagem do último erro, para a View mostrar ao utilizador.
  String? errorMessage;

  bool get isAdmin => currentUser?.isAdmin ?? false;

  /// Tenta entrar. Devolve true se o email e a palavra-passe estiverem certos.
  bool login(String email, String password) {
    email = email.trim().toLowerCase();

    if (!_isValidInput(email, password)) {
      return false;
    }

    for (final user in sampleUsers) {
      if (user.email == email && user.password == password) {
        currentUser = user;
        isGuest = false;
        errorMessage = null;
        notifyListeners();
        return true;
      }
    }

    errorMessage = 'Email ou palavra-passe incorretos.';
    return false;
  }

  /// Cria uma conta nova com o email e a palavra-passe do formulário
  /// e entra logo com ela.
  bool register(String email, String password) {
    email = email.trim().toLowerCase();

    if (!_isValidInput(email, password)) {
      return false;
    }
    if (password.length < 6) {
      errorMessage = 'A palavra-passe precisa de pelo menos 6 caracteres.';
      return false;
    }
    for (final user in sampleUsers) {
      if (user.email == email) {
        errorMessage = 'Já existe uma conta com este email.';
        return false;
      }
    }

    final newUser = User(
      name: email.split('@').first, // Nome provisório: a parte antes do @.
      email: email,
      password: password,
      course: '',
    );
    sampleUsers.add(newUser);

    currentUser = newUser;
    isGuest = false;
    errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Entra sem conta: só pode ver conteúdo público.
  void continueAsGuest() {
    currentUser = null;
    isGuest = true;
    errorMessage = null;
    notifyListeners();
  }

  /// Remove o utilizador da lista e termina a sessão.
  void deleteAccount(User user) {
    sampleUsers.remove(user);
    logout();
  }

  void logout() {
    currentUser = null;
    isGuest = false;
    notifyListeners();
  }

  /// Verificações comuns ao login e ao registo.
  bool _isValidInput(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Preenche o email e a palavra-passe.';
      return false;
    }
    if (!email.contains('@') || !email.contains('.')) {
      errorMessage = 'Escreve um email válido.';
      return false;
    }
    return true;
  }
}
