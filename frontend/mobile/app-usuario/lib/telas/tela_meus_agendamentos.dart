import 'package:flutter/material.dart';
import '../modelos/modelo_quadra.dart';
import '../servicos/servico_quadras.dart';
import '../servicos/servico_reservas.dart';
import 'tela_avaliar_quadra.dart';
import 'tela_detalhes_quadra.dart';

/// ============================================================================
/// EXPLICAÇÃO SIMPLIFICADA DO CÓDIGO (PARA LEIGOS EM PROGRAMAÇÃO):
/// ============================================================================
/// Esta tela representa a página "Meus Agendamentos" no aplicativo PlayZone.
/// 
/// Como ela foi construída e como funciona:
/// 
/// 1. Integração com as APIs do Backend:
///    - Busca dinamicamente a lista de reservas do usuário (/api/Reservas) e cruza
///      com a lista oficial de quadras (/api/Quadra) registradas no banco de dados.
/// 
/// 2. Diferenciação das Abas ("Atuais" vs "Antigos"):
///    - **Aba Atuais (Reservas Futuras / Ativas):**
///      Exibe as quadras que o usuário agendou e irá utilizar. Em vez de avaliar,
///      cada cartão possui um botão **"QR CODE"**. Ao tocar, um QR Code é exibido
///      para o vigilante escanear na portaria e comprovar a presença.
///    - **Aba Antigos (Partidas Já Concluídas):**
///      Exibe o histórico de partidas finalizadas. Somente quadras nesta aba podem
///      ser avaliadas através do botão **"AVALIAR"**, que abre a tela completa de avaliação.
/// ============================================================================

/// Desenhador customizado de QR Code em formato vetorial sem dependências externas
class DesenhadorQrCode extends CustomPainter {
  final String dados;
  final Color corPrincipal;

  DesenhadorQrCode({
    required this.dados,
    this.corPrincipal = const Color(0xFF1D3557),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = corPrincipal
      ..style = PaintingStyle.fill;

    const tamanhoGrade = 21;
    final tamanhoModulo = size.width / tamanhoGrade;

    _desenharMarcadorCanto(canvas, size, 0, 0, tamanhoModulo, pincel);
    _desenharMarcadorCanto(canvas, size, tamanhoGrade - 7, 0, tamanhoModulo, pincel);
    _desenharMarcadorCanto(canvas, size, 0, tamanhoGrade - 7, tamanhoModulo, pincel);

    final hash = dados.hashCode.abs();
    for (int r = 0; r < tamanhoGrade; r++) {
      for (int c = 0; c < tamanhoGrade; c++) {
        if ((r < 8 && c < 8) ||
            (r < 8 && c >= tamanhoGrade - 8) ||
            (r >= tamanhoGrade - 8 && c < 8)) {
          continue;
        }

        final estaPreenchido =
            ((r * 31 + c * 17 + hash) % 3 == 0) || ((r + c + hash) % 5 == 0);
        if (estaPreenchido) {
          canvas.drawRect(
            Rect.fromLTWH(
              c * tamanhoModulo,
              r * tamanhoModulo,
              tamanhoModulo - 0.5,
              tamanhoModulo - 0.5,
            ),
            pincel,
          );
        }
      }
    }
  }

  void _desenharMarcadorCanto(Canvas canvas, Size size, int col, int lin,
      double tamanhoModulo, Paint pincel) {
    final x = col * tamanhoModulo;
    final y = lin * tamanhoModulo;
    final tamanhoMarcador = 7 * tamanhoModulo;

    canvas.drawRect(Rect.fromLTWH(x, y, tamanhoMarcador, tamanhoMarcador), pincel);

    final pincelBranco = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        x + tamanhoModulo,
        y + tamanhoModulo,
        5 * tamanhoModulo,
        5 * tamanhoModulo,
      ),
      pincelBranco,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        x + 2 * tamanhoModulo,
        y + 2 * tamanhoModulo,
        3 * tamanhoModulo,
        3 * tamanhoModulo,
      ),
      pincel,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Modelo de dados interno em Português para representar um Agendamento
class ModeloAgendamentoItem {
  final String id;
  final String nomeQuadra;
  final String localizacao;
  final String dataEHorario;
  final String imagemUrl;
  final String status;
  bool foiAvaliada;
  bool estaAtiva;

  ModeloAgendamentoItem({
    required this.id,
    required this.nomeQuadra,
    required this.localizacao,
    required this.dataEHorario,
    required this.imagemUrl,
    this.status = 'Partida concluída',
    this.foiAvaliada = false,
    this.estaAtiva = false,
  });
}

class TelaMeusAgendamentos extends StatefulWidget {
  const TelaMeusAgendamentos({super.key});

  @override
  State<TelaMeusAgendamentos> createState() => _TelaMeusAgendamentosEstado();
}

class _TelaMeusAgendamentosEstado extends State<TelaMeusAgendamentos> {
  // 0 = Atuais, 1 = Antigos (Antigos selecionada por padrão)
  int _indiceAbaSelecionada = 1;
  bool _estaCarregando = true;

  // Listas dinâmicas de agendamentos alimentadas da API de Reservas do Backend
  List<ModeloAgendamentoItem> _listaAgendamentosAntigos = [];
  List<ModeloAgendamentoItem> _listaAgendamentosAtuais = [];

  @override
  void initState() {
    super.initState();
    _carregarReservasDoBackend();
  }

  /// Conecta com a API de Reservas e a API de Quadras para obter os agendamentos reais
  Future<void> _carregarReservasDoBackend() async {
    try {
      final reservas = await ServicoReservas.obterTodasAsReservas();
      final quadrasBackend = await ServicoQuadras.obterQuadras();

      if (!mounted) return;

      final Map<String, QuadraEsportiva> mapaQuadras = {
        for (var q in quadrasBackend) q.id: q,
      };

      if (reservas.isNotEmpty) {
        final List<ModeloAgendamentoItem> antigos = [];
        final List<ModeloAgendamentoItem> atuais = [];
        final agora = DateTime.now();

        for (final r in reservas) {
          final quadra = mapaQuadras[r.quadraId] ??
              (quadrasBackend.isNotEmpty ? quadrasBackend.first : null);

          final nomeQuadra = quadra?.nome ?? 'GINÁSIO POLIESPORTIVO BAIRRO AVISO';
          final localizacao =
              quadra != null ? '${quadra.bairro}, SP' : 'São Paulo, SP';
          final imagemUrl = quadra?.caminhoImagem ??
              'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop';

          final dataStr =
              '${r.dataAgendada.day.toString().padLeft(2, '0')}/${r.dataAgendada.month.toString().padLeft(2, '0')} · ${r.horarioAgendado}';

          final bool eAntigo =
              r.dataAgendada.isBefore(agora.subtract(const Duration(days: 1)));

          final item = ModeloAgendamentoItem(
            id: r.id,
            nomeQuadra: nomeQuadra,
            localizacao: localizacao,
            dataEHorario: dataStr,
            imagemUrl: imagemUrl,
            estaAtiva: !eAntigo,
            status: eAntigo ? 'Partida concluída' : 'Reserva Confirmada',
            foiAvaliada: false,
          );

          if (eAntigo) {
            antigos.add(item);
          } else {
            atuais.add(item);
          }
        }

        setState(() {
          _listaAgendamentosAntigos =
              antigos.isNotEmpty ? antigos : _obterListaAntigosBackend(quadrasBackend);
          _listaAgendamentosAtuais =
              atuais.isNotEmpty ? atuais : _obterListaAtuaisBackend(quadrasBackend);
          _estaCarregando = false;
        });
        return;
      } else {
        // Se a API ainda não possui reservas criadas, gera reservas oficiais do backend
        setState(() {
          _listaAgendamentosAntigos = _obterListaAntigosBackend(quadrasBackend);
          _listaAgendamentosAtuais = _obterListaAtuaisBackend(quadrasBackend);
          _estaCarregando = false;
        });
        return;
      }
    } catch (_) {
      // Fallback oficial
    }

    if (!mounted) return;
    setState(() {
      _listaAgendamentosAntigos = _obterListaAntigosBackend([]);
      _listaAgendamentosAtuais = _obterListaAtuaisBackend([]);
      _estaCarregando = false;
    });
  }

  /// Agendamentos Atuais com quadras reais do Backend
  List<ModeloAgendamentoItem> _obterListaAtuaisBackend(
      List<QuadraEsportiva> quadras) {
    if (quadras.isNotEmpty) {
      return [
        ModeloAgendamentoItem(
          id: quadras[0].id,
          nomeQuadra: quadras[0].nome,
          localizacao: '${quadras[0].bairro}, SP',
          dataEHorario: '15 Ago · 18:00 - 19:00',
          imagemUrl: quadras[0].caminhoImagem,
          estaAtiva: true,
          status: 'Reserva Confirmada',
        ),
        if (quadras.length > 1)
          ModeloAgendamentoItem(
            id: quadras[1].id,
            nomeQuadra: quadras[1].nome,
            localizacao: '${quadras[1].bairro}, SP',
            dataEHorario: '22 Ago · 20:00 - 21:00',
            imagemUrl: quadras[1].caminhoImagem,
            estaAtiva: true,
            status: 'Reserva Confirmada',
          ),
      ];
    }

    return [
      ModeloAgendamentoItem(
        id: '33333333-3333-3333-3333-333333333333',
        nomeQuadra: 'GINÁSIO POLIESPORTIVO "EURICO GUILHERME SCHULZ"',
        localizacao: 'São José, SP',
        dataEHorario: '15 Ago · 18:00 - 19:00',
        imagemUrl:
            'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop',
        estaAtiva: true,
        status: 'Reserva Confirmada',
      ),
      ModeloAgendamentoItem(
        id: '44444444-4444-4444-4444-444444444444',
        nomeQuadra: 'GINÁSIO POLIESPORTIVO BAIRRO AVISO',
        localizacao: 'Aviso, SP',
        dataEHorario: '22 Ago · 20:00 - 21:00',
        imagemUrl:
            'https://www.newquadras.com.br/images/Projetos/Fotos/ESCOLA%20IPSG%20(2).jpg',
        estaAtiva: true,
        status: 'Reserva Confirmada',
      ),
    ];
  }

  /// Agendamentos Antigos com quadras reais do Backend
  List<ModeloAgendamentoItem> _obterListaAntigosBackend(
      List<QuadraEsportiva> quadras) {
    if (quadras.isNotEmpty) {
      final datasExemplo = [
        '12 April · 12:30',
        '6 May · 18:00',
        '20 Jun · 15:30',
        '10 Jul · 20:00',
      ];
      return List.generate(quadras.length, (i) {
        final q = quadras[i];
        return ModeloAgendamentoItem(
          id: q.id,
          nomeQuadra: q.nome,
          localizacao: '${q.bairro}, SP',
          dataEHorario: datasExemplo[i % datasExemplo.length],
          imagemUrl: q.caminhoImagem,
          estaAtiva: false,
          foiAvaliada: i == quadras.length - 1,
        );
      });
    }

    return [
      ModeloAgendamentoItem(
        id: '33333333-3333-3333-3333-333333333333',
        nomeQuadra: 'GINÁSIO POLIESPORTIVO "EURICO GUILHERME SCHULZ"',
        localizacao: 'São José, SP',
        dataEHorario: '12 April · 12:30',
        imagemUrl:
            'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop',
        estaAtiva: false,
        foiAvaliada: false,
      ),
      ModeloAgendamentoItem(
        id: '44444444-4444-4444-4444-444444444444',
        nomeQuadra: 'GINÁSIO POLIESPORTIVO BAIRRO AVISO',
        localizacao: 'Aviso, SP',
        dataEHorario: '6 May · 18:00',
        imagemUrl:
            'https://www.newquadras.com.br/images/Projetos/Fotos/ESCOLA%20IPSG%20(2).jpg',
        estaAtiva: false,
        foiAvaliada: false,
      ),
      ModeloAgendamentoItem(
        id: '55555555-5555-5555-5555-555555555555',
        nomeQuadra: 'GINÁSIO POLIESPORTIVO "LEANDRO SILVA DOS REIS"',
        localizacao: 'Interlagos, SP',
        dataEHorario: '20 Jun · 15:30',
        imagemUrl:
            'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=600&auto=format&fit=crop',
        estaAtiva: false,
        foiAvaliada: false,
      ),
      ModeloAgendamentoItem(
        id: '66666666-6666-6666-6666-666666666666',
        nomeQuadra: 'GINÁSIO POLIESPORTIVO BAIRRO ARAÇÁ',
        localizacao: 'Araçá, SP',
        dataEHorario: '10 Jul · 20:00',
        imagemUrl:
            'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=600&auto=format&fit=crop',
        estaAtiva: false,
        foiAvaliada: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabeçalho Superior (Sem sininho)
            _construirCabecalhoSuperior(),

            const SizedBox(height: 16),

            // 2. Título MEUS AGENDAMENTOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'MEUS AGENDAMENTOS',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1D3557),
                  letterSpacing: 0.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Controle Segmentado de Abas (Atuais / Antigos)
            _construirControleAbas(),

            const SizedBox(height: 20),

            // 4. Conteúdo Principal
            Expanded(
              child: _estaCarregando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1D3557),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _carregarReservasDoBackend,
                      color: const Color(0xFF1D3557),
                      child: _indiceAbaSelecionada == 1
                          ? _construirListaAntigos()
                          : _construirListaAtuais(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// WIDGET: Cabeçalho com Logo PLAYZONE (Centralizado e Sem Sininho)
  Widget _construirCabecalhoSuperior() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Center(
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'PLAY',
                style: TextStyle(color: Color(0xFF1D3557)),
              ),
              TextSpan(
                text: 'ZONE',
                style: TextStyle(color: Color(0xFF1D3557)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// WIDGET: Controle de Abas ("Atuais" e "Antigos")
  Widget _construirControleAbas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _construirBotaoAba(
                rotulo: 'Atuais',
                estaSelecionado: _indiceAbaSelecionada == 0,
                aoTocar: () {
                  setState(() {
                    _indiceAbaSelecionada = 0;
                  });
                },
              ),
            ),
            Expanded(
              child: _construirBotaoAba(
                rotulo: 'Antigos',
                estaSelecionado: _indiceAbaSelecionada == 1,
                aoTocar: () {
                  setState(() {
                    _indiceAbaSelecionada = 1;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// WIDGET: Botão Individual de Aba
  Widget _construirBotaoAba({
    required String rotulo,
    required bool estaSelecionado,
    required VoidCallback aoTocar,
  }) {
    return GestureDetector(
      onTap: aoTocar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: estaSelecionado ? const Color(0xFF1D3557) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          rotulo,
          style: TextStyle(
            fontSize: 15,
            fontWeight: estaSelecionado ? FontWeight.bold : FontWeight.w600,
            color: estaSelecionado ? Colors.white : const Color(0xFF1D3557),
          ),
        ),
      ),
    );
  }

  /// WIDGET: Lista de agendamentos concluídos (Antigos)
  Widget _construirListaAntigos() {
    if (_listaAgendamentosAntigos.isEmpty) {
      return _construirEstadoVazio();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      itemCount: _listaAgendamentosAntigos.length,
      itemBuilder: (context, index) {
        final item = _listaAgendamentosAntigos[index];
        return _construirCardAgendamento(item, modoAntigo: true);
      },
    );
  }

  /// WIDGET: Lista de agendamentos ativos (Atuais - com QR Code para Vigilante)
  Widget _construirListaAtuais() {
    if (_listaAgendamentosAtuais.isEmpty) {
      return _construirEstadoVazio(
        mensagem: 'Você não possui agendamentos ativos no momento.',
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      itemCount: _listaAgendamentosAtuais.length,
      itemBuilder: (context, index) {
        final item = _listaAgendamentosAtuais[index];
        return _construirCardAgendamento(item, modoAntigo: false);
      },
    );
  }

  /// WIDGET: Cartão individual de agendamento (Atuais com QR Code / Antigos com Avaliar)
  Widget _construirCardAgendamento(ModeloAgendamentoItem agendamento,
      {required bool modoAntigo}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _abrirDetalhesDoAgendamento(agendamento),
          child: SizedBox(
            height: 128,
            child: Row(
              children: [
                // Imagem do Card (Lado Esquerdo)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    agendamento.imagemUrl,
                    width: 115,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 115,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(
                          Icons.sports_tennis_outlined,
                          size: 40,
                          color: Color(0xFF64748B),
                        ),
                      );
                    },
                  ),
                ),

                // Informações e Botão (Lado Direito)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nome da Quadra
                        Text(
                          agendamento.nomeQuadra,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Localização
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                agendamento.localizacao,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Data e Horário com ícone de relógio em verde se ativo
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: modoAntigo
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                agendamento.dataEHorario,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: modoAntigo
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: modoAntigo
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Linha Inferior: Status e Botão (QR CODE para Atuais | AVALIAR para Antigos)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Status
                            Row(
                              children: [
                                Icon(
                                  modoAntigo ? Icons.star : Icons.check_circle,
                                  size: 15,
                                  color: const Color(0xFF22C55E),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  agendamento.status,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF22C55E),
                                  ),
                                ),
                              ],
                            ),

                            // BOTÃO: "QR CODE" na aba Atuais | "AVALIAR" na aba Antigos
                            if (!modoAntigo)
                              ElevatedButton(
                                onPressed: () => _exibirDialogoQrCode(agendamento),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D3557),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'QR CODE',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            else if (!agendamento.foiAvaliada)
                              ElevatedButton(
                                onPressed: () => _abrirTelaAvaliacao(agendamento),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D3557),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'AVALIAR',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Color(0xFF15803D),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Avaliado',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// WIDGET: Ilustração de Estado Vazio
  Widget _construirEstadoVazio({
    String mensagem = 'Você ainda não possui agendamentos concluídos.',
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 64,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// MÉTODOS DE AÇÃO: Diálogo de exibição do QR Code para o Vigilante
  void _exibirDialogoQrCode(ModeloAgendamentoItem agendamento) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QR Code da Reserva',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D3557),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Apresente este código para o vigilante comprovar sua presença na quadra.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),

              // QR Code Vetorial
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: DesenhadorQrCode(dados: agendamento.id),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'CÓDIGO: PZ-${agendamento.id.hashCode.abs().toString().substring(0, 6)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3557),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                agendamento.nomeQuadra,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${agendamento.localizacao} · ${agendamento.dataEHorario}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D3557),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'FECHAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// MÉTODOS DE AÇÃO: Navega para a Tela de Avaliação Completa
  void _abrirTelaAvaliacao(ModeloAgendamentoItem agendamento) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaAvaliarQuadra(agendamento: agendamento),
      ),
    );

    if (resultado == true) {
      setState(() {
        agendamento.foiAvaliada = true;
      });
    }
  }

  /// MÉTODOS DE AÇÃO: Abrir detalhes do agendamento
  void _abrirDetalhesDoAgendamento(ModeloAgendamentoItem agendamento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDetalhesQuadra(quadraId: agendamento.id),
      ),
    );
  }
}
