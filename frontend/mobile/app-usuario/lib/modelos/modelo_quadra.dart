class QuadraEsportiva {
  final String id;
  final String nome;
  final String modalidade;
  final String bairro;
  final String endereco;
  final int capacidade;
  final String descricao;
  final double precoPorHora;
  final bool estaDisponivel;
  final String status;
  final double avaliacao;
  final double distanciaEmKm;
  final String caminhoImagem;

  const QuadraEsportiva({
    required this.id,
    required this.nome,
    required this.modalidade,
    required this.bairro,
    required this.endereco,
    required this.capacidade,
    required this.descricao,
    required this.precoPorHora,
    required this.estaDisponivel,
    this.status = 'Ativa',
    this.avaliacao = 4.8,
    required this.distanciaEmKm,
    required this.caminhoImagem,
  });

  factory QuadraEsportiva.deJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['Id'])?.toString() ?? '';
    final nome = (json['nome'] ?? json['Nome'])?.toString() ?? 'Quadra Poliesportiva';
    final modalidade = (json['modalidade'] ?? json['Modalidade'])?.toString() ?? 'Futebol';
    final localizacao =
        (json['localizacao'] ?? json['Localizacao'] ?? json['localidade'])
            ?.toString() ??
        'Centro';

    final capRaw = json['capacidade'] ?? json['Capacidade'];
    final int capacidade = capRaw is int
        ? capRaw
        : (int.tryParse(capRaw?.toString() ?? '') ?? 10);

    final descricao = (json['descricao'] ?? json['Descricao'])?.toString() ??
        'Quadra poliesportiva oficial para treinos e jogos.';
    final imagemUrl = (json['imagemUrl'] ?? json['ImagemUrl'])?.toString();
    final status = (json['status'] ?? json['Status'])?.toString() ?? 'Ativa';

    final bairro = _extrairBairro(localizacao);
    final endereco = localizacao;
    final precoPorHora = capacidade > 0 ? (capacidade * 15.0) : 150.0;

    final hash = id.hashCode.abs();
    final distanciaEmKm = 1.0 + (hash % 40) / 10.0;
    final avaliacaoCalculada = 4.2 + (hash % 8) / 10.0;
    final caminhoImagem = _obterImagemEsporte(imagemUrl, modalidade);

    return QuadraEsportiva(
      id: id,
      nome: nome,
      modalidade: modalidade,
      bairro: bairro,
      endereco: endereco,
      capacidade: capacidade,
      descricao: descricao,
      precoPorHora: precoPorHora,
      estaDisponivel: status.toLowerCase() != 'inativa' &&
          status.toLowerCase() != 'indisponivel' &&
          status.toLowerCase() != 'indisponível',
      status: status,
      avaliacao: double.parse(avaliacaoCalculada.toStringAsFixed(1)),
      distanciaEmKm: distanciaEmKm,
      caminhoImagem: caminhoImagem,
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'capacidade': capacidade,
      'localizacao': '$endereco - $bairro',
      'modalidade': modalidade,
      'imagemUrl': caminhoImagem,
      'status': status,
    };
  }

  static String _extrairBairro(String localizacao) {
    if (localizacao.contains('-')) {
      return localizacao.split('-').last.trim();
    }
    if (localizacao.contains(',')) {
      final partes = localizacao.split(',');
      if (partes.length > 1) {
        return partes[1].trim();
      }
    }
    return localizacao.trim().isEmpty ? 'Centro' : localizacao.trim();
  }

  static String _obterImagemEsporte(String? imagemUrl, String modalidade) {
    if (imagemUrl != null &&
        imagemUrl.trim().isNotEmpty &&
        (imagemUrl.startsWith('http://') || imagemUrl.startsWith('https://')) &&
        !imagemUrl.contains('exemplo.com') &&
        !imagemUrl.contains('example.com') &&
        !imagemUrl.contains('localhost')) {
      return imagemUrl.trim();
    }
    final mod = modalidade.toLowerCase();
    if (mod.contains('tenis') || mod.contains('tênis')) {
      return 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?q=80&w=600&auto=format&fit=crop';
    } else if (mod.contains('futebol') ||
        mod.contains('soccer') ||
        mod.contains('society') ||
        mod.contains('futsal')) {
      return 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop';
    } else if (mod.contains('basquete') || mod.contains('basketball')) {
      return 'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=600&auto=format&fit=crop';
    } else if (mod.contains('volei') || mod.contains('vôlei')) {
      return 'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?q=80&w=600&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=600&auto=format&fit=crop';
  }
}
