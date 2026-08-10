import 'package:flutter/material.dart';
import 'tela_home.dart';
import 'tela_buscar.dart';
import 'tela_historico_entradas.dart';
import 'tela_perfil.dart';
import '../estado_central.dart';
import '../traducao.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceSelecionado = 0;
  final EstadoCentral _estadoCentral = EstadoCentral();

  // Lista de telas das abas
  late final List<Widget> _telas;

  @override
  void initState() {
    super.initState();
    _estadoCentral.addListener(_aoAtualizarEstado);
    _telas = [
      TelaHome(aoNavegarParaAba: _alterarAba),
      const TelaBuscar(),
      const TelaHistoricoEntradas(),
      TelaPerfil(aoEfetuarLogoff: _voltarParaLogin),
    ];
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
    final ehEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _indiceSelecionado,
        children: _telas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(ehEscuro ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceSelecionado,
          onTap: _alterarAba,
          type: BottomNavigationBarType.fixed,
          backgroundColor: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
          selectedItemColor: const Color(0xFF0B7F38), // Verde ativo
          unselectedItemColor: ehEscuro ? const Color(0xFF64748B) : const Color(0xFF94A3B8), // Cinza inativo
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: Tradutor.obter('aba_home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              activeIcon: const Icon(Icons.search),
              label: Tradutor.obter('aba_buscar'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.description_outlined),
              activeIcon: const Icon(Icons.description),
              label: Tradutor.obter('aba_historico'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: Tradutor.obter('aba_perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
