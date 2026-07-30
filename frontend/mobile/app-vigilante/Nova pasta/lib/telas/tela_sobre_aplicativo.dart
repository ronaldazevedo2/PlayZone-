import 'package:flutter/material.dart';

class TelaSobreAplicativo extends StatelessWidget {
  const TelaSobreAplicativo({super.key});

  void _abrirTermos(BuildContext context) {
    Navigator.of(context).pushNamed('/termos');
  }

  void _abrirPrivacidade(BuildContext context) {
    Navigator.of(context).pushNamed('/privacidade');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF09398E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "SOBRE O APLICATIVO",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Logo Centralizada
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.sports_soccer,
                  size: 80,
                  color: Color(0xFF09398E),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nome e Versão
            const Text(
              "PlayZone Arenas",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF09398E),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Versão 1.0.0",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Descrição do Aplicativo
            const Text(
              "O aplicativo PlayZone Vigilante foi projetado especificamente para o monitoramento, controle de acesso e gestão síncrona das quadras esportivas da PlayZone. Com ele, o vigilante pode validar reservas por QR Code, inspecionar a ocupação em tempo real e consultar históricos de acesso de forma ágil e segura.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF1E293B),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),

            // Links Úteis
            ListTile(
              title: const Text(
                "Termos de Uso",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              trailing: const Icon(Icons.open_in_new, size: 18, color: Color(0xFF09398E)),
              onTap: () => _abrirTermos(context),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            ListTile(
              title: const Text(
                "Política de Privacidade",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              trailing: const Icon(Icons.open_in_new, size: 18, color: Color(0xFF09398E)),
              onTap: () => _abrirPrivacidade(context),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            const SizedBox(height: 48),

            // Créditos
            const Text(
              "© 2026 PlayZone Arenas. Todos os direitos reservados.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
