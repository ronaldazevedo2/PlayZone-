import 'package:flutter/material.dart';
import '../modelos/modelo_quadra.dart';
import '../servicos/servico_autenticacao.dart';
import '../servicos/servico_quadras.dart';
import 'tela_detalhes_quadra.dart';
import 'tela_login.dart';

class TelaInicial extends StatefulWidget {
  final SessaoUsuario sessao;

  const TelaInicial({super.key, required this.sessao});

  @override
  State<TelaInicial> createState() => _TelaInicialEstado();
}

class _TelaInicialEstado extends State<TelaInicial> {
  late SessaoUsuario _sessaoAtual;
  final TextEditingController _controladorBusca = TextEditingController();
  final FocusNode _buscaFoco = FocusNode();

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
    _controladorBusca.addListener(_filtrarQuadras);

    // Busca assíncrona das quadras diretamente da API ao carregar a página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buscarQuadrasDaApi();
    });
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
        _filtrarQuadras(); // Aplica filtros e ordena
        _estaCarregando = false;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _todasAsQuadras = [];
        _filtrarQuadras();
        _estaCarregando = false;
      });
    }
  }

  @override
  void dispose() {
    _controladorBusca.removeListener(_filtrarQuadras);
    _controladorBusca.dispose();
    _buscaFoco.dispose();
    super.dispose();
  }

  void _ordenarPorDistancia() {
    _quadrasFiltradas.sort(
      (a, b) => a.distanciaEmKm.compareTo(b.distanciaEmKm),
    );
  }

  void _filtrarQuadras() {
    final query = _controladorBusca.text.toLowerCase().trim();
    setState(() {
      _quadrasFiltradas = _todasAsQuadras.where((quadra) {
        final matchesNome = quadra.nome.toLowerCase().contains(query);
        final matchesModalidade = quadra.modalidade.toLowerCase().contains(
          query,
        );
        final matchesBairro =
            _bairroFiltrado == null || quadra.bairro == _bairroFiltrado;
        return (matchesNome || matchesModalidade) && matchesBairro;
      }).toList();
      _ordenarPorDistancia();
    });
  }

  void _selecionarBairro(String bairro) {
    setState(() {
      _bairroFiltrado = bairro;
      _filtrarQuadras();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtrando quadras em $bairro'),
        action: SnackBarAction(
          label: 'Limpar',
          textColor: Colors.white,
          onPressed: _limparFiltroBairro,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _limparFiltroBairro() {
    setState(() {
      _bairroFiltrado = null;
      _filtrarQuadras();
    });
  }

  void _fazerLogout() async {
    await ServicoAutenticacao.encerrarSessao();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaLoginUsuario()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _buscarQuadrasDaApi,
          color: const Color(0xFF22C55E),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Cabeçalho Customizado
                _construirCabecalho(),

                // Indicador de progresso se estiver carregando
                if (_estaCarregando)
                  const LinearProgressIndicator(
                    color: Color(0xFF22C55E),
                    backgroundColor: Color(0xFFEFF6FF),
                  ),

                const SizedBox(height: 16),

                // 2. Barra de Busca
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _construirBarraBusca(),
                ),
                const SizedBox(height: 8),

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
                const SizedBox(height: 24),

                // 3. Seção Quadras Próximas
                _construirSecaoQuadrasProximas(),
                const SizedBox(height: 32),

                // 4. Seção Explorar por Bairro
                _construirSecaoBairros(),
                const SizedBox(height: 32),

                // 5. Banner Premium
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _construirBannerPremium(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      // 6. Barra de Navegação Inferior Customizada
      bottomNavigationBar: _construirBarraNavegacao(),
    );
  }

  // WIDGET: Cabeçalho
  Widget _construirCabecalho() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _fazerLogout,
            child: Tooltip(
              message: 'Perfil de ${_sessaoAtual.nomeCompleto} - Sair da conta',
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A), // Azul escuro
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),

          // Logotipo: PLAYZONE
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 24,
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

          // Ícone do sino
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFF0F172A),
                  size: 24,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444), // Vermelho
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET: Barra de Busca
  Widget _construirBarraBusca() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF64748B), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controladorBusca,
              focusNode: _buscaFoco,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
              decoration: const InputDecoration(
                hintText: 'Buscar quadras, esportes ou locais',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14.0),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filtro avançado em desenvolvimento!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(
              Icons.tune_outlined,
              color: Color(0xFF254EDB),
              size: 22,
            ),
          ),
        ],
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
                  _controladorBusca.clear();
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
            builder: (context) => TelaDetalhesQuadra(quadra: quadra),
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
              color: Colors.black.withOpacity(0.04),
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
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(quadra.caminhoImagem),
                          fit: BoxFit.cover,
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
                              color: Colors.black.withOpacity(0.1),
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
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'R\$ ${quadra.precoPorHora.toStringAsFixed(0)}',
                            ),
                            const TextSpan(
                              text: '/hr',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
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

  // WIDGET: Seção Explorar por Localidade (carregada dinamicamente do Banco de Dados / API)
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: estaSelecionado
                ? const Color(0xFF254EDB)
                : const Color(0xFFE2E8F0),
            width: estaSelecionado ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            // Ícone com fundo azul-escuro
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2C59), // Azul escuro
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),

            // Informações textuais
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

            // Chevron de navegação
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
        color: const Color(0xFF0A2240), // Azul marinho escuro
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2240).withOpacity(0.15),
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
                // Tag "SEJA PREMIUM"
                const Text(
                  'SEJA PREMIUM',
                  style: TextStyle(
                    color: Color(0xFF22C55E), // Verde brilhante
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),

                // Descrição do banner
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

                // Botão do banner
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
          // Desenho/Ícone grande de troféu
          Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.emoji_events,
              color: Colors.white.withOpacity(0.8),
              size: 90,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Barra de Navegação Inferior
  Widget _construirBarraNavegacao() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1.0),
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

  // WIDGET: Item de Navegação Individual
  Widget _construirItemNavegacao(int index, IconData icone, String rotulo) {
    final bool estaAtivo = _abaSelecionada == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _abaSelecionada = index;
        });
        if (index > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aba "$rotulo" em desenvolvimento!'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: estaAtivo
                  ? const Color(0xFFDCFCE7)
                  : Colors.transparent, // Fundo verde claro para ativo
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icone,
              color: estaAtivo
                  ? const Color(0xFF22C55E)
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
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
