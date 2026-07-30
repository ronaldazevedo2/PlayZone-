import 'dart:math';
import 'package:flutter/material.dart';
import '../estado_central.dart';

class TelaPerfil extends StatefulWidget {
  final VoidCallback aoEfetuarLogoff;

  const TelaPerfil({
    super.key,
    required this.aoEfetuarLogoff,
  });

  @override
  State<TelaPerfil> createState() => _TelaPerfilEstado();
}

class _TelaPerfilEstado extends State<TelaPerfil> {
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

  void _mostrarConfirmacaoSaida() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Sair da Conta",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF09398E),
            ),
          ),
          content: const Text(
            "Deseja realmente sair da sua conta?",
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _estadoCentral.deslogarVigilante();
                widget.aoEfetuarLogoff();
              },
              child: const Text(
                "Sair",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vigilante = _estadoCentral.vigilanteLogado;
    final nome = vigilante != null ? vigilante.nome : "Vigilante";
    final email = vigilante != null ? vigilante.email : "vigilante@email.com";
    final matricula = vigilante != null ? vigilante.matricula : "---";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09398E),
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          "VIGILANTE",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
            onPressed: () {
              Navigator.of(context).pushNamed('/notificacoes');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "MEU PERFIL",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF09398E),
              ),
            ),
            const SizedBox(height: 20),

            // Card do Perfil do Vigilante Logado Real
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  // Foto Circular / Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF09398E), width: 2),
                      color: const Color(0xFFE2E8F0),
                    ),
                    child: ClipOval(
                      child: Center(
                        child: Text(
                          nome.substring(0, min(2, nome.length)).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF09398E),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Dados do Perfil
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Matrícula: $matricula",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Arena PlayZone",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF09398E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Opções do Perfil
            _construirOpcaoPerfil(
              icone: Icons.settings_outlined,
              titulo: "Configurações",
              aoClicar: () => Navigator.of(context).pushNamed('/configuracoes'),
            ),
            const SizedBox(height: 12),
            _construirOpcaoPerfil(
              icone: Icons.notifications_none_outlined,
              titulo: "Notificações",
              aoClicar: () => Navigator.of(context).pushNamed('/notificacoes'),
            ),
            const SizedBox(height: 12),
            _construirOpcaoPerfil(
              icone: Icons.info_outline,
              titulo: "Sobre o aplicativo",
              aoClicar: () => Navigator.of(context).pushNamed('/sobre'),
            ),
            const SizedBox(height: 24),

            // Botão Sair da Conta
            GestureDetector(
              onTap: _mostrarConfirmacaoSaida,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Color(0xFF0B7F38), // Verde conforme imagem de referência
                      size: 24,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Sair da conta",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B7F38),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirOpcaoPerfil({
    required IconData icone,
    required String titulo,
    required VoidCallback aoClicar,
  }) {
    return GestureDetector(
      onTap: aoClicar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(
              icone,
              color: const Color(0xFF09398E), // Azul escuro
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF09398E),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
