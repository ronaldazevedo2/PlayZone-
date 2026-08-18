import 'dart:async';
import 'package:flutter/material.dart';
import '../modelos/modelo_quadra.dart';
import '../servicos/servico_autenticacao.dart';
import '../servicos/servico_quadras.dart';
import 'tela_meus_agendamentos.dart';
import 'tela_pesquisa_quadras.dart';
import 'tela_perfil_usuario.dart';

class TelaInicial extends StatefulWidget {
  final SessaoUsuario sessao;
  final int abaInicial;

  const TelaInicial({
    super.key,
    required this.sessao,
    this.abaInicial = 0,
  });

  @override
  State<TelaInicial> createState() => _TelaInicialEstado();
}

class _TelaInicialEstado extends State<TelaInicial> {
  late SessaoUsuario _sessaoAtual;
  String? _bairroFiltrado;
  String _modalidadeSelecionada = 'Todas';
  List<QuadraEsportiva> _quadrasFiltradas = [];
  late int _abaSelecionada;

  // Lista dinâmica de quadras carregadas da API
  List<QuadraEsportiva> _todasAsQuadras = [];
  bool _estaCarregando = false;
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
    _sessaoAtual = widget.sessao;
    _abaSelecionada = widget.abaInicial;

    // Busca assíncrona das quadras diretamente da API ao carregar a página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buscarQuadrasDaApi();
    });

    // Sincronização automática silenciosa a cada 4 segundos
    _timerSincronizacao = Timer.periodic(const Duration(seconds: 4), (_) {
      _atualizarQuadrasSilencioso();
    });
  }

  @override
  void dispose() {
    _timerSincronizacao?.cancel();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _buscarQuadrasDaApi();
  }

  Future<void> _atualizarQuadrasSilencioso() async {
    try {
      final quadras = await ServicoQuadras.obterQuadras();
      if (!mounted) return;
      setState(() {
        _todasAsQuadras = quadras;
        _filtrarQuadras();
      });
    } catch (_) {}
  }

  Future<void> _buscarQuadrasDaApi() async {
    if (!mounted) return;
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
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _todasAsQuadras = _obterQuadrasPadraoHandler();
        _filtrarQuadras();
        _estaCarregando = false;
      });
    }
  }

  List<QuadraEsportiva> _obterQuadrasPadraoHandler() {
    final dtos = [
      {
        'id': '11111111-1111-1111-1111-111111111111',
        'nome': 'ARENA BASQUETE ARAÇÁ',
        'descricao': 'Quadra de basquete coberta no bairro Araçá.',
        'localizacao': 'Rua das Palmeiras, 250 - Araçá',
        'capacidade': 10,
        'modalidade': 'Basquete',
        'imagemUrl': 'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=600&auto=format&fit=crop',
        'status': 'Ativa',
      },
      {
        'id': '22222222-2222-2222-2222-222222222222',
        'nome': 'ARENA FUTEBOL SÃO JOSÉ',
        'descricao': 'Campo oficial de futebol com gramado sintético.',
        'localizacao': 'Rua dos Atletas, 100 - São José',
        'capacidade': 14,
        'modalidade': 'Futebol',
        'imagemUrl': 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop',
        'status': 'Ativa',
      },
      {
        'id': '33333333-3333-3333-3333-333333333333',
        'nome': 'GINÁSIO DE FUTSAL INTERLAGOS',
        'descricao': 'Quadra de futsal com piso vinílico especial.',
        'localizacao': 'Av. Esportiva, 500 - Interlagos',
        'capacidade': 12,
        'modalidade': 'Futsal',
        'imagemUrl': 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=600&auto=format&fit=crop',
        'status': 'Ativa',
      },
      {
        'id': '44444444-4444-4444-4444-444444444444',
        'nome': 'ARENA VÔLEI CENTRO',
        'descricao': 'Quadra oficial com suporte a Vôlei.',
        'localizacao': 'Rua das Flores, 20 - Centro',
        'capacidade': 12,
        'modalidade': 'Vôlei',
        'imagemUrl': 'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?q=80&w=600&auto=format&fit=crop',
        'status': 'Ativa',
      },
    ];

    return dtos.map((dto) => QuadraEsportiva.deJson(dto)).toList();
  }

  void _ordenarPorDistancia() {
    _quadrasFiltradas.sort(
      (a, b) => a.distanciaEmKm.compareTo(b.distanciaEmKm),
    );
  }

  void _filtrarQuadras() {
    setState(() {
      _quadrasFiltradas = _todasAsQuadras.where((quadra) {
        bool bateuBairro = true;
        if (_bairroFiltrado != null && _bairroFiltrado!.isNotEmpty) {
          final filtro = _bairroFiltrado!.toLowerCase().trim();
          final bairroQuadra = quadra.bairro.toLowerCase().trim();
          final enderecoQuadra = quadra.endereco.toLowerCase().trim();
          bateuBairro = bairroQuadra == filtro ||
              bairroQuadra.contains(filtro) ||
              enderecoQuadra.contains(filtro);
        }

        bool bateuModalidade = true;
        if (_modalidadeSelecionada != 'Todas') {
          final filtroMod = _modalidadeSelecionada.toLowerCase().trim();
          final modQuadra = quadra.modalidade.toLowerCase().trim();
          final listaMods =
              quadra.listaModalidades.map((m) => m.toLowerCase().trim()).toList();
          bateuModalidade = modQuadra.contains(filtroMod) ||
              listaMods.any((m) => m.contains(filtroMod) || filtroMod.contains(m));
        }

        return bateuBairro && bateuModalidade;
      }).toList();
      _ordenarPorDistancia();
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

  void _selecionarBairro(String bairro) {
    setState(() {
      if (_bairroFiltrado == bairro) {
        _bairroFiltrado = null;
      } else {
        _bairroFiltrado = bairro;
      }
      _filtrarQuadras();
    });
  }

  void _limparFiltroBairro() {
    setState(() {
      _bairroFiltrado = null;
      _filtrarQuadras();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: IndexedStack(
        index: _abaSelecionada,
        children: [
          // ABA 0: Home
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _buscarQuadrasDaApi,
              color: const Color(0xFF22C55E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Logo PLAYZONE Centralizada (Sem campo de pesquisa e sem sininho)
                    _construirCabecalho(),

                    // Chips horizontais de seleção de modalidade extraídos dinamicamente
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _construirCarrosselDeModalidades(),
                    ),

                    // Indicador de progresso se estiver carregando
                    if (_estaCarregando)
                      const LinearProgressIndicator(
                        color: Color(0xFF22C55E),
                        backgroundColor: Color(0xFFEFF6FF),
                      ),

                    const SizedBox(height: 12),

                    // Indicador de filtro ativo (Bairro)
                    if (_bairroFiltrado != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            InputChip(
                              label: Text(
                                'Bairro: $_bairroFiltrado',
                                style: const TextStyle(
                                  color: Color(0xFF254EDB),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: const Color(0xFFEFF6FF),
                              deleteIconColor: const Color(0xFF254EDB),
                              onDeleted: _limparFiltroBairro,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // 2. Seção Quadras Próximas
                    _construirSecaoQuadrasProximas(),
                    const SizedBox(height: 32),

                    // 3. Seção Explorar por Bairro
                    _construirSecaoBairros(),
                    const SizedBox(height: 32),

                    // 4. Banner Premium
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _construirBannerPremium(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // ABA 1: Pesquisa de Quadras (Search)
          const TelaPesquisaQuadras(),

          // ABA 2: Agendamentos
          const TelaMeusAgendamentos(),

          // ABA 3: Perfil
          TelaPerfilUsuario(
            sessao: _sessaoAtual,
            aoVoltar: () {
              setState(() {
                _abaSelecionada = 0;
              });
            },
          ),
        ],
      ),
      // 5. Barra de Navegação Inferior Customizada (Ativo em VERDE)
      bottomNavigationBar: _construirBarraNavegacao(),
    );
  }



  // WIDGET: Cabeçalho (Apenas Logo PLAYZONE Centralizada - Sem Sininho e Sem Campo de Busca)
  Widget _construirCabecalho() {
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
                style: TextStyle(color: Color(0xFF0F172A)), // Quase preto
              ),
              TextSpan(
                text: 'ZONE',
                style: TextStyle(color: Color(0xFF22C55E)), // Verde
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET: Carrossel de Chips de Categorias Esportivas (Dinamico do BD)
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
                  color: selecionado
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: selecionado
                    ? [
                        BoxShadow(
                          color:
                              const Color(0xFF1E293B).withValues(alpha: 0.15),
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
                    color:
                        selecionado ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // WIDGET: Seção Quadras Próximas
  Widget _construirSecaoQuadrasProximas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _bairroFiltrado != null
                    ? 'QUADRAS EM ${_bairroFiltrado!.toUpperCase()}'
                    : 'QUADRAS PRÓXIMAS',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _abaSelecionada = 1;
                  });
                },
                child: const Row(
                  children: [
                    Text(
                      'Ver Todas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF254EDB),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFF254EDB),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _quadrasFiltradas.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    'Não há quadras disponíveis.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: 275,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _quadrasFiltradas.length,
                  itemBuilder: (context, index) {
                    final quadra = _quadrasFiltradas[index];
                    return _construirCardQuadra(quadra);
                  },
                ),
              ),
      ],
    );
  }

  // WIDGET: Card de Quadra Individual
  Widget _construirCardQuadra(QuadraEsportiva quadra) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/quadras/detalhes',
          arguments: quadra.id,
        );
      },
      child: Container(
        width: 230,
        margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem da Quadra + Tag Disponível
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'imagem_quadra_${quadra.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.network(
                          quadra.caminhoImagem,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
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
                                      size: 38,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      quadra.modalidade.isNotEmpty
                                          ? quadra.modalidade
                                          : 'Quadra Esportiva',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (quadra.estaDisponivel)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Disponível',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Informações do card
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome
                  Text(
                    quadra.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Localização (Bairro)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF94A3B8),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          quadra.bairro,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rodapé do card: Botão Agendar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Agendar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Seção Explorar por Localidade
  Widget _construirSecaoBairros() {
    final mapaLocalidades = _obterLocalidadesComContagem();
    final iconesDisponiveis = [
      Icons.home_work_outlined,
      Icons.domain_outlined,
      Icons.apartment_outlined,
      Icons.location_city_outlined,
      Icons.map_outlined,
    ];

    final entradas = mapaLocalidades.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'EXPLORAR POR LOCALIDADE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (entradas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Text(
              'Não há quadras disponíveis.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          )
        else
          ...entradas.asMap().entries.map((itemIndice) {
            final indice = itemIndice.key;
            final item = itemIndice.value;
            final icone = iconesDisponiveis[indice % iconesDisponiveis.length];

            return _construirItemBairro(
              nomeBairro: item.key,
              quantidadeQuadras: item.value,
              icone: icone,
            );
          }),
      ],
    );
  }

  Map<String, int> _obterLocalidadesComContagem() {
    final Map<String, int> mapaLocalidades = {};
    for (final quadra in _todasAsQuadras) {
      final localidade = quadra.bairro.trim().isNotEmpty
          ? quadra.bairro.trim()
          : 'Centro';
      mapaLocalidades[localidade] = (mapaLocalidades[localidade] ?? 0) + 1;
    }
    return mapaLocalidades;
  }

  // WIDGET: Item de Bairro Individual
  Widget _construirItemBairro({
    required String nomeBairro,
    required int quantidadeQuadras,
    required IconData icone,
  }) {
    final bool estaSelecionado = _bairroFiltrado == nomeBairro;

    return GestureDetector(
      onTap: () => _selecionarBairro(nomeBairro),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: estaSelecionado ? const Color(0xFFF0F6FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: estaSelecionado
                ? const Color(0xFF1D4ED8)
                : const Color(0xFFE2E8F0),
            width: estaSelecionado ? 2.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: estaSelecionado
                  ? const Color(0xFF1D4ED8).withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: estaSelecionado ? 10 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2C59),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomeBairro,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$quantidadeQuadras Quadras disponíveis',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 20),
          ],
        ),
      ),
    );
  }

  // WIDGET: Banner Premium
  Widget _construirBannerPremium() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A2240),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2240).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SEJA PREMIUM',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Descontos exclusivos e prioridade em agendamentos de pico.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Serviço Premium em breve!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0A2240),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Saiba Mais',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.emoji_events,
              color: Colors.white.withValues(alpha: 0.8),
              size: 90,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Barra de Navegação Inferior (Ícones ativos em VERDE)
  Widget _construirBarraNavegacao() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _construirItemNavegacao(0, Icons.home, 'Início'),
          _construirItemNavegacao(1, Icons.search, 'Buscar'),
          _construirItemNavegacao(2, Icons.calendar_today_outlined, 'Agendamentos'),
          _construirItemNavegacao(3, Icons.person_outline, 'Perfil'),
        ],
      ),
    );
  }

  // WIDGET: Item de Navegação Individual (Destaque Ativo em VERDE)
  Widget _construirItemNavegacao(int index, IconData icone, String rotulo) {
    final bool estaAtivo = _abaSelecionada == index;

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          Navigator.pushNamed(context, '/perfil');
        } else {
          setState(() {
            _abaSelecionada = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: estaAtivo
                  ? const Color(0xFFDCFCE7) // Fundo VERDE CLARO quando ativo
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icone,
              color: estaAtivo
                  ? const Color(0xFF238838) // VERDE VIBRANTE quando ativo
                  : const Color(0xFF64748B),
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rotulo,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: estaAtivo ? FontWeight.bold : FontWeight.normal,
              color: estaAtivo
                  ? const Color(0xFF238838) // Texto VERDE quando ativo
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
