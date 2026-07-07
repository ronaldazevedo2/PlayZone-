import 'package:flutter/material.dart';

class CabecalhoAutenticacao extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const CabecalhoAutenticacao({
    super.key,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    final larguraTela = MediaQuery.of(context).size.width;

    // Calcula o tamanho da logo de forma responsiva
    final tamanhoLogo = larguraTela * 0.35;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        // Exibição da logo do aplicativo
        Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: tamanhoLogo.clamp(80.0, 160.0),
            height: tamanhoLogo.clamp(80.0, 160.0),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback caso a imagem falhe ao carregar
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  size: 50,
                  color: Colors.blue,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        // Título de Boas-Vindas
        Text(
          titulo,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B), // Cinza muito escuro/quase preto
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Subtítulo de Apoio
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            subtitulo,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B), // Cinza médio
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
