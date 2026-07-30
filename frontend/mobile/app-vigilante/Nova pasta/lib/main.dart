import 'package:flutter/material.dart';
import 'telas/splash_page.dart';
import 'telas/tela_login.dart';
import 'telas/tela_principal.dart';
import 'telas/tela_esqueci_senha.dart';
import 'telas/tela_cadastro.dart';
import 'telas/tela_configuracoes.dart';
import 'telas/tela_notificacoes.dart';
import 'telas/tela_sobre_aplicativo.dart';
import 'telas/tela_termos_uso.dart';
import 'telas/tela_politica_privacidade.dart';
import 'estado_central.dart';

void main() {
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatefulWidget {
  const MeuAplicativo({super.key});

  @override
  State<MeuAplicativo> createState() => _MeuAplicativoEstado();
}

class _MeuAplicativoEstado extends State<MeuAplicativo> {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayZone',
      debugShowCheckedModeBanner: false,
      themeMode: _estadoCentral.modoEscuroAtivo ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF0B7F38), // Verde clássico conforme mockups
          primary: const Color(0xFF0B7F38),
          secondary: const Color(0xFF09398E), // Azul escuro dos cabeçalhos
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF0B7F38),
          primary: const Color(0xFF22C55E),
          secondary: const Color(0xFF3B82F6),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Fundo dark premium
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaSplash(),
        '/login': (context) => const TelaLogin(),
        '/principal': (context) => const TelaPrincipal(),
        '/esqueci_senha': (context) => const TelaEsqueciSenha(),
        '/cadastro': (context) => const TelaCadastro(),
        '/configuracoes': (context) => const TelaConfiguracoes(),
        '/notificacoes': (context) => const TelaNotificacoes(),
        '/sobre': (context) => const TelaSobreAplicativo(),
        '/termos': (context) => const TelaTermosUso(),
        '/privacidade': (context) => const TelaPoliticaPrivacidade(),
      },
    );
  }
}

