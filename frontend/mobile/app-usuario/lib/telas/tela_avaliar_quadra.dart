import 'package:flutter/material.dart';
import 'tela_meus_agendamentos.dart';

/// Item representando um critério de avaliação individual
class ModeloCriterioAvaliacao {
  final String nome;
  int nota;

  ModeloCriterioAvaliacao({
    required this.nome,
    this.nota = 5,
  });
}

class TelaAvaliarQuadra extends StatefulWidget {
  final ModeloAgendamentoItem agendamento;

  const TelaAvaliarQuadra({
    super.key,
    required this.agendamento,
  });

  @override
  State<TelaAvaliarQuadra> createState() => _TelaAvaliarQuadraEstado();
}

class _TelaAvaliarQuadraEstado extends State<TelaAvaliarQuadra> {
  int _notaGeral = 5;
  final TextEditingController _controladorComentario = TextEditingController();
  bool _enviarAnonimo = false;

  // Lista de critérios detalhados de avaliação
  final List<ModeloCriterioAvaliacao> _listaCriterios = [
    ModeloCriterioAvaliacao(nome: 'Qualidade da Quadra', nota: 5),
    ModeloCriterioAvaliacao(nome: 'Iluminação', nota: 5),
    ModeloCriterioAvaliacao(nome: 'Limpeza', nota: 5),
    ModeloCriterioAvaliacao(nome: 'Organização', nota: 5),
    ModeloCriterioAvaliacao(nome: 'Segurança', nota: 5),
    ModeloCriterioAvaliacao(nome: 'Atendimento', nota: 5),
  ];

  @override
  void dispose() {
    _controladorComentario.dispose();
    super.dispose();
  }

  void _enviarAvaliacao() {
    // Retorna 'true' para indicar que a quadra foi avaliada com sucesso
    Navigator.pop(context, true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Avaliação enviada com sucesso para ${widget.agendamento.nomeQuadra}!',
        ),
        backgroundColor: const Color(0xFF22C55E),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Avaliar Quadra',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Card de Resumo da Quadra
            _construirCardResumo(),

            const SizedBox(height: 24),

            // 2. Pergunta Principal
            const Text(
              'Como foi sua experiência nesta quadra?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Estrelas Gerais Grandes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final estrela = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _notaGeral = estrela;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      estrela <= _notaGeral
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFF16A34A),
                      size: 40,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // 4. Campo para comentário textual
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _controladorComentario,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                decoration: const InputDecoration(
                  hintText: 'Conte para outros jogadores como foi sua experiência...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  contentPadding: EdgeInsets.all(14.0),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 5. Avaliação por Critérios
            const Text(
              'Avaliação por Critérios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 12),

            _construirSecaoCriterios(),

            const SizedBox(height: 20),

            // 6. Enviar avaliação anonimamente
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Switch(
                    value: _enviarAnonimo,
                    activeTrackColor: const Color(0xFF1D3557),
                    onChanged: (val) {
                      setState(() {
                        _enviarAnonimo = val;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Enviar avaliação anonimamente',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Seu nome não será exibido nesta quadra.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 7. Botões Secundários (Adicionar Fotos | Reportar Problema)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecione fotos da galeria.'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1D3557),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text(
                      'Adicionar Fotos',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reportar problema ao suporte.'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD97706),
                      side: const BorderSide(color: Color(0xFFFCD34D)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.warning_amber_rounded, size: 18),
                    label: const Text(
                      'Reportar Problema',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 8. Botão Principal ENVIAR AVALIAÇÃO
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _enviarAvaliacao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D3557),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ENVIAR AVALIAÇÃO',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// WIDGET: Card de Resumo no topo
  Widget _construirCardResumo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Foto da Quadra
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.agendamento.imagemUrl,
              width: 90,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 90,
                height: 80,
                color: const Color(0xFFE2E8F0),
                child: const Icon(Icons.sports_soccer, color: Color(0xFF64748B)),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Informações da Quadra
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.agendamento.nomeQuadra,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.agendamento.localizacao,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      widget.agendamento.dataEHorario,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Partida concluída',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// WIDGET: Lista de critérios com checkboxes e estrelas
  Widget _construirSecaoCriterios() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Column(
        children: _listaCriterios.map((criterio) {
          return _construirItemCriterio(criterio);
        }).toList(),
      ),
    );
  }

  /// WIDGET: Item individual de critério
  Widget _construirItemCriterio(ModeloCriterioAvaliacao criterio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              criterio.nome,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),

          // 5 Estrelas para cada critério
          Row(
            children: List.generate(5, (index) {
              final estrela = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    criterio.nota = estrela;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Icon(
                    estrela <= criterio.nota
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFF16A34A),
                    size: 22,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
