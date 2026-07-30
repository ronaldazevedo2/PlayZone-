import 'package:flutter/material.dart';
import '../estado_central.dart';

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesEstado();
}

class _TelaConfiguracoesEstado extends State<TelaConfiguracoes> {
  final EstadoCentral _estadoCentral = EstadoCentral();

  @override
  void initState() {
    super.initState();
    _estadoCentral.addListener(_aoAtualizarEstado);
  }

  @override
  void dispose() {
    _estadoCentral.removeListener(_aoAtualizarEstado);
    super.dispose();
  }

  void _aoAtualizarEstado() {
    if (mounted) {
      setState(() {});
    }
  }

  String _obterTextoTraduzido(String chave) {
    final idioma = _estadoCentral.idiomaSelecionado;
    final traducoes = {
      'Português (BR)': {
        'titulo': 'CONFIGURAÇÕES',
        'pref': 'Preferências do Aplicativo',
        'notif': 'Notificações Push',
        'notif_sub': 'Receber alertas em tempo real',
        'tema': 'Modo Escuro',
        'tema_sub': 'Alterar visual para tons escuros',
        'bio': 'Acesso Biométrico',
        'bio_sub': 'Entrar com impressão digital/rosto',
        'idioma': 'Idioma do Aplicativo',
        'rodape': 'Configurações salvas localmente no dispositivo.',
        'atv_notif': 'Notificações ativadas.',
        'des_notif': 'Notificações desativadas.',
        'atv_escuro': 'Modo escuro ativado.',
        'des_escuro': 'Modo claro ativado.',
        'atv_bio': 'Acesso biométrico ativado.',
        'des_bio': 'Acesso biométrico desativado.',
        'idioma_alt': 'Idioma alterado com sucesso.',
      },
      'English': {
        'titulo': 'SETTINGS',
        'pref': 'Application Preferences',
        'notif': 'Push Notifications',
        'notif_sub': 'Receive real-time alerts',
        'tema': 'Dark Mode',
        'tema_sub': 'Change visual to dark tones',
        'bio': 'Biometric Access',
        'bio_sub': 'Login with fingerprint/face',
        'idioma': 'App Language',
        'rodape': 'Settings saved locally on the device.',
        'atv_notif': 'Notifications enabled.',
        'des_notif': 'Notifications disabled.',
        'atv_escuro': 'Dark mode enabled.',
        'des_escuro': 'Light mode enabled.',
        'atv_bio': 'Biometric access enabled.',
        'des_bio': 'Biometric access disabled.',
        'idioma_alt': 'Language changed successfully.',
      },
      'Español': {
        'titulo': 'CONFIGURACIÓN',
        'pref': 'Preferencias de la Aplicación',
        'notif': 'Notificaciones Push',
        'notif_sub': 'Recibir alertas en tiempo real',
        'tema': 'Modo Oscuro',
        'tema_sub': 'Cambiar visual a tonos oscuros',
        'bio': 'Acceso Biométrico',
        'bio_sub': 'Entrar con huella dactilar/rostro',
        'idioma': 'Idioma de la Aplicación',
        'rodape': 'Configuraciones guardadas localmente en el dispositivo.',
        'atv_notif': 'Notificaciones activadas.',
        'des_notif': 'Notificaciones desactivadas.',
        'atv_escuro': 'Modo oscuro activado.',
        'des_escuro': 'Modo claro activado.',
        'atv_bio': 'Acceso biométrico activado.',
        'des_bio': 'Acceso biométrico desactivado.',
        'idioma_alt': 'Idioma cambiado con éxito.',
      }
    };

    return traducoes[idioma]?[chave] ?? chave;
  }

  void _aoAlternarNotificacoes(bool valor) {
    _estadoCentral.alterarNotificacoes(valor);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(valor ? _obterTextoTraduzido('atv_notif') : _obterTextoTraduzido('des_notif')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _aoAlternarModoEscuro(bool valor) {
    _estadoCentral.alterarModoEscuro(valor);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(valor ? _obterTextoTraduzido('atv_escuro') : _obterTextoTraduzido('des_escuro')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _aoAlternarBiometria(bool valor) {
    _estadoCentral.alterarBiometria(valor);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(valor ? _obterTextoTraduzido('atv_bio') : _obterTextoTraduzido('des_bio')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF09398E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _obterTextoTraduzido('titulo'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
            _obterTextoTraduzido('pref'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          
          // Card de Configurações
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _construirItemAlternador(
                  icone: Icons.notifications_active_outlined,
                  titulo: _obterTextoTraduzido('notif'),
                  subtitulo: _obterTextoTraduzido('notif_sub'),
                  valor: _estadoCentral.notificacoesAtivas,
                  aoAlterar: _aoAlternarNotificacoes,
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _construirItemAlternador(
                  icone: Icons.dark_mode_outlined,
                  titulo: _obterTextoTraduzido('tema'),
                  subtitulo: _obterTextoTraduzido('tema_sub'),
                  valor: _estadoCentral.modoEscuroAtivo,
                  aoAlterar: _aoAlternarModoEscuro,
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _construirItemAlternador(
                  icone: Icons.fingerprint,
                  titulo: _obterTextoTraduzido('bio'),
                  subtitulo: _obterTextoTraduzido('bio_sub'),
                  valor: _estadoCentral.biometriaAtiva,
                  aoAlterar: _aoAlternarBiometria,
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _construirItemDropdown(
                  icone: Icons.language,
                  titulo: _obterTextoTraduzido('idioma'),
                  valorAtual: _estadoCentral.idiomaSelecionado,
                  opcoes: const ['Português (BR)', 'English', 'Español'],
                  aoAlterar: (novoValor) {
                    if (novoValor != null) {
                      _estadoCentral.alterarIdioma(novoValor);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_obterTextoTraduzido('idioma_alt')),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Rodapé informativo
          Center(
            child: Text(
              _obterTextoTraduzido('rodape'),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirItemAlternador({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required void Function(bool) aoAlterar,
  }) {
    return ListTile(
      leading: Icon(icone, color: const Color(0xFF09398E)),
      title: Text(
        titulo,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF64748B),
        ),
      ),
      trailing: Switch(
        value: valor,
        onChanged: aoAlterar,
        activeColor: const Color(0xFF0B7F38),
      ),
    );
  }

  Widget _construirItemDropdown({
    required IconData icone,
    required String titulo,
    required String valorAtual,
    required List<String> opcoes,
    required void Function(String?) aoAlterar,
  }) {
    return ListTile(
      leading: Icon(icone, color: const Color(0xFF09398E)),
      title: Text(
        titulo,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1E293B),
        ),
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valorAtual,
          dropdownColor: Theme.of(context).cardColor,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF09398E)),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          onChanged: aoAlterar,
          items: opcoes.map<DropdownMenuItem<String>>((String opcao) {
            return DropdownMenuItem<String>(
              value: opcao,
              child: Text(opcao),
            );
          }).toList(),
        ),
      ),
    );
  }
}
