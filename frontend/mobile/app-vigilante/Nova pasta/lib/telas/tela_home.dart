import 'package:flutter/material.dart';
import 'tela_controle_acesso.dart';
import 'tela_status_arena.dart';
import '../estado_central.dart';

class TelaHome extends StatefulWidget {
  final Function(int) aoNavegarParaAba;

  const TelaHome({
    super.key,
    required this.aoNavegarParaAba,
  });

  @override
  State<TelaHome> createState() => _TelaHomeEstado();
}

class _TelaHomeEstado extends State<TelaHome> {
  bool _mostrarTutorial = true;
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

  void _navegarParaControleAcesso() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TelaControleAcesso(aoNavegarParaAba: widget.aoNavegarParaAba)),
    );
  }

  void _navegarParaStatusArena() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TelaStatusArena()),
    );
  }

  void _abrirHistorico() {
    widget.aoNavegarParaAba(2); // Muda para a aba de Histórico (índice 2)
  }

  void _abrirBusca() {
    widget.aoNavegarParaAba(1); // Muda para a aba de Buscar (índice 1)
  }

  @override
  Widget build(BuildContext context) {
    final vigilante = _estadoCentral.vigilanteLogado;
    final nomeExibido = vigilante != null ? vigilante.nome : "Vigilante";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09398E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 36,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "PLAYZONE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.of(context).pushNamed('/notificacoes');
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 12),
            child: const Text(
              "VIGILANTE",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Conteúdo Principal da Home
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Olá, $nomeExibido! 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Pronto para mais um dia de trabalho.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // Card Principal - Escanear QR Code
                GestureDetector(
                  onTap: _navegarParaControleAcesso,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B7F38), // Verde escuro principal
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B7F38).withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ESCANEAR\nQR CODE",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Registre a entrada de usuários",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF09398E), // Azul escuro
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Seção Menu Rápido com os 4 Cards
                const Text(
                  "ATALHOS DA ARENA",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _construirItemMenu(
                  icone: Icons.shield_outlined,
                  titulo: "CONTROLE DE ACESSO",
                  subtitulo: "Gerencie e registre entradas na arena",
                  aoClicar: _navegarParaControleAcesso,
                ),
                const SizedBox(height: 12),
                _construirItemMenu(
                  icone: Icons.bar_chart_outlined,
                  titulo: "STATUS DA ARENA",
                  subtitulo: "Veja ocupação e situação das quadras",
                  aoClicar: _navegarParaStatusArena,
                ),
                const SizedBox(height: 12),
                _construirItemMenu(
                  icone: Icons.access_time_outlined,
                  titulo: "HISTÓRICO DE ENTRADAS",
                  subtitulo: "Consulte todas as entradas registradas",
                  aoClicar: _abrirHistorico,
                ),
                const SizedBox(height: 12),
                _construirItemMenu(
                  icone: Icons.search_outlined,
                  titulo: "BUSCAR USUÁRIOS",
                  subtitulo: "Procure por nome ou documento (CPF)",
                  aoClicar: _abrirBusca,
                ),
                const SizedBox(height: 28),

                // Seção Instruções de Uso Detalhadas
                const Text(
                  "INSTRUÇÕES DE USO",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Como operar o sistema de acessos:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF09398E),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 12),
                      _ItemInstrucao(
                        numero: "1",
                        texto: "Abra o scanner de QR Code ao receber um jogador na entrada da quadra.",
                      ),
                      SizedBox(height: 10),
                      _ItemInstrucao(
                        numero: "2",
                        texto: "Valide os dados da reserva apresentados na tela (nome do jogador, quadra e horário).",
                      ),
                      SizedBox(height: 10),
                      _ItemInstrucao(
                        numero: "3",
                        texto: "Clique em 'Registrar Entrada' para liberar o acesso e atualizar as métricas da arena.",
                      ),
                      SizedBox(height: 10),
                      _ItemInstrucao(
                        numero: "4",
                        texto: "Consulte o menu 'Status da Arena' para monitorar os clientes atualmente ativos nas quadras.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Overlay de Destaque da Ação Principal (Tutorial)
          if (_mostrarTutorial)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _mostrarTutorial = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Stack(
                    children: [
                      // Card verde duplicado em cima do overlay para dar destaque
                      Positioned(
                        top: 110, // Posição aproximada sob o App Bar
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B7F38),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ESCANEAR\nQR CODE",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Registre a entrada de usuários",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF09398E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tooltip explicativo
                      Positioned(
                        top: 235,
                        left: 20,
                        right: 20,
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ação principal",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF09398E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Use o scanner para registrar a entrada de usuários de forma rápida e segura.",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Indicador de progresso (pontinhos)
                                    Row(
                                      children: [
                                        _construirPontoProgresso(ativo: true),
                                        const SizedBox(width: 6),
                                        _construirPontoProgresso(ativo: false),
                                        const SizedBox(width: 6),
                                        _construirPontoProgresso(ativo: false),
                                        const SizedBox(width: 6),
                                        _construirPontoProgresso(ativo: false),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _mostrarTutorial = false;
                                        });
                                      },
                                      child: const Text(
                                        "Entendi",
                                        style: TextStyle(
                                          color: Color(0xFF0B7F38),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Ícone de mão clicando no botão de seta
                      Positioned(
                        top: 135,
                        right: 35,
                        child: Icon(
                          Icons.touch_app,
                          color: Colors.white.withOpacity(0.9),
                          size: 44,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _construirItemMenu({
    required IconData icone,
    required String titulo,
    required String subtitulo,
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF), // Azul bem claro
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icone,
                color: const Color(0xFF09398E), // Azul escuro
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09398E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF0B7F38), // Verde para setas do menu
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirPontoProgresso({required bool ativo}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: ativo ? const Color(0xFF0B7F38) : const Color(0xFFCBD5E1),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ItemInstrucao extends StatelessWidget {
  final String numero;
  final String texto;

  const _ItemInstrucao({
    required this.numero,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF0B7F38),
            shape: BoxShape.circle,
          ),
          child: Text(
            numero,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

