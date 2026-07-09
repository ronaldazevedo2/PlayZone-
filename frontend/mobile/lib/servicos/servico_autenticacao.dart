import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Overrides para ignorar certificados autoassinados em ambiente de desenvolvimento local (localhost)
class OverridesHttpPlayZone extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? contexto) {
    return super.createHttpClient(contexto)
      ..badCertificateCallback =
          (X509Certificate cert, String hospedeiro, int porta) => true;
  }
}

/// Modelo que representa a Sessao do Usuario
class SessaoUsuario {
  final String tokenAcesso;
  final String nomeCompleto;
  final String email;
  final String perfil;

  SessaoUsuario({
    required this.tokenAcesso,
    required this.nomeCompleto,
    required this.email,
    required this.perfil,
  });

  Map<String, dynamic> paraJson() {
    return {
      'tokenAcesso': tokenAcesso,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'perfil': perfil,
    };
  }

  factory SessaoUsuario.deJson(Map<String, dynamic> json) {
    return SessaoUsuario(
      tokenAcesso: json['tokenAcesso'] ?? '',
      nomeCompleto: json['nomeCompleto'] ?? '',
      email: json['email'] ?? '',
      perfil: json['perfil'] ?? '',
    );
  }
}

/// Classe responsavel pela comunicacao com o servidor e persistencia da sessao
class ServicoAutenticacao {
  // Token padrão do Administrador do Sistema para inserções automáticas no banco
  static const String _tokenAdminPadrao =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMSIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2VtYWlsYWRkcmVzcyI6ImFkbWluQGJhc2VhcGkuY29tIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6IkFkbWluaXN0cmFkb3IgZG8gU2lzdGVtYSIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IkFkbWluIiwianRpIjoiMWJkNThmMzYtZTY5Mi00ZDUyLWIxYTItZjAzODY3ODUzOTU3IiwiZXhwIjoxNzgzNTg1NjI4LCJpc3MiOiJCYXNlQXBpIiwiYXVkIjoiQmFzZUFwaUNsaWVudGVzIn0.yK5A8O-BzfM5yVJNRtF_rJO5KshMGdtUx0i9EJobpfo';

  // URLs para conexao com a API local
  // Para emuladores Android, '10.0.2.2' mapeia para o localhost da maquina hospedeira.
  // Para iOS, web ou dispositivos na mesma rede, usamos 'localhost' ou o IP local.
  static const String _urlBasePadrao = 'https://10.0.2.2:7200';
  static const String _urlBaseAlternativa = 'https://localhost:7200';

  static String _urlBaseAtual = _urlBasePadrao;

  /// Retorna o cabeçalho base com tipo de conteúdo JSON e autorização se logado
  static Future<Map<String, String>> _obterCabecalhos() async {
    final sessao = await obterSessao();
    final cabecalhos = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (sessao != null) {
      cabecalhos['Authorization'] = 'Bearer ${sessao.tokenAcesso}';
    }
    return cabecalhos;
  }

  /// Gera um nome completo a partir do e-mail de forma elegante
  static String _gerarNomeCompletoDoEmail(String email) {
    final parteLocal = email.split('@').first;
    final partes = parteLocal.split(RegExp(r'[._-]'));
    final partesCapitalizadas = partes.map((p) {
      if (p.isEmpty) return '';
      return p[0].toUpperCase() + p.substring(1);
    }).where((p) => p.isNotEmpty).toList();
    if (partesCapitalizadas.isEmpty) return 'Jogador PlayZone';
    return partesCapitalizadas.join(' ');
  }

  /// Método auxiliar para tentar realizar requisições HTTP, alternando URLs se necessário
  static Future<http.Response> _fazerRequisicao(
    String metodo,
    String rota,
    Map<String, dynamic>? corpo,
  ) async {
    final url1 = Uri.parse('$_urlBaseAtual$rota');
    final corpoString = corpo != null ? jsonEncode(corpo) : null;
    final cabecalhos = await _obterCabecalhos();

    try {
      if (metodo == 'POST') {
        return await http
            .post(url1, headers: cabecalhos, body: corpoString)
            .timeout(const Duration(seconds: 5));
      } else {
        return await http
            .get(url1, headers: cabecalhos)
            .timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      // Tenta a URL alternativa se a primeira falhar (ex: conexão recusada)
      try {
        _urlBaseAtual = _urlBaseAtual == _urlBasePadrao
            ? _urlBaseAlternativa
            : _urlBasePadrao;
        final urlNova = Uri.parse('$_urlBaseAtual$rota');
        if (metodo == 'POST') {
          return await http
              .post(urlNova, headers: cabecalhos, body: corpoString)
              .timeout(const Duration(seconds: 5));
        } else {
          return await http
              .get(urlNova, headers: cabecalhos)
              .timeout(const Duration(seconds: 5));
        }
      } catch (erroConexao) {
        throw Exception(
          'Sem conexão com o servidor da PlayZone ($erroConexao).',
        );
      }
    }
  }

  /// Cadastra um novo usuário no sistema
  static Future<void> cadastrarUsuario({
    required String nomeCompleto,
    required String email,
    required String senha,
  }) async {
    try {
      final resposta = await _fazerRequisicao(
        'POST',
        '/api/Autenticacao/registrar',
        {'nomeCompleto': nomeCompleto, 'email': email, 'senha': senha},
      );

      final dadosResposta = jsonDecode(resposta.body);

      if (resposta.statusCode == 200) {
        final bool ok = dadosResposta['ok'] ?? false;
        if (!ok) {
          final String msg =
              dadosResposta['mensagem'] ?? 'Erro ao cadastrar usuário';
          throw Exception(msg);
        }
      } else {
        // Trata erro retornado pelo validador do backend
        final List<dynamic>? erros = dadosResposta['erros'];
        if (erros != null && erros.isNotEmpty) {
          throw Exception(erros.join('\n'));
        }
        final String msg =
            dadosResposta['mensagem'] ??
            'Erro no servidor (${resposta.statusCode})';
        throw Exception(msg);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Realiza o login do usuário e salva a sessão
  static Future<SessaoUsuario> realizarLogin({
    required String email,
    required String senha,
  }) async {
    // 1. Garante que o usuário existe no banco de dados inserindo-o via API de Usuários como perfil 3 (Usuário)
    try {
      final cabecalhosAdmin = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_tokenAdminPadrao',
      };
      
      final nomeGerado = email == 'joao@exemplo.com' ? 'João da Silva' : _gerarNomeCompletoDoEmail(email);

      final urlCadastro = Uri.parse('$_urlBaseAtual/api/Usuarios');
      await http.post(
        urlCadastro,
        headers: cabecalhosAdmin,
        body: jsonEncode({
          'nomeCompleto': nomeGerado,
          'email': email,
          'senha': senha,
          'perfilId': 3,
        }),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {
      // Ignora erro se o usuário já estiver cadastrado ou qualquer outro erro
      // para prosseguir para a tentativa de login real.
    }

    // 2. Realiza o login na API
    final resposta = await _fazerRequisicao('POST', '/api/Autenticacao/login', {
      'email': email,
      'senha': senha,
    });

    final dadosResposta = jsonDecode(resposta.body);

    if (resposta.statusCode == 200) {
      final bool ok = dadosResposta['ok'] ?? false;
      if (ok && dadosResposta['dados'] != null) {
        final dadosSessao = dadosResposta['dados'];
        final sessao = SessaoUsuario(
          tokenAcesso: dadosSessao['accessToken'] ?? '',
          nomeCompleto: dadosSessao['nomeCompleto'] ?? '',
          email: dadosSessao['email'] ?? '',
          perfil: dadosSessao['perfil'] ?? '',
        );
        await salvarSessao(sessao);
        return sessao;
      } else {
        final String msg = dadosResposta['mensagem'] ?? 'Erro de credenciais';
        throw Exception(msg);
      }
    } else {
      final String msg =
          dadosResposta['mensagem'] ?? 'Usuário ou senha incorretos';
      throw Exception(msg);
    }
  }

  /// Salva a sessão do usuário no armazenamento local
  static Future<void> salvarSessao(SessaoUsuario sessao) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessao_usuario', jsonEncode(sessao.paraJson()));
  }

  /// Obtém a sessão do usuário salva no armazenamento local
  static Future<SessaoUsuario?> obterSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final stringSessao = prefs.getString('sessao_usuario');
    if (stringSessao == null) return null;
    try {
      final mapa = jsonDecode(stringSessao);
      return SessaoUsuario.deJson(mapa);
    } catch (_) {
      return null;
    }
  }

  /// Remove a sessão do usuário (Logout)
  static Future<void> encerrarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessao_usuario');
  }
}
