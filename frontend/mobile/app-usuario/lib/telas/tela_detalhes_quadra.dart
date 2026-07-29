import 'package:flutter/material.dart';
import '../modelos/modelo_quadra.dart';
import '../modelos/modelo_reserva.dart';
import '../servicos/servico_quadras.dart';
import '../servicos/servico_reservas.dart';

class TelaDetalhesQuadra extends StatefulWidget {
  final String quadraId;

  const TelaDetalhesQuadra({
    super.key,
    required this.quadraId,
  });

  @override
  State<TelaDetalhesQuadra> createState() => _TelaDetalhesQuadraEstado();
}

class _TelaDetalhesQuadraEstado extends State<TelaDetalhesQuadra> {
  QuadraEsportiva? _quadra;
  bool _carregandoQuadra = true;
  bool _carregandoReservas = false;

  DateTime _dataSelecionada = DateTime.now();
  String? _horarioSelecionado;
  List<ModeloReserva> _reservas = [];

  final List<String> _horariosDisponiveis = [
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() {
      _carregandoQuadra = true;
    });

    try {
      final quadra = await ServicoQuadras.obterQuadraPorId(widget.quadraId);
      if (!mounted) return;
      setState(() {
        _quadra = quadra;
        _carregandoQuadra = false;
      });
      _carregarReservasDaData();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregandoQuadra = false;
      });
    }
  }

  Future<void> _carregarReservasDaData() async {
    setState(() {
      _carregandoReservas = true;
      _horarioSelecionado = null;
    });

    try {
      final reservas = await ServicoReservas.obterReservasPorQuadraEData(
        widget.quadraId,
        _dataSelecionada,
      );
      if (!mounted) return;
      setState(() {
        _reservas = reservas;
        _carregandoReservas = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reservas = [];
        _carregandoReservas = false;
      });
    }
  }

  bool _verificarSeHorarioEstaReservado(String horario) {
    return _reservas.any((reserva) {
      final mesmaQuadra = reserva.quadraId == widget.quadraId;
      final mesmaData = reserva.dataAgendada.year == _dataSelecionada.year &&
          reserva.dataAgendada.month == _dataSelecionada.month &&
          reserva.dataAgendada.day == _dataSelecionada.day;
      final mesmoHorario = reserva.horarioAgendado == horario;
      return mesmaQuadra && mesmaData && mesmoHorario;
    });
  }

  Future<void> _confirmarAgendamento() async {
    if (_horarioSelecionado == null || _quadra == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um horário livre antes de agendar.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final novaReserva = ModeloReserva(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      quadraId: widget.quadraId,
      dataAgendada: _dataSelecionada,
      horarioAgendado: _horarioSelecionado!,
    );

    final sucesso = await ServicoReservas.criarReserva(novaReserva);

    if (!mounted) return;

    if (sucesso) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 28),
              SizedBox(width: 10),
              Text('Reserva Confirmada!'),
            ],
          ),
          content: Text(
            'Sua reserva para a quadra ${_quadra!.nome} no dia '
            '${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year} '
            'às $_horarioSelecionado foi solicitada com sucesso!',
            style: const TextStyle(color: Color(0xFF475569)),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _carregarReservasDaData();
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoQuadra) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF22C55E)),
        ),
      );
    }

    final quadra = _quadra ??
        QuadraEsportiva(
          id: widget.quadraId,
          nome: 'ARENA CENTRAL - QUADRA A',
          modalidade: 'Sintético Pro',
          bairro: 'São Paulo',
          endereco: 'Rua dos Atletas, 1500',
          capacidade: 10,
          descricao:
              'Quadra oficial com gramado sintético de última geração, iluminação em LED e vestiários premium.',
          precoPorHora: 150.0,
          estaDisponivel: true,
          distanciaEmKm: 2.5,
          caminhoImagem:
              'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop',
        );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // GALERIA DE IMAGENS (Principal + Miniatura com "+5")
                  _construirGaleriaDeImagens(quadra),

                  const SizedBox(height: 20),

                  // CABEÇALHO DO NOME DA ARENA E SININHO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          quadra.nome.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),

                  // LOCALIZAÇÃO
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${quadra.endereco}, ${quadra.bairro}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // BADGES DE CAPACIDADE E MODALIDADE
                  Row(
                    children: [
                      _construirBadgeInfo(
                        icone: Icons.groups_outlined,
                        texto: '${quadra.capacidade} jogadores',
                      ),
                      const SizedBox(width: 10),
                      _construirBadgeInfo(
                        icone: Icons.sports_soccer_outlined,
                        texto: quadra.modalidade,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // DESCRIÇÃO
                  Text(
                    quadra.descricao,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // SEÇÃO HORÁRIOS DE HOJE + LEGENDA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Horários de Hoje',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Row(
                        children: [
                          _construirIndicadorLegenda(
                            cor: const Color(0xFF22C55E),
                            label: 'LIVRE',
                          ),
                          const SizedBox(width: 12),
                          _construirIndicadorLegenda(
                            cor: const Color(0xFFCBD5E1),
                            label: 'OCUPADO',
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // SELETOR DE DATAS HORIZONTAL
                  _construirSeletorDeDatas(),

                  const SizedBox(height: 20),

                  // GRID DE HORÁRIOS
                  if (_carregandoReservas)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF22C55E)),
                      ),
                    )
                  else
                    _construirGridHorarios(),

                  const SizedBox(height: 28),

                  // SEÇÃO LOCALIZAÇÃO (MAPA)
                  const Text(
                    'Localização',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _construirCardMapa(),
                ],
              ),
            ),
          ),

          // BARRA FIXA DE AGENDAMENTO NO RODAPÉ
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _construirBarraInferiorFixa(quadra),
          ),
        ],
      ),
    );
  }

  // WIDGET: Galeria de Imagens com Imagem Principal e Miniatura "+5"
  Widget _construirGaleriaDeImagens(QuadraEsportiva quadra) {
    return Row(
      children: [
        // Imagem Principal Maior
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              quadra.caminhoImagem,
              height: 210,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 210,
                color: const Color(0xFFE2E8F0),
                child: const Icon(Icons.stadium, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Miniaturas na Direita
        Expanded(
          flex: 1,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?q=80&w=300&auto=format&fit=crop',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '+5',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF254EDB),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirBadgeInfo({required IconData icone, required String texto}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 16, color: const Color(0xFF1E293B)),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirIndicadorLegenda({
    required Color cor,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // WIDGET: Seletor de Datas (HOJE, TER, QUA, QUI, SEX)
  Widget _construirSeletorDeDatas() {
    final hoje = DateTime.now();
    final diasDaSemanaSiglas = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];

    return SizedBox(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, idx) {
          final dataOpcao = hoje.add(Duration(days: idx));
          final ehMesmoDia = dataOpcao.year == _dataSelecionada.year &&
              dataOpcao.month == _dataSelecionada.month &&
              dataOpcao.day == _dataSelecionada.day;

          final stringDia = idx == 0 ? 'HOJE' : diasDaSemanaSiglas[dataOpcao.weekday % 7];

          return GestureDetector(
            onTap: () {
              setState(() {
                _dataSelecionada = DateTime(
                  dataOpcao.year,
                  dataOpcao.month,
                  dataOpcao.day,
                );
              });
              _carregarReservasDaData();
            },
            child: Container(
              width: 58,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: ehMesmoDia ? const Color(0xFF192252) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ehMesmoDia ? const Color(0xFF192252) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stringDia,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: ehMesmoDia ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dataOpcao.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ehMesmoDia ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // WIDGET: Grid 3 Colunas para Horários
  Widget _construirGridHorarios() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _horariosDisponiveis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, idx) {
        final horario = _horariosDisponiveis[idx];
        final estaReservado = _verificarSeHorarioEstaReservado(horario);
        final estaSelecionado = _horarioSelecionado == horario;

        Color corFundo;
        Color corBorda;
        Color corTexto;

        if (estaReservado) {
          // Horário Ocupado -> Cinza e Desabilitado
          corFundo = const Color(0xFFE2E8F0);
          corBorda = const Color(0xFFE2E8F0);
          corTexto = const Color(0xFF94A3B8);
        } else if (estaSelecionado) {
          // Horário Livre Selecionado -> Verde preenchido
          corFundo = const Color(0xFF22C55E);
          corBorda = const Color(0xFF22C55E);
          corTexto = Colors.white;
        } else {
          // Horário Livre Não Selecionado -> Fundo claro, borda e texto verde
          corFundo = Colors.white;
          corBorda = const Color(0xFF22C55E);
          corTexto = const Color(0xFF22C55E);
        }

        return GestureDetector(
          onTap: estaReservado
              ? null
              : () {
                  setState(() {
                    _horarioSelecionado = horario;
                  });
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: corFundo,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: corBorda, width: 1.5),
            ),
            child: Center(
              child: Text(
                horario,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: corTexto,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // WIDGET: Card de Preview do Mapa
  Widget _construirCardMapa() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            color: Color(0xFF192252),
            size: 28,
          ),
        ),
      ),
    );
  }

  // WIDGET: Barra Inferior Fixa com Valor e Botão Agendar Agora
  Widget _construirBarraInferiorFixa(QuadraEsportiva quadra) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VALOR DA RESERVA',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _horarioSelecionado != null
                      ? 'R\$ ${quadra.precoPorHora.toStringAsFixed(0)}'
                      : '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: _horarioSelecionado != null ? _confirmarAgendamento : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'AGENDAR AGORA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.bolt, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
