import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelo de dados e conversão para persistência do Vigilante no Banco de Dados
class VigilanteRegistro {
  final String nome;
  final String email;
  final String matricula;
  final String senha;

  VigilanteRegistro({
    required this.nome,
    required this.email,
    required this.matricula,
    required this.senha,
  });

  Map<String, dynamic> paraMapa() {
    return {
      'nome': nome,
      'email': email,
      'matricula': matricula,
      'senha': senha,
    };
  }

  factory VigilanteRegistro.doMapa(Map<String, dynamic> mapa) {
    return VigilanteRegistro(
      nome: mapa['nome'] ?? '',
      email: mapa['email'] ?? '',
      matricula: mapa['matricula'] ?? '',
      senha: mapa['senha'] ?? '',
    );
  }

  String paraJson() => json.encode(paraMapa());

  factory VigilanteRegistro.doJson(String fonte) =>
      VigilanteRegistro.doMapa(json.decode(fonte));
}

/// Serviço responsável pelo gerenciamento de banco de dados e persistência dos vigilantes cadastrados
class ServicoBancoDados {
  static final ServicoBancoDados _instancia = ServicoBancoDados._interno();
  factory ServicoBancoDados() => _instancia;
  ServicoBancoDados._interno();

  static const String _chaveTabelaVigilantes = 'tabela_vigilantes_cadastrados';

  SharedPreferences? _preferencias;

  Future<SharedPreferences> get _obterPreferencias async {
    _preferencias ??= await SharedPreferences.getInstance();
    return _preferencias!;
  }

  /// Inicializa a conexão com o banco de dados local
  Future<void> inicializarBanco() async {
    _preferencias ??= await SharedPreferences.getInstance();
  }

  /// Carrega todos os vigilantes salvos no banco de dados
  Future<List<VigilanteRegistro>> obterTodosVigilantes() async {
    final prefs = await _obterPreferencias;
    final List<String>? listaJson = prefs.getStringList(_chaveTabelaVigilantes);

    if (listaJson == null || listaJson.isEmpty) {
      return [];
    }

    return listaJson
        .map((item) => VigilanteRegistro.doJson(item))
        .toList();
  }

  /// Salva ou atualiza um vigilante no banco de dados local
  Future<bool> salvarVigilante(VigilanteRegistro vigilante) async {
    final prefs = await _obterPreferencias;
    final vigilantes = await obterTodosVigilantes();

    // Verifica se já existe vigilante cadastrado com este e-mail
    final indiceExistente = vigilantes.indexWhere(
      (v) => v.email.trim().toLowerCase() == vigilante.email.trim().toLowerCase(),
    );

    if (indiceExistente != -1) {
      // Atualiza o cadastro existente
      vigilantes[indiceExistente] = vigilante;
    } else {
      // Insere um novo vigilante no banco de dados
      vigilantes.add(vigilante);
    }

    final listaJson = vigilantes.map((v) => v.paraJson()).toList();
    return await prefs.setStringList(_chaveTabelaVigilantes, listaJson);
  }

  /// Busca um vigilante específico no banco de dados pelo e-mail
  Future<VigilanteRegistro?> buscarVigilantePorEmail(String email) async {
    final vigilantes = await obterTodosVigilantes();
    final emailFormatado = email.trim().toLowerCase();

    for (final v in vigilantes) {
      if (v.email.trim().toLowerCase() == emailFormatado) {
        return v;
      }
    }
    return null;
  }

  /// Remove um vigilante do banco de dados pelo e-mail
  Future<bool> removerVigilante(String email) async {
    final prefs = await _obterPreferencias;
    final vigilantes = await obterTodosVigilantes();

    vigilantes.removeWhere(
      (v) => v.email.trim().toLowerCase() == email.trim().toLowerCase(),
    );

    final listaJson = vigilantes.map((v) => v.paraJson()).toList();
    return await prefs.setStringList(_chaveTabelaVigilantes, listaJson);
  }
}
