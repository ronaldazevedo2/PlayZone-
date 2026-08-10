import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega preferências salvas antes de exibir o app
  await EstadoCentral().carregarPreferencias();
  runApp(const MeuAplicativo());
}

// ScrollBehavior personalizado para scroll suave em todas as plataformas
class _ScrollBehaviorPersonalizado extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
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

  // Constrói TextTheme com Google Fonts (Inter)
  TextTheme _construirTextTheme(Brightness brightness) {
    final corBase = brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1E293B);
    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(color: corBase),
        displayMedium: TextStyle(color: corBase),
        displaySmall: TextStyle(color: corBase),
        headlineLarge: TextStyle(color: corBase),
        headlineMedium: TextStyle(color: corBase),
        headlineSmall: TextStyle(color: corBase),
        titleLarge: TextStyle(color: corBase, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: corBase, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: corBase, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: corBase),
        bodyMedium: TextStyle(
          color: brightness == Brightness.dark
              ? const Color(0xFF94A3B8)
              : const Color(0xFF475569),
        ),
        bodySmall: TextStyle(
          color: brightness == Brightness.dark
              ? const Color(0xFF64748B)
              : const Color(0xFF94A3B8),
        ),
        labelLarge: TextStyle(color: corBase, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayZone Vigilante',
      debugShowCheckedModeBanner: false,
      scrollBehavior: _ScrollBehaviorPersonalizado(),
      themeMode: _estadoCentral.modoEscuroAtivo
          ? ThemeMode.dark
          : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        textTheme: _construirTextTheme(Brightness.light),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF0B7F38),
          primary: const Color(0xFF0B7F38),
          secondary: const Color(0xFF09398E),
          surface: Colors.white,
          onSurface: const Color(0xFF1E293B),
          outline: const Color(0xFFE2E8F0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF09398E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0B7F38), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return const Color(0xFF94A3B8);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected))
              return const Color(0xFF0B7F38);
            return const Color(0xFFE2E8F0);
          }),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: _construirTextTheme(Brightness.dark),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF0B7F38),
          primary: const Color(0xFF22C55E),
          secondary: const Color(0xFF3B82F6),
          surface: const Color(0xFF1E293B),
          onSurface: Colors.white,
          outline: const Color(0xFF334155),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFF1E293B),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return const Color(0xFF475569);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected))
              return const Color(0xFF22C55E);
            return const Color(0xFF334155);
          }),
        ),
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
