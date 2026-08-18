import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'servicos/servico_autenticacao.dart';
import 'telas/tela_cadastro_usuario.dart';
import 'telas/tela_detalhes_quadra.dart';
import 'telas/tela_esqueceu_senha.dart';
import 'telas/tela_inicial.dart';
import 'telas/tela_login.dart';
import 'telas/tela_perfil_usuario.dart';
import 'telas/tela_redefinir_senha.dart';

void main() {
  HttpOverrides.global = OverridesHttpPlayZone();
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

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
      onGenerateRoute: _gerarRotaConfigurada,
    );
  }

  static Route<dynamic>? _gerarRotaConfigurada(RouteSettings configuracao) {
    final uri = Uri.parse(configuracao.name ?? '/');
    final caminho = uri.path;

    return MaterialPageRoute(
      settings: configuracao,
      builder: (context) {
        return FutureBuilder<SessaoUsuario?>(
          future: ServicoAutenticacao.obterSessao(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF238838)),
                ),
              );
            }

            final sessao = snapshot.data;

            // Rotas públicas sem necessidade de autenticação
            if (caminho == '/cadastro') return const TelaCadastroUsuario();
            if (caminho == '/esqueceu-senha') return const TelaEsqueceuSenha();
            if (caminho == '/redefinir-senha') return const TelaRedefinirSenha();
            if (caminho == '/login') {
              return sessao != null
                  ? TelaInicial(sessao: sessao, abaInicial: 0)
                  : const TelaLoginUsuario();
            }

            // Se a sessão for nula e a rota for privada -> Redireciona para /login
            if (sessao == null) {
              return const TelaLoginUsuario();
            }

            // Rotas autenticadas da aplicação
            switch (caminho) {
              case '/inicio':
              case '/home':
              case '/':
                return TelaInicial(sessao: sessao, abaInicial: 0);
              case '/buscar/quadras':
              case '/pesquisa':
                return TelaInicial(sessao: sessao, abaInicial: 1);
              case '/agendamentos':
              case '/meus-agendamentos':
                return TelaInicial(sessao: sessao, abaInicial: 2);
              case '/perfil':
                return TelaPerfilUsuario(sessao: sessao);
              case '/quadras/detalhes':
              case '/detalhes-quadra':
                final quadraId = uri.queryParameters['id'] ??
                    (configuracao.arguments as String?) ??
                    '33333333-3333-3333-3333-333333333333';
                return TelaDetalhesQuadra(quadraId: quadraId);
              default:
                return TelaInicial(sessao: sessao, abaInicial: 0);
            }
          },
        );
      },
    );
  }
}
