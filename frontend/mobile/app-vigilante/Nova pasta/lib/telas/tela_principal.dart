import 'package:flutter/material.dart';
import 'tela_home.dart';
import 'tela_buscar.dart';
import 'tela_historico_entradas.dart';
import 'tela_perfil.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceSelecionado = 0;

  // Lista de telas das abas
  late final List<Widget> _telas;

  @override
  void initState() {
    super.initState();
    _telas = [
      TelaHome(aoNavegarParaAba: _alterarAba),
      TelaBuscar(),
      TelaHistoricoEntradas(),
      TelaPerfil(aoEfetuarLogoff: _voltarParaLogin),
    ];
  }

  void _alterarAba(int indice) {
    setState(() {
      _indiceSelecionado = indice;
    });
  }

  void _voltarParaLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceSelecionado,
        children: _telas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceSelecionado,
          onTap: _alterarAba,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0B7F38), // Verde ativo
          unselectedItemColor: const Color(0xFF94A3B8), // Cinza inativo
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Histórico',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
