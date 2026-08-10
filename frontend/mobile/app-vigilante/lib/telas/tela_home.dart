import 'dart:async';
import 'package:flutter/material.dart';
import 'package:playzone_mobile/traducao.dart';
import 'tela_controle_acesso.dart';
import 'tela_status_arena.dart';
import '../estado_central.dart';

class TelaHome extends StatefulWidget {
  final Function(int) aoNavegarParaAba;

  const TelaHome({super.key, required this.aoNavegarParaAba});

  @override
  State<TelaHome> createState() => _TelaHomeEstado();
}

class _TelaHomeEstado extends State<TelaHome> {
  final EstadoCentral _estadoCentral = EstadoCentral();
  final PageController _controladorCarrossel = PageController();
  int _paginaCarrosselAtual = 0;
  Timer? _timerCarrossel;

  // Imagens de quadras esportivas do Unsplash
  final List<Map<String, String>> _imagensQuadras = [
    {
      'url': 'https://images.unsplash.com/photo-1529925130639-0f47a4892f7f?auto=format&fit=crop&w=800&q=80',
      'titulo': 'Quadra de Futsal',
      'subtitulo': 'Arena PlayZone',
    },
    {
      'url': 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?auto=format&fit=crop&w=800&q=80',
      'titulo': 'Beach Tennis',
      'subtitulo': 'Quadra Premium',
    },
    {
      'url': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80',
      'titulo': 'Natação & Esportes',
      'subtitulo': 'Complexo Aquático',
    },
    {
      'url': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
      'titulo': 'Musculação',
      'subtitulo': 'Academia PlayZone',
    },
  ];

  @override
  void initState() {
    super.initState();
    _estadoCentral.addListener(_aoAtualizarEstado);
    _iniciarTimerCarrossel();
  }

  @override
  void dispose() {
    _estadoCentral.removeListener(_aoAtualizarEstado);
    _timerCarrossel?.cancel();
    _controladorCarrossel.dispose();
    super.dispose();
  }

  void _aoAtualizarEstado() {
    if (mounted) setState(() {});
  }

  void _iniciarTimerCarrossel() {
    _timerCarrossel = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final proxima = (_paginaCarrosselAtual + 1) % _imagensQuadras.length;
      _controladorCarrossel.animateToPage(
        proxima,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  String _obterSaudacao() {
    final hora = DateTime.now().hour;
    final idioma = _estadoCentral.idiomaSelecionado;

    if (idioma == 'English') {
      if (hora < 12) return 'Good morning';
      if (hora < 18) return 'Good afternoon';
      return 'Good evening';
    } else if (idioma == 'Español') {
      if (hora < 12) return 'Buenos días';
      if (hora < 18) return 'Buenas tardes';
      return 'Buenas noches';
    } else {
      if (hora < 12) return 'Bom dia';
      if (hora < 18) return 'Boa tarde';
      return 'Boa noite';
    }
  }

  void _navegarParaControleAcesso() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TelaControleAcesso(aoNavegarParaAba: widget.aoNavegarParaAba),
      ),
    );
  }

  void _navegarParaStatusArena() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TelaStatusArena()),
    );
  }

  void _abrirHistorico() {
    widget.aoNavegarParaAba(2);
  }

  void _abrirBusca() {
    widget.aoNavegarParaAba(1);
  }

  @override
  Widget build(BuildContext context) {
    final ehEscuro = Theme.of(context).brightness == Brightness.dark;
    final vigilante = _estadoCentral.vigilanteLogado;
    final nomeExibido = vigilante != null ? vigilante.nome.split(' ').first : 'Vigilante';
    final saudacao = _obterSaudacao();

    // Estatísticas calculadas
    final totalEntradas = _estadoCentral.historico.length;
    final clientesDentro = _estadoCentral.clientes
        .where((c) => c.statusAcesso == TipoStatusAcesso.dentro)
        .length;
    final notificacoesNaoLidas = _estadoCentral.notificacoes
        .where((n) => !n.lida)
        .length;

    return Scaffold(
      backgroundColor: ehEscuro
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: ehEscuro
            ? const Color(0xFF1E293B)
            : const Color(0xFF09398E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.shield,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'PLAYZONE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () => Navigator.of(context).pushNamed('/notificacoes'),
              ),
              if (notificacoesNaoLidas > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        notificacoesNaoLidas > 9
                            ? '9+'
                            : '$notificacoesNaoLidas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Carrossel de Imagens de Quadras ─────────────────────────────
            _construirCarrossel(ehEscuro),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Saudação Personalizada ─────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$saudacao, $nomeExibido! 👋',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: ehEscuro
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Tradutor.obter('home_pronto'),
                              style: TextStyle(
                                fontSize: 13,
                                color: ehEscuro
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── Cards de Estatísticas Rápidas ───────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _construirCardEstatistica(
                          icone: Icons.login,
                          valor: '$totalEntradas',
                          rotulo: 'Entradas\nHoje',
                          cor: const Color(0xFF0B7F38),
                          ehEscuro: ehEscuro,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _construirCardEstatistica(
                          icone: Icons.people_outline,
                          valor: '$clientesDentro',
                          rotulo: 'Dentro\nAgora',
                          cor: const Color(0xFF09398E),
                          ehEscuro: ehEscuro,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _construirCardEstatistica(
                          icone: Icons.notifications_active_outlined,
                          valor: '$notificacoesNaoLidas',
                          rotulo: 'Alertas\nAtivos',
                          cor: notificacoesNaoLidas > 0
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF64748B),
                          ehEscuro: ehEscuro,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Card Principal - Escanear QR Code ──────────────────
                  _construirCardQRCode(ehEscuro),
                  const SizedBox(height: 28),

                  // ─── Menu Rápido ─────────────────────────────────────────
                  Text(
                    Tradutor.obter('home_atalhos'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ehEscuro
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _construirItemMenu(
                    icone: Icons.shield_outlined,
                    titulo: Tradutor.obter('home_controle_acesso'),
                    subtitulo: Tradutor.obter('home_gerencie_entradas'),
                    aoClicar: _navegarParaControleAcesso,
                    ehEscuro: ehEscuro,
                    corIcone: const Color(0xFF0B7F38),
                  ),
                  const SizedBox(height: 10),
                  _construirItemMenu(
                    icone: Icons.bar_chart_outlined,
                    titulo: Tradutor.obter('home_status_arena'),
                    subtitulo: Tradutor.obter('home_ocupacao_quadras'),
                    aoClicar: _navegarParaStatusArena,
                    ehEscuro: ehEscuro,
                    corIcone: const Color(0xFF09398E),
                  ),
                  const SizedBox(height: 10),
                  _construirItemMenu(
                    icone: Icons.access_time_outlined,
                    titulo: Tradutor.obter('home_historico_entradas'),
                    subtitulo: Tradutor.obter('home_consulte_entradas'),
                    aoClicar: _abrirHistorico,
                    ehEscuro: ehEscuro,
                    corIcone: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 10),
                  _construirItemMenu(
                    icone: Icons.search_outlined,
                    titulo: Tradutor.obter('home_buscar_usuarios'),
                    subtitulo: Tradutor.obter('home_procure_documento'),
                    aoClicar: _abrirBusca,
                    ehEscuro: ehEscuro,
                    corIcone: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 10),
                  _construirItemMenu(
                    icone: Icons.star_outline_rounded,
                    titulo: 'Enviar Feedback',
                    subtitulo: 'Avaliações e sugestões',
                    aoClicar: () =>
                        Navigator.of(context).pushNamed('/feedback'),
                    ehEscuro: ehEscuro,
                    corIcone: const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 28),

                  // ─── Instruções de Uso ───────────────────────────────────
                  Text(
                    Tradutor.obter('home_instrucoes'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ehEscuro
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ehEscuro
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ehEscuro
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tradutor.obter('home_como_operar'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ehEscuro
                                ? Colors.white
                                : const Color(0xFF09398E),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ItemInstrucao(
                          numero: '1',
                          texto: Tradutor.obter('home_passo1'),
                          ehEscuro: ehEscuro,
                        ),
                        const SizedBox(height: 8),
                        _ItemInstrucao(
                          numero: '2',
                          texto: Tradutor.obter('home_passo2'),
                          ehEscuro: ehEscuro,
                        ),
                        const SizedBox(height: 8),
                        _ItemInstrucao(
                          numero: '3',
                          texto: Tradutor.obter('home_passo3'),
                          ehEscuro: ehEscuro,
                        ),
                        const SizedBox(height: 8),
                        _ItemInstrucao(
                          numero: '4',
                          texto: Tradutor.obter('home_passo4'),
                          ehEscuro: ehEscuro,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCarrossel(bool ehEscuro) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controladorCarrossel,
            onPageChanged: (pagina) {
              setState(() => _paginaCarrosselAtual = pagina);
            },
            itemCount: _imagensQuadras.length,
            itemBuilder: (context, index) {
              final imagem = _imagensQuadras[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imagem['url']!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: ehEscuro
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0B7F38),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF09398E),
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 60,
                        color: Colors.white30,
                      ),
                    ),
                  ),
                  // Gradiente sobre a imagem
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                  // Texto sobre a imagem
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          imagem['titulo']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          imagem['subtitulo']!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // Indicadores de página
          Positioned(
            bottom: 10,
            right: 16,
            child: Row(
              children: List.generate(
                _imagensQuadras.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: _paginaCarrosselAtual == index ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _paginaCarrosselAtual == index
                        ? const Color(0xFF0B7F38)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCardEstatistica({
    required IconData icone,
    required String valor,
    required String rotulo,
    required Color cor,
    required bool ehEscuro,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ehEscuro ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: ehEscuro
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: cor, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ehEscuro ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rotulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: ehEscuro
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCardQRCode(bool ehEscuro) {
    return GestureDetector(
      onTap: _navegarParaControleAcesso,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B7F38), Color(0xFF065F27)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B7F38).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Tradutor.obter('home_escanear_qr'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Tradutor.obter('home_registre_entrada'),
                    style: const TextStyle(
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
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirItemMenu({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required VoidCallback aoClicar,
    required bool ehEscuro,
    required Color corIcone,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: aoClicar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ehEscuro
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: ehEscuro
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: corIcone.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: corIcone, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ehEscuro
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 11,
                        color: ehEscuro
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: ehEscuro
                    ? const Color(0xFF475569)
                    : const Color(0xFFCBD5E1),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemInstrucao extends StatelessWidget {
  final String numero;
  final String texto;
  final bool ehEscuro;

  const _ItemInstrucao({
    required this.numero,
    required this.texto,
    required this.ehEscuro,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
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
            style: TextStyle(
              fontSize: 13,
              color: ehEscuro
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
