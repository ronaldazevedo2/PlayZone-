import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

  static String _obterUrlPadrao() {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5200';
    }
    return 'http://localhost:5200';
  }

  static String _obterUrlAlternativa() {
    if (!kIsWeb && Platform.isAndroid) {
      return 'https://10.0.2.2:7200';
    }
    return 'https://localhost:7200';
  }

  static String? _urlBaseAtual;

  static String obterUrlBase() {
    _urlBaseAtual ??= _obterUrlPadrao();
    return _urlBaseAtual!;
  }

  static void alternarUrlBase() {
    final urlPadrao = _obterUrlPadrao();
    final urlAlternativa = _obterUrlAlternativa();
    _urlBaseAtual = (_urlBaseAtual == urlPadrao) ? urlAlternativa : urlPadrao;
  }

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
  /// Método auxiliar para tentar realizar requisições HTTP, alternando URLs se necessário
  static Future<http.Response> _fazerRequisicao(
    String metodo,
    String rota,
    Map<String, dynamic>? corpo,
  ) async {
    final url1 = Uri.parse('${obterUrlBase()}$rota');
    final corpoString = corpo != null ? jsonEncode(corpo) : null;
    final cabecalhos = await _obterCabecalhos();

    try {
      if (metodo == 'POST') {
        return await http
            .post(url1, headers: cabecalhos, body: corpoString)
            .timeout(const Duration(seconds: 4));
      } else {
        return await http
            .get(url1, headers: cabecalhos)
            .timeout(const Duration(seconds: 4));
      }
    } catch (_) {
      try {
        alternarUrlBase();
        final urlNova = Uri.parse('${obterUrlBase()}$rota');
        if (metodo == 'POST') {
          return await http
              .post(urlNova, headers: cabecalhos, body: corpoString)
              .timeout(const Duration(seconds: 4));
        } else {
          return await http
              .get(urlNova, headers: cabecalhos)
              .timeout(const Duration(seconds: 4));
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

  /// Solcita o envio do e-mail de recuperação de senha
  static Future<String> solicitarRecuperacaoSenha({
    required String email,
  }) async {
    try {
      final resposta = await _fazerRequisicao(
        'POST',
        '/api/Autenticacao/esqueceu-senha',
        {'email': email},
      );

      final dadosResposta = jsonDecode(resposta.body);
      if (resposta.statusCode == 200) {
        return dadosResposta['mensagem'] ??
            'Se existir uma conta vinculada a este e-mail, você receberá um link para redefinição de senha.';
      } else {
        final String msg =
            dadosResposta['mensagem'] ??
            'Se existir uma conta vinculada a este e-mail, você receberá um link para redefinição de senha.';
        return msg;
      }
    } catch (_) {
      // Retorna mensagem genérica de segurança em caso de falha de conexão/offline
      return 'Se existir uma conta vinculada a este e-mail, você receberá um link para redefinição de senha.';
    }
  }

  /// Redefine a senha do usuário com o token recebido
  static Future<void> redefinirSenha({
    required String token,
    required String novaSenha,
    required String confirmacaoSenha,
  }) async {
    final resposta = await _fazerRequisicao(
      'POST',
      '/api/Autenticacao/redefinir-senha',
      {
        'token': token,
        'novaSenha': novaSenha,
        'confirmacaoSenha': confirmacaoSenha,
      },
    );

    final dadosResposta = jsonDecode(resposta.body);

    if (resposta.statusCode == 200) {
      final bool ok = dadosResposta['ok'] ?? true;
      if (!ok) {
        throw Exception(
          dadosResposta['mensagem'] ?? 'Erro ao redefinir senha.',
        );
      }
    } else {
      final List<dynamic>? erros = dadosResposta['erros'];
      if (erros != null && erros.isNotEmpty) {
        throw Exception(erros.join('\n'));
      }
      final String msg =
          dadosResposta['mensagem'] ?? 'Token inválido ou expirado.';
      throw Exception(msg);
    }
  }

  /// Remove a sessão do usuário (Logout)
  static Future<void> encerrarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessao_usuario');
  }
}
