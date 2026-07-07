import 'package:flutter/material.dart';
import '../modelos/modelo_quadra.dart';

class TelaDetalhesQuadra extends StatelessWidget {
  final QuadraEsportiva quadra;

  const TelaDetalhesQuadra({super.key, required this.quadra});

  @override
  Widget build(BuildContext context) {
    final alturaImagem = MediaQuery.of(context).size.height * 0.35;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Visualizador de Conteúdo Rolável
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imagem em destaque no topo
                  Hero(
                    tag: 'imagem_quadra_${quadra.id}',
                    child: Container(
                      height: alturaImagem,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(quadra.caminhoImagem),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black54, Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Detalhes da quadra
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categoria / Modalidade
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            quadra.modalidade.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF254EDB),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nome da quadra
                        Text(
                          quadra.nome,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF192252),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Preço por hora
                        Row(
                          children: [
                            Text(
                              'R\$ ${quadra.precoPorHora.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                            const Text(
                              '/hora',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const Spacer(),
                            // Badge de Disponibilidade
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: quadra.estaDisponivel ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: quadra.estaDisponivel ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    quadra.estaDisponivel ? 'Disponível' : 'Indisponível',
                                    style: TextStyle(
                                      color: quadra.estaDisponivel ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        const Divider(color: Color(0xFFE2E8F0), height: 1),
                        const SizedBox(height: 24),

                        // Grid de Informações
                        Row(
                          children: [
                            // Capacidade
                            Expanded(
                              child: _construirItemGridInfo(
                                icone: Icons.people_outline,
                                titulo: 'Capacidade',
                                valor: '${quadra.capacidade} Jogadores',
                              ),
                            ),
                            // Distância
                            Expanded(
                              child: _construirItemGridInfo(
                                icone: Icons.directions_walk,
                                titulo: 'Distância',
                                valor: '${quadra.distanciaEmKm.toStringAsFixed(1)} km de você',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Localização
                        _construirItemGridInfo(
                          icone: Icons.location_on_outlined,
                          titulo: 'Localização',
                          valor: '${quadra.endereco}, ${quadra.bairro} - SP',
                        ),
                        const SizedBox(height: 24),

                        const Divider(color: Color(0xFFE2E8F0), height: 1),
                        const SizedBox(height: 24),

                        // Descrição
                        const Text(
                          'Sobre a quadra',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          quadra.descricao,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 100), // Espaço extra para rolar sobre o botão fixo
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão de voltar flutuante
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

          // Botão de agendar fixado na base da tela
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Agendamento solicitado para a quadra ${quadra.nome}!'),
                    backgroundColor: const Color(0xFF22C55E),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E), // Verde clássico ou de destaque
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 6,
                shadowColor: const Color(0xFF22C55E).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'SOLICITAR AGENDAMENTO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirItemGridInfo({
    required IconData icone,
    required String titulo,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icone, color: const Color(0xFF64748B), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
