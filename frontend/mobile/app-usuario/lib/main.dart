import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'servicos/servico_autenticacao.dart';
import 'telas/tela_inicial.dart';
import 'telas/tela_login.dart';

void main() {
  HttpOverrides.global = OverridesHttpPlayZone();
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatefulWidget {
  const MeuAplicativo({super.key});

  @override
  State<MeuAplicativo> createState() => _MeuAplicativoEstado();
}

class _MeuAplicativoEstado extends State<MeuAplicativo> {
  late Future<SessaoUsuario?> _futureSessao;

  @override
  void initState() {
    super.initState();
    _futureSessao = ServicoAutenticacao.obterSessao();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayZone',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF238838), // Verde clássico do app
          primary: const Color(0xFF238838),
          secondary: const Color(0xFF163791), // Azul para focos secundários
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<SessaoUsuario?>(
        future: _futureSessao,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF238838)),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return TelaInicial(sessao: snapshot.data!);
          }
          return const TelaLoginUsuario();
        },
      ),
    );
  }
}
