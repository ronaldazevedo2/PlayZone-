import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

/// Exceção personalizada para erros da API de Autenticação
class ExcecaoAutenticacao implements Exception {
  final String mensagem;
  ExcecaoAutenticacao(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Modelo de dados retornado pela API no login
class RespostaAutenticacao {
  final String token;
  final String? refreshToken;
  final String? tipoToken;
  final int? expiraEm;

  RespostaAutenticacao({
    required this.token,
    this.refreshToken,
    this.tipoToken,
    this.expiraEm,
  });

  factory RespostaAutenticacao.doJson(Map<String, dynamic> json) {
    return RespostaAutenticacao(
      token: json['token'] ?? json['accessToken'] ?? json['jwt'] ?? '',
      refreshToken: json['refreshToken'],
      tipoToken: json['tokenType'] ?? 'Bearer',
      expiraEm: json['expiresIn'],
    );
  }

  /// Extrai os dados do usuário contidos no JWT Token
  Map<String, dynamic> decodificarToken() {
    if (token.isEmpty) return {};
    try {
      return JwtDecoder.decode(token);
    } catch (_) {
      return {};
    }
  }
}

/// Override do HttpOverrides para aceitar certificados SSL autoassinados em desenvolvimento local.
class ClassificacaoHttpPersonalizada extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

/// Serviço HTTP encarregado da integração com a API ASP.NET Core (Swagger)
class ServicoAutenticacaoApi {
  static final ServicoAutenticacaoApi _instancia = ServicoAutenticacaoApi._interno();
  factory ServicoAutenticacaoApi() => _instancia;

  ServicoAutenticacaoApi._interno() {
    // Permite conexões HTTPS com certificados locais de desenvolvimento
    HttpOverrides.global = ClassificacaoHttpPersonalizada();
  }

  /// URL Base Padrão da API (pode ser sobrescrita pelo usuário ou configurações)
  static String urlBaseGlobal = 'https://localhost:7200';

  String get _urlBaseApi => urlBaseGlobal;

  /// Atualiza a URL base da API dinamicamente
  static void configurarUrlBase(String novaUrl) {
    urlBaseGlobal = novaUrl.trim().replaceAll(RegExp(r'/$'), '');
  }

  /// Realiza o login enviando credenciais para a API.
  /// Tenta múltiplos endpoints comuns em APIs C# ASP.NET Core (JWT / Identity / Swagger).
  Future<RespostaAutenticacao> realizarLogin({
    required String email,
    required String senha,
  }) async {
    final endpointsParaTestar = [
      '/api/Auth/login',
      '/api/auth/login',
      '/api/Autenticacao/login',
      '/api/v1/auth/login',
      '/api/Account/login',
      '/api/login',
      '/login',
    ];

    final corpoRequisicao = jsonEncode({
      'email': email.trim(),
      'senha': senha,
      'password': senha, // Compatibilidade com OpenAPI em inglês
      'username': email.trim(),
    });

    final cabecalhos = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    String? ultimoErro;

    for (final endpoint in endpointsParaTestar) {
      try {
        final url = Uri.parse('$_urlBaseApi$endpoint');
        final resposta = await http.post(
          url,
          headers: cabecalhos,
          body: corpoRequisicao,
        ).timeout(const Duration(seconds: 5));

        if (resposta.statusCode == 200 || resposta.statusCode == 201) {
          final dados = jsonDecode(resposta.body);
          if (dados is Map<String, dynamic>) {
            return RespostaAutenticacao.doJson(dados);
          } else if (dados is String) {
            return RespostaAutenticacao(token: dados);
          }
        } else if (resposta.statusCode == 400 || resposta.statusCode == 401) {
          try {
            final erroJson = jsonDecode(resposta.body);
            ultimoErro = erroJson['message'] ?? erroJson['mensagem'] ?? erroJson['title'] ?? 'Credenciais inválidas';
          } catch (_) {
            ultimoErro = 'E-mail ou senha incorretos.';
          }
        }
      } catch (e) {
        ultimoErro = 'Falha ao conectar com o servidor ($_urlBaseApi): $e';
      }
    }

    throw ExcecaoAutenticacao(ultimoErro ?? 'Não foi possível autenticar junto à API.');
  }

  /// Cadastra um novo vigilante/usuário na API.
  Future<bool> cadastrarUsuario({
    required String nome,
    required String email,
    required String matricula,
    required String senha,
  }) async {
    final endpointsParaTestar = [
      '/api/Auth/register',
      '/api/auth/register',
      '/api/Autenticacao/registrar',
      '/api/v1/auth/register',
      '/api/Account/register',
      '/api/register',
      '/register',
    ];

    final corpoRequisicao = jsonEncode({
      'nome': nome.trim(),
      'name': nome.trim(),
      'email': email.trim(),
      'matricula': matricula.trim(),
      'senha': senha,
      'password': senha,
    });

    final cabecalhos = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    String? ultimoErro;

    for (final endpoint in endpointsParaTestar) {
      try {
        final url = Uri.parse('$_urlBaseApi$endpoint');
        final resposta = await http.post(
          url,
          headers: cabecalhos,
          body: corpoRequisicao,
        ).timeout(const Duration(seconds: 5));

        if (resposta.statusCode == 200 || resposta.statusCode == 201) {
          return true;
        } else if (resposta.statusCode == 400 || resposta.statusCode == 409) {
          try {
            final erroJson = jsonDecode(resposta.body);
            ultimoErro = erroJson['message'] ?? erroJson['mensagem'] ?? 'E-mail ou matrícula já cadastrado.';
          } catch (_) {
            ultimoErro = 'Erro ao realizar cadastro na API.';
          }
        }
      } catch (e) {
        ultimoErro = 'Erro ao conectar à API: $e';
      }
    }

    throw ExcecaoAutenticacao(ultimoErro ?? 'Falha ao registrar usuário na API.');
  }

  /// Recuperação de senha via API
  Future<bool> solicitarRecuperacaoSenha(String email) async {
    final endpointsParaTestar = [
      '/api/Auth/forgot-password',
      '/api/auth/recuperar-senha',
      '/api/Account/forgot-password',
    ];

    final corpoRequisicao = jsonEncode({
      'email': email.trim(),
    });

    for (final endpoint in endpointsParaTestar) {
      try {
        final url = Uri.parse('$_urlBaseApi$endpoint');
        final resposta = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: corpoRequisicao,
        ).timeout(const Duration(seconds: 5));

        if (resposta.statusCode == 200 || resposta.statusCode == 204) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }
}
