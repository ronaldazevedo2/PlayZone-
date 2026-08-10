import 'dart:math';
import 'package:flutter/material.dart';
import 'package:playzone_mobile/traducao.dart';
import '../estado_central.dart';
import 'tela_perfil_detalhado.dart';

class TelaBuscar extends StatefulWidget {
  const TelaBuscar({super.key});

  @override
  State<TelaBuscar> createState() => _TelaBuscarEstado();
}

class _TelaBuscarEstado extends State<TelaBuscar> {
  final TextEditingController _controladorPesquisa = TextEditingController();
  final EstadoCentral _estadoCentral = EstadoCentral();

  List<ClienteArena> _resultadosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _estadoCentral.addListener(_aoAtualizarEstado);
    _controladorPesquisa.addListener(_filtrarResultados);
    _filtrarResultados();
  }

  @override
  void dispose() {
    _estadoCentral.removeListener(_aoAtualizarEstado);
    _controladorPesquisa.dispose();
    super.dispose();
  }

  void _aoAtualizarEstado() {
    if (mounted) {
      _filtrarResultados();
    }
  }

  void _filtrarResultados() {
    final query = _controladorPesquisa.text.toLowerCase().trim();
    final todosClientes = _estadoCentral.clientes;

    setState(() {
      if (query.isEmpty) {
        _resultadosFiltrados = List.from(todosClientes);
      } else {
        _resultadosFiltrados = todosClientes.where((cliente) {
          // Limpa pontos e traços do CPF para melhorar a busca numérica
          final cpfLimpo = cliente.cpf.replaceAll('.', '').replaceAll('-', '');
          final queryLimpa = query.replaceAll('.', '').replaceAll('-', '');

          return cliente.nome.toLowerCase().contains(query) ||
              cliente.cpf.contains(query) ||
              cpfLimpo.contains(queryLimpa) ||
              cliente.localReserva.toLowerCase().contains(query) ||
              cliente.matricula.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ehEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ehEscuro
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: ehEscuro
            ? const Color(0xFF1E293B)
            : const Color(0xFF09398E),
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          Tradutor.obter('vigilante'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/notificacoes');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Área Superior com o campo de busca
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Tradutor.obter('buscar_titulo'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ehEscuro ? Colors.white : const Color(0xFF09398E),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ehEscuro
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: TextField(
                    controller: _controladorPesquisa,
                    style: TextStyle(
                      color: ehEscuro ? Colors.white : const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: Tradutor.obter('buscar_dica'),
                      hintStyle: TextStyle(
                        color: ehEscuro
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  Tradutor.obter('buscar_resultados'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ehEscuro
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Lista de resultados
          Expanded(
            child: _resultadosFiltrados.isEmpty
                ? Center(
                    child: Text(
                      Tradutor.obter('buscar_sem_resultados'),
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _resultadosFiltrados.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final resultado = _resultadosFiltrados[index];
                      return _construirItemResultado(resultado, ehEscuro);
                    },
                  ),
          ),

          // Legenda na parte inferior
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 20.0,
            ),
            decoration: BoxDecoration(
              color: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: ehEscuro
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _construirItemLegenda(
                  const Color(0xFF0B7F38),
                  Tradutor.obter('liberado'),
                  ehEscuro,
                ),
                _construirItemLegenda(
                  const Color(0xFFF59E0B),
                  Tradutor.obter('pendente'),
                  ehEscuro,
                ),
                _construirItemLegenda(
                  const Color(0xFF64748B),
                  Tradutor.obter('livre'),
                  ehEscuro,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirItemResultado(ClienteArena resultado, bool ehEscuro) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TelaPerfilDetalhado(cliente: resultado),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ehEscuro ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            // Avatar com indicador de cor de status na borda
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _obterCorStatus(resultado.statusAcesso),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(1),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(resultado.fotoUrl),
                backgroundColor: const Color(0xFF09398E).withOpacity(0.1),
                child: resultado.fotoUrl.isEmpty
                    ? Text(
                        resultado.nome
                            .substring(0, min(2, resultado.nome.length))
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF09398E),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Informações de texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resultado.nome,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ehEscuro ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "CPF: ${resultado.cpf}",
                    style: TextStyle(
                      color: ehEscuro
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Quadra à direita
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  resultado.localReserva,
                  style: TextStyle(
                    color: ehEscuro
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF09398E),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: ehEscuro
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF09398E),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _obterCorStatus(TipoStatusAcesso status) {
    switch (status) {
      case TipoStatusAcesso.liberado:
      case TipoStatusAcesso.dentro:
        return const Color(0xFF0B7F38);
      case TipoStatusAcesso.pendente:
        return const Color(0xFFF59E0B);
      case TipoStatusAcesso.livre:
        return const Color(0xFFCBD5E1);
    }
  }

  Widget _construirItemLegenda(Color cor, String rotulo, bool ehEscuro) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          rotulo,
          style: TextStyle(
            color: ehEscuro ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
