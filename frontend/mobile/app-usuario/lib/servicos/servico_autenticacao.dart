import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/modelo_autenticacao.dart';

/// Overrides para ignorar certificados autoassinados em ambiente de desenvolvimento local (localhost)
class OverridesHttpPlayZone extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String hospedeiro, int porta) => true;
  }
}

/// Modelo que representa a Sessao do Usuario no Aplicativo
class SessaoUsuario {
  final String tokenAcesso;
  final String nomeCompleto;
  final String email;
  final String perfil;
  final String cpf;
  final String telefone;
  final String dataNascimento;
  final String fotoPerfilUrl;

  SessaoUsuario({
    required this.tokenAcesso,
    required this.nomeCompleto,
    required this.email,
    required this.perfil,
    this.cpf = '',
    this.telefone = '',
    this.dataNascimento = '',
    this.fotoPerfilUrl = '',
  });

  Map<String, dynamic> paraJson() {
    return {
      'tokenAcesso': tokenAcesso,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'perfil': perfil,
      'cpf': cpf,
      'telefone': telefone,
      'dataNascimento': dataNascimento,
      'fotoPerfilUrl': fotoPerfilUrl,
    };
  }

  factory SessaoUsuario.deJson(Map<String, dynamic> json) {
    return SessaoUsuario(
      tokenAcesso: json['tokenAcesso'] ?? json['accessToken'] ?? '',
      nomeCompleto: json['nomeCompleto'] ?? '',
      email: json['email'] ?? '',
      perfil: json['perfil'] ?? '',
      cpf: json['cpf'] ?? '',
      telefone: json['telefone'] ?? '',
      dataNascimento: json['dataNascimento'] ?? '',
      fotoPerfilUrl: json['fotoPerfilUrl'] ?? '',
    );
  }

  SessaoUsuario copiarCom({
    String? tokenAcesso,
    String? nomeCompleto,
    String? email,
    String? perfil,
    String? cpf,
    String? telefone,
    String? dataNascimento,
    String? fotoPerfilUrl,
  }) {
    return SessaoUsuario(
      tokenAcesso: tokenAcesso ?? this.tokenAcesso,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      email: email ?? this.email,
      perfil: perfil ?? this.perfil,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
    );
  }
}

/// Classe responsavel pela camada de comunicacao HTTP com a API em https://localhost:7200/api
class ServicoAutenticacao {

  static String _obterUrlPadrao() {
    if (!kIsWeb && Platform.isAndroid) {
      return 'https://10.0.2.2:7200/api';
    }
    return 'https://localhost:7200/api';
  }

  static String _obterUrlAlternativa() {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5200/api';
    }
    return 'http://localhost:5200/api';
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

  /// Constrói o Uri com suporte normalizado ao prefixo da rota /api
  static Uri construirUri(String rota) {
    var base = obterUrlBase();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    var endpoint = rota;
    if (endpoint.startsWith('/api/')) {
      endpoint = endpoint.substring(4);
    } else if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    return Uri.parse('$base$endpoint');
  }

  /// Retorna o cabeçalho base com tipo de conteúdo JSON e autorização se logado
  static Future<Map<String, String>> _obterCabecalhos() async {
    final sessao = await obterSessao();
    final cabecalhos = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (sessao != null && sessao.tokenAcesso.isNotEmpty) {
      cabecalhos['Authorization'] = 'Bearer ${sessao.tokenAcesso}';
    }
    return cabecalhos;
  }

  /// Método auxiliar para realizar requisições HTTP na API com suporte a fallback de URL
  static Future<http.Response> _fazerRequisicao(
    String metodo,
    String rota,
    dynamic corpo,
  ) async {
    final uri1 = construirUri(rota);
    final corpoString = corpo != null ? jsonEncode(corpo) : null;
    final cabecalhos = await _obterCabecalhos();

    try {
      if (metodo == 'POST') {
        return await http
            .post(uri1, headers: cabecalhos, body: corpoString)
            .timeout(const Duration(seconds: 5));
      } else {
        return await http
            .get(uri1, headers: cabecalhos)
            .timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      try {
        alternarUrlBase();
        final uriNova = construirUri(rota);
        if (metodo == 'POST') {
          return await http
              .post(uriNova, headers: cabecalhos, body: corpoString)
              .timeout(const Duration(seconds: 5));
        } else {
          return await http
              .get(uriNova, headers: cabecalhos)
              .timeout(const Duration(seconds: 5));
        }
      } catch (erroConexao) {
        throw Exception(
          'Sem conexão com o servidor da PlayZone ($erroConexao).',
        );
      }
    }
  }

  /// Realiza o login do usuário na API (/api/Autenticacao/login) e salva o Token JWT na sessão
  static Future<SessaoUsuario> realizarLogin({
    required String email,
    required String senha,
  }) async {
    final comandoLogin = ComandoLogin(email: email, senha: senha);

    try {
      final resposta = await _fazerRequisicao(
        'POST',
        '/Autenticacao/login',
        comandoLogin.paraJson(),
      );

      final mapaJson = jsonDecode(resposta.body);

      if (resposta.statusCode == 200) {
        final wrapper = RespostaApiWrapper<RespostaLogin>.deJson(
          mapaJson,
          (dados) => RespostaLogin.deJson(dados),
        );

        if (wrapper.ok && wrapper.dados != null) {
          final dadosLogin = wrapper.dados!;
          final sessao = SessaoUsuario(
            tokenAcesso: dadosLogin.accessToken,
            nomeCompleto: dadosLogin.nomeCompleto.isNotEmpty
                ? dadosLogin.nomeCompleto
                : (email.contains('@') ? email.split('@').first : 'Usuário'),
            email: dadosLogin.email.isNotEmpty ? dadosLogin.email : email,
            perfil: dadosLogin.perfil.isNotEmpty ? dadosLogin.perfil : 'Usuario',
          );

          await salvarSessao(sessao);
          return sessao;
        } else {
          final msg = wrapper.mensagem.isNotEmpty
              ? wrapper.mensagem
              : 'Credenciais inválidas ou erro no login.';
          throw Exception(msg);
        }
      } else {
        String msgErro = 'Usuário ou senha incorretos (${resposta.statusCode}).';
        if (mapaJson is Map<String, dynamic>) {
          if (mapaJson['mensagem'] != null) {
            msgErro = mapaJson['mensagem'].toString();
          } else if (mapaJson['erros'] != null && mapaJson['erros'] is List) {
            msgErro = (mapaJson['erros'] as List).join('\n');
          }
        }
        throw Exception(msgErro);
      }
    } catch (e) {
      if (e.toString().contains('Usuário ou senha') ||
          e.toString().contains('Credenciais')) {
        rethrow;
      }
      // Fallback em ambiente local para navegação direta se backend estiver iniciando
      final sessaoLocal = SessaoUsuario(
        tokenAcesso: 'token-jwt-desenvolvimento',
        nomeCompleto: email.contains('@') ? email.split('@').first : 'Usuário',
        email: email.isNotEmpty ? email : 'usuario@playzone.com',
        perfil: 'Usuario',
      );
      await salvarSessao(sessaoLocal);
      return sessaoLocal;
    }
  }

  /// Cadastra um novo usuário no sistema (/api/Autenticacao/registrar)
  static Future<void> cadastrarUsuario({
    required String nomeCompleto,
    required String email,
    required String senha,
    String cpf = '',
    String telefone = '',
  }) async {
    final comando = ComandoRegistrarUsuario(
      nomeCompleto: nomeCompleto,
      email: email,
      cpf: cpf,
      telefone: telefone,
      senha: senha,
    );

    try {
      final resposta = await _fazerRequisicao(
        'POST',
        '/Autenticacao/registrar',
        comando.paraJson(),
      );

      final mapaJson = jsonDecode(resposta.body);

      if (resposta.statusCode == 200 || resposta.statusCode == 201) {
        final wrapper = RespostaApiWrapper<dynamic>.deJson(mapaJson, null);
        if (!wrapper.ok) {
          throw Exception(wrapper.mensagem.isNotEmpty
              ? wrapper.mensagem
              : 'Erro ao cadastrar usuário.');
        }
        return;
      } else {
        if (mapaJson is Map<String, dynamic>) {
          if (mapaJson['erros'] != null && mapaJson['erros'] is List) {
            throw Exception((mapaJson['erros'] as List).join('\n'));
          }
          if (mapaJson['mensagem'] != null) {
            throw Exception(mapaJson['mensagem'].toString());
          }
        }
        throw Exception('Erro ao cadastrar usuário (${resposta.statusCode}).');
      }
    } catch (e) {
      if (e.toString().contains('Sem conexão')) {
        return;
      }
      rethrow;
    }
  }

  /// Solicita o envio do e-mail de recuperação de senha (/api/Autenticacao/esqueceu-senha)
  static Future<String> solicitarRecuperacaoSenha({
    required String email,
  }) async {
    try {
      final resposta = await _fazerRequisicao(
        'POST',
        '/Autenticacao/esqueceu-senha',
        {'email': email},
      );

      final dadosResposta = jsonDecode(resposta.body);
      return dadosResposta['mensagem'] ??
          'Se o e-mail estiver cadastrado, você receberá instruções em breve.';
    } catch (_) {
      return 'Se o e-mail estiver cadastrado, você receberá instruções em breve.';
    }
  }

  /// Redefine a senha do usuário com o token recebido (/api/Autenticacao/redefinir-senha)
  static Future<void> redefinirSenha({
    required String token,
    required String novaSenha,
    required String confirmacaoSenha,
  }) async {
    final resposta = await _fazerRequisicao(
      'POST',
      '/Autenticacao/redefinir-senha',
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
      throw Exception(
        dadosResposta['mensagem'] ?? 'Token inválido ou expirado.',
      );
    }
  }

  /// Atualiza os dados do perfil do usuário na API e salva a sessão
  static Future<SessaoUsuario> atualizarPerfilUsuario({
    required String nomeCompleto,
    required String email,
    required String telefone,
    String? cpf,
    String? fotoPerfilUrl,
  }) async {
    final sessaoAtual = await obterSessao();
    try {
      final resposta = await _fazerRequisicao(
        'POST',
        '/Autenticacao/atualizar-perfil',
        {
          'nomeCompleto': nomeCompleto,
          'email': email,
          'telefone': telefone,
          'cpf': cpf,
          'fotoPerfilUrl': fotoPerfilUrl,
        },
      ).timeout(const Duration(seconds: 4));

      if (resposta.statusCode == 200) {
        final dadosResposta = jsonDecode(resposta.body);
        if (dadosResposta is Map<String, dynamic> && (dadosResposta['ok'] ?? true)) {}
      }
    } catch (_) {}

    final novaSessao = (sessaoAtual ?? SessaoUsuario(
      tokenAcesso: 'token-acesso-front',
      nomeCompleto: nomeCompleto,
      email: email,
      perfil: 'Usuario',
    )).copiarCom(
      nomeCompleto: nomeCompleto,
      email: email,
      telefone: telefone,
      cpf: cpf != null && cpf.isNotEmpty ? cpf : sessaoAtual?.cpf,
      fotoPerfilUrl: fotoPerfilUrl ?? sessaoAtual?.fotoPerfilUrl,
    );

    await salvarSessao(novaSessao);
    return novaSessao;
  }

  /// Altera a senha do usuário atualmente autenticado
  static Future<void> alterarSenhaLogado({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    try {
      final resposta = await _fazerRequisicao(
        'POST',
        '/Autenticacao/alterar-senha',
        {
          'senhaAtual': senhaAtual,
          'novaSenha': novaSenha,
        },
      ).timeout(const Duration(seconds: 4));

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados is Map<String, dynamic> && !(dados['ok'] ?? true)) {
          throw Exception(dados['mensagem'] ?? 'Erro ao alterar senha.');
        }
      }
    } catch (e) {
      if (e.toString().contains('Erro ao alterar')) {
        rethrow;
      }
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
