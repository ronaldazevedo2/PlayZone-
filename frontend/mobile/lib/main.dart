import 'package:flutter/material.dart';
import 'telas/tela_login.dart';

void main() {
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayZone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22C55E), // Verde clássico do app
          primary: const Color(0xFF22C55E),
          secondary: const Color(0xFF3B82F6), // Azul para focos secundários
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const TelaLogin(),
    );
  }
}
