import 'package:shared_preferences/shared_preferences.dart';

/// Serviço responsável por persistir dados localmente usando shared_preferences.
/// Utilizado principalmente para salvar e restaurar a sessão do vigilante logado.
class ServicoArmazenamento {
  // Singleton
  static final ServicoArmazenamento _instancia = ServicoArmazenamento._interno();
  factory ServicoArmazenamento() => _instancia;
  ServicoArmazenamento._interno();

  static const String _chaveEmailLogado = 'email_vigilante_logado';
  static const String _chaveTutorialVisto = 'tutorial_home_visto';
  static const String _chaveModoEscuro = 'modo_escuro';
  static const String _chaveIdioma = 'idioma_selecionado';
  static const String _chaveNotificacoes = 'notificacoes_ativas';

  SharedPreferences? _prefs;

  /// Inicializa o SharedPreferences (deve ser chamado antes de usar).
  Future<void> inicializar() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _preferencias async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ─── Sessão do Usuário ──────────────────────────────────────────────────────

  /// Salva o email do vigilante logado para persistência de sessão.
  Future<void> salvarSessao(String email) async {
    final prefs = await _preferencias;
    await prefs.setString(_chaveEmailLogado, email);
  }

  /// Retorna o email do vigilante salvo, ou null se não houver sessão.
  Future<String?> obterEmailSessao() async {
    final prefs = await _preferencias;
    return prefs.getString(_chaveEmailLogado);
  }

  /// Remove a sessão salva (logout).
  Future<void> limparSessao() async {
    final prefs = await _preferencias;
    await prefs.remove(_chaveEmailLogado);
  }

  // ─── Preferências do App ────────────────────────────────────────────────────

  /// Salva preferência de modo escuro.
  Future<void> salvarModoEscuro(bool ativo) async {
    final prefs = await _preferencias;
    await prefs.setBool(_chaveModoEscuro, ativo);
  }

  /// Retorna preferência de modo escuro (padrão: false).
  Future<bool> obterModoEscuro() async {
    final prefs = await _preferencias;
    return prefs.getBool(_chaveModoEscuro) ?? false;
  }

  /// Salva idioma selecionado.
  Future<void> salvarIdioma(String idioma) async {
    final prefs = await _preferencias;
    await prefs.setString(_chaveIdioma, idioma);
  }

  /// Retorna idioma salvo (padrão: Português (BR)).
  Future<String> obterIdioma() async {
    final prefs = await _preferencias;
    return prefs.getString(_chaveIdioma) ?? 'Português (BR)';
  }

  /// Salva preferência de notificações.
  Future<void> salvarNotificacoes(bool ativo) async {
    final prefs = await _preferencias;
    await prefs.setBool(_chaveNotificacoes, ativo);
  }

  /// Retorna preferência de notificações (padrão: true).
  Future<bool> obterNotificacoes() async {
    final prefs = await _preferencias;
    return prefs.getBool(_chaveNotificacoes) ?? true;
  }

  // ─── Tutorial ───────────────────────────────────────────────────────────────

  /// Salva que o tutorial da home já foi visualizado.
  Future<void> marcarTutorialComoVisto() async {
    final prefs = await _preferencias;
    await prefs.setBool(_chaveTutorialVisto, true);
  }

  /// Retorna se o tutorial já foi visto.
  Future<bool> tutorialJaFoiVisto() async {
    final prefs = await _preferencias;
    return prefs.getBool(_chaveTutorialVisto) ?? false;
  }
}
