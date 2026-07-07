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
}
