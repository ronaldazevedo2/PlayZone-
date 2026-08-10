import 'dart:math';
import 'package:flutter/material.dart';
import '../estado_central.dart';
import 'tela_perfil_detalhado.dart';

class TelaStatusArena extends StatefulWidget {
  const TelaStatusArena({super.key});

  @override
  State<TelaStatusArena> createState() => _TelaStatusArenaEstado();
}

class _TelaStatusArenaEstado extends State<TelaStatusArena> {
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

  @override
  Widget build(BuildContext context) {
    // Estatísticas dinâmicas com base nos clientes
    final clientes = _estadoCentral.clientes;
    final totalDentro = clientes
        .where((c) => c.statusAcesso == TipoStatusAcesso.dentro)
        .length;
    final totalClientes = clientes.length;
    final totalFora = totalClientes - totalDentro;

    // Simula ocupação de quadras baseada nos clientes que estão dentro
    final quadrasOcupadas = clientes
        .where((c) => c.statusAcesso == TipoStatusAcesso.dentro)
        .map((c) => c.localReserva)
        .toSet();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF09398E),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "STATUS DA ARENA",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/notificacoes');
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF22C55E),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "QUADRAS", icon: Icon(Icons.sports_soccer)),
              Tab(text: "JOGADORES", icon: Icon(Icons.people_alt_outlined)),
            ],
          ),
        ),
        body: Column(
          children: [
            // Painel Superior de Ocupação Rápida
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    // Gráfico Circular de Ocupação
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: CustomPaint(
                            painter: PintorOcupacaoCircular(
                              valorPreenchido: totalDentro,
                              valorTotal: totalClientes,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$totalDentro/$totalClientes",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const Text(
                              "ATIVOS",
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF09398E),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),

                    // Legenda das cores
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirItemLegenda(
                            const Color(0xFF0B7F38),
                            "Dentro da Arena",
                            totalDentro,
                          ),
                          const SizedBox(height: 8),
                          _construirItemLegenda(
                            const Color(0xFFCBD5E1),
                            "Fora da Arena",
                            totalFora,
                          ),
                          const SizedBox(height: 8),
                          _construirItemLegenda(
                            const Color(0xFF09398E),
                            "Quadras em Uso",
                            quadrasOcupadas.length,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Conteúdo das Abas
            Expanded(
              child: TabBarView(
                children: [
                  // ABA 1: Quadras
                  _construirAbaQuadras(quadrasOcupadas),

                  // ABA 2: Jogadores Dentro e Fora
                  _construirAbaJogadores(clientes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirAbaQuadras(Set<String> quadrasOcupadas) {
    final listaQuadras = [
      {"nome": "Quadra A", "horario": "18:00 - 19:00"},
      {"nome": "Quadra B", "horario": "19:00 - 20:00"},
      {"nome": "Quadra C", "horario": "Livre"},
      {"nome": "Quadra D", "horario": "Livre"},
      {"nome": "Quadra E", "horario": "17:00 - 18:00"},
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: listaQuadras.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final q = listaQuadras[index];
        final nome = q["nome"]!;
        final horario = q["horario"]!;
        final ocupada =
            quadrasOcupadas.contains(nome) ||
            (horario != "Livre" &&
                index % 2 == 0); // Alguma simulação de ocupação fixa combinada

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ocupada
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sports_soccer,
                  color: ocupada
                      ? const Color(0xFF0B7F38)
                      : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      horario == "Livre" && ocupada
                          ? "Ocupação imediata"
                          : horario,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ocupada
                      ? const Color(0xFF0B7F38)
                      : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: ocupada
                        ? const Color(0xFF0B7F38)
                        : const Color(0xFFCBD5E1),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ocupada ? "OCUPADA" : "LIVRE",
                  style: TextStyle(
                    color: ocupada ? Colors.white : const Color(0xFF64748B),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construirAbaJogadores(List<ClienteArena> clientes) {
    final jogadoresDentro = clientes
        .where((c) => c.statusAcesso == TipoStatusAcesso.dentro)
        .toList();
    final jogadoresFora = clientes
        .where((c) => c.statusAcesso != TipoStatusAcesso.dentro)
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        // Seção Dentro da Arena
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Dentro da Arena",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF09398E),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0B7F38).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${jogadoresDentro.length} ativos",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B7F38),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (jogadoresDentro.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Nenhum jogador dentro da arena no momento.",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jogadoresDentro.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final jogador = jogadoresDentro[index];
              return _construirCardJogadorArena(jogador, true);
            },
          ),

        const SizedBox(height: 24),

        // Seção Fora da Arena
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Fora da Arena (Cadastrados)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            Text(
              "${jogadoresFora.length} cadastrados",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (jogadoresFora.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Todos os jogadores estão dentro.",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jogadoresFora.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final jogador = jogadoresFora[index];
              return _construirCardJogadorArena(jogador, false);
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _construirCardJogadorArena(ClienteArena jogador, bool estaDentro) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TelaPerfilDetalhado(cliente: jogador),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(jogador.fotoUrl),
              backgroundColor: const Color(0xFFE2E8F0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jogador.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${jogador.localReserva} • ${jogador.horarioPrevisto}",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: estaDentro
                    ? Colors.red.shade50
                    : const Color(0xFF0B7F38),
                foregroundColor: estaDentro ? Colors.red : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                minimumSize: const Size(60, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (estaDentro) {
                  _estadoCentral.registrarSaida(jogador);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Saída registrada para ${jogador.nome}!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  _estadoCentral.registrarEntrada(jogador);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Entrada registrada para ${jogador.nome}!"),
                      backgroundColor: const Color(0xFF0B7F38),
                    ),
                  );
                }
              },
              child: Text(
                estaDentro ? "SAÍDA" : "ENTRADA",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirItemLegenda(Color cor, String rotulo, int quantidade) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            rotulo,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Text(
          quantidade.toString(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

// Pintor customizado para desenhar a rosca de progresso
class PintorOcupacaoCircular extends CustomPainter {
  final int valorPreenchido;
  final int valorTotal;

  PintorOcupacaoCircular({
    required this.valorPreenchido,
    required this.valorTotal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = (min(size.width, size.height) - 14) / 2;
    const espessura = 10.0;

    // Pintar fundo cinza
    final pincelFundo = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = espessura
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(centro, raio, pincelFundo);

    // Pintar progresso verde
    final pincelProgresso = Paint()
      ..color = const Color(0xFF0B7F38)
      ..strokeWidth = espessura
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (valorTotal > 0) {
      final anguloVarredura = (valorPreenchido / valorTotal) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: raio),
        -pi / 2, // Começar do topo (-90 graus)
        anguloVarredura,
        false,
        pincelProgresso,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PintorOcupacaoCircular oldDelegate) {
    return oldDelegate.valorPreenchido != valorPreenchido ||
        oldDelegate.valorTotal != valorTotal;
  }
}
