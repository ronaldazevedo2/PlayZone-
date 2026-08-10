import 'package:flutter/material.dart';
import '../modelos/modelo_quadra.dart';
import '../servicos/servico_autenticacao.dart';
import '../servicos/servico_quadras.dart';
import 'tela_detalhes_quadra.dart';
import 'tela_meus_agendamentos.dart';
import 'tela_pesquisa_quadras.dart';
import 'tela_perfil_usuario.dart';

class TelaInicial extends StatefulWidget {
  final SessaoUsuario sessao;

  const TelaInicial({super.key, required this.sessao});

  @override
  State<TelaInicial> createState() => _TelaInicialEstado();
}

class _TelaInicialEstado extends State<TelaInicial> {
  late SessaoUsuario _sessaoAtual;
  String? _bairroFiltrado;
  List<QuadraEsportiva> _quadrasFiltradas = [];
  int _abaSelecionada = 0;

  // Lista dinâmica de quadras carregadas da API
  List<QuadraEsportiva> _todasAsQuadras = [];
  bool _estaCarregando = false;

  @override
  void initState() {
    super.initState();
    _sessaoAtual = widget.sessao;

    // Busca assíncrona das quadras diretamente da API ao carregar a página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buscarQuadrasDaApi();
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    _buscarQuadrasDaApi();
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
        _todasAsQuadras = quadras.isNotEmpty
            ? quadras
            : _obterQuadrasPadraoHandler();
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
        'id': '55555555-5555-5555-5555-555555555555',
        'nome': 'GINÁSIO POLIESPORTIVO "LEANDRO SILVA DOS REIS"',
        'descricao': 'Ginásio Poliesportivo localizado no bairro Interlagos.',
        'localizacao': 'Interlagos',
        'capacidade': 20,
        'modalidade': 'Futebol',
        'imagemUrl': 'https://exemplo.com/imagens/interlagos.jpg',
        'status': 'Ativa',
      },
      {
        'id': 'd1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'nome': 'ARENA SÃO JOSÉ',
        'descricao': 'Quadra oficial com gramado sintético e vestiários.',
        'localizacao': 'Rua dos Atletas, 100 - São José',
        'capacidade': 10,
        'modalidade': 'Futebol Society',
        'imagemUrl': 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop',
        'status': 'Ativa',
      },
      {
        'id': 'e2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e',
        'nome': 'GINÁSIO POLIESPORTIVO AVISO',
        'descricao': 'Quadra coberta com piso vinílico para futsal e basquete.',
        'localizacao': 'Av. Esportiva, 500 - Aviso',
        'capacidade': 12,
        'modalidade': 'Futsal e Basquete',
        'imagemUrl': 'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=600&auto=format&fit=crop',
        'status': 'Ativa',
      },
      {
        'id': 'f3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f',
        'nome': 'COMPLEXO TÊNIS CLUBE',
        'descricao': 'Quadra de saibro oficial com iluminação noturna.',
        'localizacao': 'Rua das Palmeiras, 250 - Centro',
        'capacidade': 4,
        'modalidade': 'Tênis',
        'imagemUrl': 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?q=80&w=600&auto=format&fit=crop',
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
        final matchesBairro =
            _bairroFiltrado == null || quadra.bairro == _bairroFiltrado;
        return matchesBairro;
      }).toList();
      _ordenarPorDistancia();
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
              const Text(
                'QUADRAS PRÓXIMAS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _limparFiltroBairro();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exibindo todas as quadras registradas.'),
                    ),
                  );
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaDetalhesQuadra(quadraId: quadra.id),
          ),
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
                            return Image.network(
                              'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop',
                              fit: BoxFit.cover,
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
                          '${quadra.bairro}, SP',
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

                  // Rodapé do card: Preço + Botão Agendar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Uso Gratuito',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
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
          _construirItemNavegacao(0, Icons.home, 'Home'),
          _construirItemNavegacao(1, Icons.search, 'Search'),
          _construirItemNavegacao(2, Icons.calendar_today_outlined, 'Bookings'),
          _construirItemNavegacao(3, Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  // WIDGET: Item de Navegação Individual (Destaque Ativo em VERDE)
  Widget _construirItemNavegacao(int index, IconData icone, String rotulo) {
    final bool estaAtivo = _abaSelecionada == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _abaSelecionada = index;
        });
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
