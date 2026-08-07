/// Wrapper para respostas padronizadas da API backend (RespostaApi)
class RespostaApiWrapper<T> {
  final bool ok;
  final String mensagem;
  final T? dados;
  final List<String>? erros;

  const RespostaApiWrapper({
    required this.ok,
    required this.mensagem,
    this.dados,
    this.erros,
  });

  factory RespostaApiWrapper.deJson(
    Map<String, dynamic> json,
    T Function(dynamic)? conversorDados,
  ) {
    final bool ok = json['ok'] ?? false;
    final String mensagem = json['mensagem'] ?? '';

    T? dadosParsed;
    if (json['dados'] != null && conversorDados != null) {
      dadosParsed = conversorDados(json['dados']);
    }

    List<String>? errosParsed;
    if (json['erros'] != null && json['erros'] is List) {
      errosParsed = (json['erros'] as List).map((e) => e.toString()).toList();
    }

    return RespostaApiWrapper<T>(
      ok: ok,
      mensagem: mensagem,
      dados: dadosParsed,
      erros: errosParsed,
    );
  }
}

/// Modelo de Comando para efetuar Login na API (/api/Autenticacao/login)
class ComandoLogin {
  final String email;
  final String senha;
  final int perfil;

  const ComandoLogin({
    required this.email,
    required this.senha,
    this.perfil = 3,
  });

  Map<String, dynamic> paraJson() {
    return {
      'email': email,
      'senha': senha,
      'perfil': perfil,
    };
  }
}

/// Modelo de Comando para registrar novo Usuário na API (/api/Autenticacao/registrar)
class ComandoRegistrarUsuario {
  final String nomeCompleto;
  final String email;
  final String cpf;
  final String telefone;
  final String senha;

  const ComandoRegistrarUsuario({
    required this.nomeCompleto,
    required this.email,
    this.cpf = '',
    this.telefone = '',
    required this.senha,
  });

  Map<String, dynamic> paraJson() {
    return {
      'nomeCompleto': nomeCompleto,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'senha': senha,
    };
  }
}

/// Modelo da Resposta do Login contendo o Token JWT de Acesso
class RespostaLogin {
  final String accessToken;
  final String expiraEm;
  final String nomeCompleto;
  final String email;
  final String perfil;

  const RespostaLogin({
    required this.accessToken,
    required this.expiraEm,
    required this.nomeCompleto,
    required this.email,
    required this.perfil,
  });

  factory RespostaLogin.deJson(Map<String, dynamic> json) {
    return RespostaLogin(
      accessToken: json['accessToken'] ?? json['tokenAcesso'] ?? '',
      expiraEm: json['expiraEm']?.toString() ?? '',
      nomeCompleto: json['nomeCompleto'] ?? '',
      email: json['email'] ?? '',
      perfil: json['perfil'] ?? '',
    );
  }
}
