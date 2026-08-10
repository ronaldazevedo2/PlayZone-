import 'package:flutter/material.dart';
import '../estado_central.dart';
import '../traducao.dart';

class TelaConversaNotificacao extends StatefulWidget {
  final String notificacaoId;

  const TelaConversaNotificacao({
    super.key,
    required this.notificacaoId,
  });

  @override
  State<TelaConversaNotificacao> createState() => _TelaConversaNotificacaoEstado();
}

class _TelaConversaNotificacaoEstado extends State<TelaConversaNotificacao> {
  final TextEditingController _controladorMensagem = TextEditingController();
  final ScrollController _controladorRolagem = ScrollController();
  final EstadoCentral _estado = EstadoCentral();

  @override
  void initState() {
    super.initState();
    _estado.addListener(_aoAtualizarEstado);
    // Rolagem para o final após carregar
    WidgetsBinding.instance.addPostFrameCallback((_) => _rolarParaFinal(animar: false));
  }

  @override
  void dispose() {
    _estado.removeListener(_aoAtualizarEstado);
    _controladorMensagem.dispose();
    _controladorRolagem.dispose();
    super.dispose();
  }

  void _aoAtualizarEstado() {
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) => _rolarParaFinal());
    }
  }

  void _rolarParaFinal({bool animar = true}) {
    if (_controladorRolagem.hasClients) {
      if (animar) {
        _controladorRolagem.animateTo(
          _controladorRolagem.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _controladorRolagem.jumpTo(_controladorRolagem.position.maxScrollExtent);
      }
    }
  }

  void _enviarMensagem() {
    final texto = _controladorMensagem.text.trim();
    if (texto.isEmpty) return;

    _estado.enviarMensagemChat(widget.notificacaoId, texto);
    _controladorMensagem.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Busca a notificação atualizada
    final notificacao = _estado.notificacoes.firstWhere(
      (n) => n.id == widget.notificacaoId,
      orElse: () => NotificacaoVigilante(
        id: '',
        titulo: 'Conversa',
        descricao: '',
        tempoPassado: '',
        icone: Icons.chat,
        corIcone: Colors.blue,
        conversa: [],
      ),
    );

    final ehEscuro = Theme.of(context).brightness == Brightness.dark;

    if (notificacao.id.isEmpty) {
      return Scaffold(
        backgroundColor: ehEscuro ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        body: Center(child: Text(Tradutor.obter('notif_sem_novas'))),
      );
    }

    String obterSubtituloCanal() {
      final idioma = _estado.idiomaSelecionado;
      if (idioma == 'English') return "Support and Alerts Channel";
      if (idioma == 'Español') return "Canal de Soporte y Alertas";
      return "Canal de Suporte e Alertas";
    }

    return Scaffold(
      backgroundColor: ehEscuro ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9), // Fundo do chat
      appBar: AppBar(
        backgroundColor: ehEscuro ? const Color(0xFF1E293B) : const Color(0xFF09398E),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: notificacao.corIcone.withOpacity(0.15),
              child: Icon(notificacao.icone, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Tradutor.obter(notificacao.titulo),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    obterSubtituloCanal(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Área de Mensagens
          Expanded(
            child: ListView.builder(
              controller: _controladorRolagem,
              padding: const EdgeInsets.all(16.0),
              itemCount: notificacao.conversa.length,
              itemBuilder: (context, index) {
                final msg = notificacao.conversa[index];
                return _construirBalaoMensagem(msg, ehEscuro);
              },
            ),
          ),

          // Campo de Entrada de Mensagens
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
              border: Border(top: BorderSide(color: ehEscuro ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ehEscuro ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: ehEscuro ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controladorMensagem,
                        style: TextStyle(color: ehEscuro ? Colors.white : const Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          hintText: Tradutor.obter('chat_dica'),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: ehEscuro ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 14),
                        ),
                        onSubmitted: (_) => _enviarMensagem(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _enviarMensagem,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0B7F38), // Verde para enviar
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBalaoMensagem(MensagemChat msg, bool ehEscuro) {
    final alinhamentoDireita = msg.enviadaPorMim;
    final corFundo = alinhamentoDireita 
        ? const Color(0xFF0B7F38) 
        : (ehEscuro ? const Color(0xFF1E293B) : Colors.white);
    final corTexto = alinhamentoDireita ? Colors.white : (ehEscuro ? Colors.white : const Color(0xFF1E293B));

    return Align(
      alignment: alinhamentoDireita ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: alinhamentoDireita ? const Radius.circular(16) : Radius.zero,
            bottomRight: alinhamentoDireita ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Tradutor.obter(msg.texto),
              style: TextStyle(
                color: corTexto,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "${msg.dataHora.hour.toString().padLeft(2, '0')}:${msg.dataHora.minute.toString().padLeft(2, '0')}",
                style: TextStyle(
                  color: alinhamentoDireita ? Colors.white70 : const Color(0xFF94A3B8),
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
