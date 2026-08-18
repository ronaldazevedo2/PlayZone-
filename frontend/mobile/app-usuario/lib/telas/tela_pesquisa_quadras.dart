import 'dart:async';
import 'package:flutter/material.dart';
import '../modelos/modelo_quadra.dart';
import '../servicos/servico_quadras.dart';

class TelaPesquisaQuadras extends StatefulWidget {
  const TelaPesquisaQuadras({super.key});

  @override
  State<TelaPesquisaQuadras> createState() => _TelaPesquisaQuadrasEstado();
}

class _TelaPesquisaQuadrasEstado extends State<TelaPesquisaQuadras> {
  final TextEditingController _controladorPesquisa = TextEditingController();
  List<QuadraEsportiva> _todasAsQuadras = [];
  List<QuadraEsportiva> _quadrasFiltradas = [];
  bool _estaCarregando = true;
  String _modalidadeSelecionada = 'Todas';
  Timer? _timerSincronizacao;

  List<String> get _modalidadesDisponiveis {
    final Set<String> modalidadesUnicas = {};

    for (final quadra in _todasAsQuadras) {
      final mod = quadra.modalidade.trim();
      if (mod.isNotEmpty && mod.toLowerCase() != 'null') {
        modalidadesUnicas.add(mod);
      }
      for (final subMod in quadra.listaModalidades) {
        final sub = subMod.trim();
        if (sub.isNotEmpty && sub.toLowerCase() != 'null') {
          modalidadesUnicas.add(sub);
        }
      }
    }

    final List<String> modalidadesOrdenadas = modalidadesUnicas.toList()
      ..sort((a, b) => a.compareTo(b));

    return ['Todas', ...modalidadesOrdenadas];
  }

  @override
  void initState() {
    super.initState();
    _controladorPesquisa.addListener(_filtrarQuadras);
    _carregarQuadrasDaApi();

    _timerSincronizacao = Timer.periodic(const Duration(seconds: 4), (_) {
      _carregarQuadrasSilencioso();
    });
  }

  @override
  void dispose() {
    _timerSincronizacao?.cancel();
    _controladorPesquisa.removeListener(_filtrarQuadras);
    _controladorPesquisa.dispose();
    super.dispose();
  }

  Future<void> _carregarQuadrasSilencioso() async {
    try {
      final quadras = await ServicoQuadras.obterQuadras();
      if (!mounted) return;
      setState(() {
        _todasAsQuadras = quadras;
        _filtrarQuadras();
      });
    } catch (_) {}
  }

  Future<void> _carregarQuadrasDaApi() async {
    setState(() {
      _estaCarregando = true;
    });

    try {
      final quadras = await ServicoQuadras.obterQuadras();
      if (!mounted) return;
      setState(() {
        _todasAsQuadras = quadras;
        _filtrarQuadras();
        _estaCarregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _todasAsQuadras = [];
        _filtrarQuadras();
        _estaCarregando = false;
      });
    }
  }

  void _filtrarQuadras() {
    final termo = _controladorPesquisa.text.toLowerCase().trim();

    setState(() {
      _quadrasFiltradas = _todasAsQuadras.where((quadra) {
        final bateuNome = quadra.nome.toLowerCase().contains(termo);
        final bateuLocalizacao = quadra.endereco.toLowerCase().contains(termo) ||
            quadra.bairro.toLowerCase().contains(termo);
        final bateuModalidadeTexto =
            quadra.modalidade.toLowerCase().contains(termo);

        final bateuTermo = termo.isEmpty ||
            bateuNome ||
            bateuLocalizacao ||
            bateuModalidadeTexto;

        bool bateuCategoria = true;
        if (_modalidadeSelecionada != 'Todas') {
          final filtro = _modalidadeSelecionada.toLowerCase().trim();
          final modQuadra = quadra.modalidade.toLowerCase().trim();
          final listaMods =
              quadra.listaModalidades.map((m) => m.toLowerCase().trim()).toList();

          bateuCategoria = modQuadra.contains(filtro) ||
              listaMods.any((m) => m.contains(filtro) || filtro.contains(m));
        }

        return bateuTermo && bateuCategoria;
      }).toList();
    });
  }

  void _selecionarModalidade(String modalidade) {
    setState(() {
      if (_modalidadeSelecionada == modalidade && modalidade != 'Todas') {
        _modalidadeSelecionada = 'Todas';
      } else {
        _modalidadeSelecionada = modalidade;
      }
      _filtrarQuadras();
    });
  }

  void _abrirDetalhesQuadra(String quadraId) {
    Navigator.pushNamed(
      context,
      '/quadras/detalhes',
      arguments: quadraId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF22C55E),
          onRefresh: _carregarQuadrasDaApi,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // BARRA DE PESQUISA SUPERIOR
                _construirBarraDePesquisa(),

                const SizedBox(height: 18),

                // CHIPS HORIZONTAIS DE SELEÇÃO DE MODALIDADE
                _construirCarrosselDeModalidades(),

                const SizedBox(height: 24),

                // TÍTULO DA SEÇÃO
                const Text(
                  'QUADRAS EM DESTAQUE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 14),

                // CONTEÚDO (CARREGANDO / LISTA DE CARDS / ESTADO VAZIO)
                if (_estaCarregando)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF22C55E)),
                    ),
                  )
                else if (_quadrasFiltradas.isEmpty)
                  _construirEstadoVazio()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _quadrasFiltradas.length,
                    itemBuilder: (context, index) {
                      final quadra = _quadrasFiltradas[index];
                      return _construirCardQuadra(quadra);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET: Campo de Busca Arredondado
  Widget _construirBarraDePesquisa() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _controladorPesquisa,
        decoration: InputDecoration(
          hintText: 'Encontrar quadras próximas...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF64748B),
            size: 22,
          ),
          suffixIcon: _controladorPesquisa.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF94A3B8), size: 18),
                  onPressed: () {
                    _controladorPesquisa.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // WIDGET: Carrossel de Chips de Categorias Esportivas
  Widget _construirCarrosselDeModalidades() {
    final modalidades = _modalidadesDisponiveis;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: modalidades.length,
        itemBuilder: (context, index) {
          final String nomeModalidade = modalidades[index];
          final bool selecionado = _modalidadeSelecionada == nomeModalidade;

          return GestureDetector(
            onTap: () => _selecionarModalidade(nomeModalidade),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: selecionado ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selecionado ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
                boxShadow: selecionado
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  nomeModalidade,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selecionado ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // WIDGET: Card de Quadra Individual (Conforme a Imagem de Referência)
  Widget _construirCardQuadra(QuadraEsportiva quadra) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEM COM BADGES FLUTUANTES (NOTA & DISPONÍVEL AGORA)
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  quadra.caminhoImagem,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F2C59), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.sports_soccer,
                            color: Color(0xFF22C55E),
                            size: 44,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            quadra.modalidade.isNotEmpty
                                ? quadra.modalidade
                                : 'Quadra Esportiva',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // BADGE DE AVALIAÇÃO ⭐ (Topo Direita)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        '${quadra.avaliacao}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // BADGE DISPONÍVEL AGORA (Base Esquerda da Imagem)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    quadra.estaDisponivel ? 'DISPONÍVEL AGORA' : 'INDISPONÍVEL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: quadra.estaDisponivel
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // CONTEÚDO DO CARD (NOME, ENDEREÇO E BOTÃO DE AÇÃO)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NOME DA QUADRA
                Text(
                  quadra.nome,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),

                // ENDEREÇO / LOCALIZAÇÃO
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${quadra.bairro}, ${quadra.endereco}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // BOTÃO DE AGENDAR AGORA (VERDE ESCURO ESTILIZADO)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _abrirDetalhesQuadra(quadra.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF476B39),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'RESERVAR AGORA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Estado Vazio Quando Nenhuma Quadra For Encontrada
  Widget _construirEstadoVazio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Color(0xFFCBD5E1),
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma quadra encontrada.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 6),
            Text(
              ' Tente pesquisar por outro nome, bairro ou modalidade.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
