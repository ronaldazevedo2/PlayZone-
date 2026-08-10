import 'package:flutter/material.dart';
import 'package:playzone_mobile/traducao.dart';
import '../estado_central.dart';
import 'tela_conversa_notificacao.dart';

class TelaNotificacoes extends StatefulWidget {
  const TelaNotificacoes({super.key});

  @override
  State<TelaNotificacoes> createState() => _TelaNotificacoesEstado();
}

class _TelaNotificacoesEstado extends State<TelaNotificacoes> {
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

  void _marcarComoLidaEAbrirChat(NotificacaoVigilante notificacao) {
    _estadoCentral.marcarNotificacaoComoLida(notificacao.id);

    // Abre a tela de conversa (chat/mensagem) correspondente
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TelaConversaNotificacao(notificacaoId: notificacao.id),
      ),
    );
  }

  void _limparNotificacoes() {
    _estadoCentral.limparNotificacoes();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Tradutor.obter('notif_limpo_msg')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ehEscuro = Theme.of(context).brightness == Brightness.dark;
    final notificacoes = _estadoCentral.notificacoes;

    return Scaffold(
      backgroundColor: ehEscuro
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: ehEscuro
            ? const Color(0xFF1E293B)
            : const Color(0xFF09398E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          Tradutor.obter('notif_titulo'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          if (notificacoes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              tooltip: Tradutor.obter('notif_limpar_tudo'),
              onPressed: _limparNotificacoes,
            ),
        ],
      ),
      body: notificacoes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: ehEscuro
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Tradutor.obter('notif_sem_novas'),
                    style: TextStyle(
                      color: ehEscuro
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20.0),
              itemCount: notificacoes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notificacao = notificacoes[index];
                return _construirCardNotificacao(notificacao, ehEscuro);
              },
            ),
    );
  }

  Widget _construirCardNotificacao(
    NotificacaoVigilante notificacao,
    bool ehEscuro,
  ) {
    Color fundoCard;
    Color bordaCard;

    if (notificacao.lida) {
      fundoCard = ehEscuro ? const Color(0xFF1E293B) : Colors.white;
      bordaCard = ehEscuro ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    } else {
      fundoCard = ehEscuro
          ? const Color(0xFF1E3A8A).withOpacity(0.3)
          : const Color(0xFFEFF6FF);
      bordaCard = ehEscuro ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE);
    }

    return GestureDetector(
      onTap: () => _marcarComoLidaEAbrirChat(notificacao),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fundoCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bordaCard),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone da Notificação
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notificacao.corIcone.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notificacao.icone,
                color: notificacao.corIcone,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Conteúdo textual
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notificacao.titulo,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: notificacao.lida
                                ? FontWeight.bold
                                : FontWeight.w800,
                            color: ehEscuro
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Bolinha azul se não lida
                      if (!notificacao.lida)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notificacao.descricao,
                    style: TextStyle(
                      fontSize: 11,
                      color: ehEscuro
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notificacao.tempoPassado,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: ehEscuro
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
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
}
