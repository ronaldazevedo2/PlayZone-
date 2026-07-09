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
    required this.distanciaEmKm,
    required this.caminhoImagem,
  });

  factory QuadraEsportiva.deJson(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final nome = json['nome'] ?? 'Sem Nome';
    final modalidade = json['modalidade'] ?? 'Poliesportiva';
    final localizacao = json['localizacao'] ?? 'Centro';
    final capacidade = json['capacidade'] ?? 10;
    final descricao = json['descricao'] ?? 'Quadra esportiva para jogos e treinos.';
    final imagemUrl = json['imagemUrl'];

    // Mapeamentos elegantes dos campos locais
    final bairro = _extrairBairro(localizacao);
    final endereco = localizacao;
    
    // Preço padrão fixo ou baseado na capacidade da quadra
    final precoPorHora = capacidade > 0 ? (capacidade * 15.0) : 150.0;

    // Distância determinística gerada com base no hashCode do ID
    final hash = id.hashCode.abs();
    final distanciaEmKm = 1.0 + (hash % 40) / 10.0;

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
      estaDisponivel: true,
      distanciaEmKm: distanciaEmKm,
      caminhoImagem: caminhoImagem,
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'capacidade': capacidade,
      'localizacao': '$endereco - $bairro',
      'modalidade': modalidade,
      'imagemUrl': caminhoImagem,
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
    if (imagemUrl != null && imagemUrl.isNotEmpty) return imagemUrl;
    final mod = modalidade.toLowerCase();
    if (mod.contains('tenis') || mod.contains('tênis')) {
      return 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?q=80&w=600&auto=format&fit=crop';
    } else if (mod.contains('futebol') || mod.contains('soccer') || mod.contains('society')) {
      return 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop';
    } else if (mod.contains('basquete') || mod.contains('basketball')) {
      return 'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=600&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=600&auto=format&fit=crop';
  }
}
