import 'package:flutter/material.dart';
import '../estado_central.dart';

class TelaPerfilDetalhado extends StatelessWidget {
  final ClienteArena cliente;

  const TelaPerfilDetalhado({
    super.key,
    required this.cliente,
  });

  Color _obterCorStatus(TipoStatusAcesso status) {
    switch (status) {
      case TipoStatusAcesso.liberado:
        return const Color(0xFF0B7F38); // Verde
      case TipoStatusAcesso.pendente:
        return const Color(0xFFF59E0B); // Laranja
      case TipoStatusAcesso.livre:
        return const Color(0xFF64748B); // Cinza
      case TipoStatusAcesso.dentro:
        return const Color(0xFF09398E); // Azul escuro
    }
  }

  String _obterTextoStatus(TipoStatusAcesso status) {
    switch (status) {
      case TipoStatusAcesso.liberado:
        return "LIBERADO";
      case TipoStatusAcesso.pendente:
        return "PENDENTE";
      case TipoStatusAcesso.livre:
        return "LIVRE";
      case TipoStatusAcesso.dentro:
        return "DENTRO DA ARENA";
    }
  }

  @override
  Widget build(BuildContext context) {
    final corStatus = _obterCorStatus(cliente.statusAcesso);
    final textoStatus = _obterTextoStatus(cliente.statusAcesso);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09398E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "PERFIL DO USUÁRIO",
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
            // Card Principal de Identificação
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Foto com borda do status
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: corStatus, width: 3),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(cliente.fotoUrl),
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: cliente.fotoUrl.isEmpty
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cliente.nome,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: corStatus.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      textoStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: corStatus,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card de Detalhes Cadastrais
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informações Pessoais",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09398E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _construirLinhaDetalhe(Icons.badge_outlined, "Matrícula", cliente.matricula),
                  const Divider(height: 24),
                  _construirLinhaDetalhe(Icons.assignment_ind_outlined, "CPF", cliente.cpf),
                  const Divider(height: 24),
                  _construirLinhaDetalhe(Icons.sports_soccer, "Reserva Quadra", cliente.localReserva),
                  const Divider(height: 24),
                  _construirLinhaDetalhe(Icons.access_time_outlined, "Horário Previsto", cliente.horarioPrevisto),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card de Contato / Ações Rápidas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Ações do Vigilante",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09398E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Notificação enviada para ${cliente.nome}."),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_outlined, size: 18),
                    label: const Text("Enviar Alerta de Quadra"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF09398E),
                      side: const BorderSide(color: Color(0xFF09398E)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLinhaDetalhe(IconData icone, String titulo, String valor) {
    return Row(
      children: [
        Icon(icone, color: const Color(0xFF64748B), size: 20),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
