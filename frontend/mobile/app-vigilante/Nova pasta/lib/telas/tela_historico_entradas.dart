import 'dart:math';
import 'package:flutter/material.dart';
import '../estado_central.dart';
import 'tela_perfil_detalhado.dart';

class TelaHistoricoEntradas extends StatefulWidget {
  const TelaHistoricoEntradas({super.key});

  @override
  State<TelaHistoricoEntradas> createState() => _TelaHistoricoEntradasEstado();
}

class _TelaHistoricoEntradasEstado extends State<TelaHistoricoEntradas> {
  final TextEditingController _controladorPesquisa = TextEditingController();
  final EstadoCentral _estadoCentral = EstadoCentral();

  String _filtroDataSelecionado = "Hoje";
  String _filtroStatusSelecionado = "Todos";
  List<RegistroAcessoHistorico> _registrosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _estadoCentral.addListener(_aoAtualizarEstado);
    _controladorPesquisa.addListener(_filtrarRegistros);
    _filtrarRegistros();
  }

  @override
  void dispose() {
    _estadoCentral.removeListener(_aoAtualizarEstado);
    _controladorPesquisa.dispose();
    super.dispose();
  }

  void _aoAtualizarEstado() {
    if (mounted) {
      _filtrarRegistros();
    }
  }

  void _filtrarRegistros() {
    final query = _controladorPesquisa.text.toLowerCase();
    final todosRegistros = _estadoCentral.historico;

    setState(() {
      _registrosFiltrados = todosRegistros.where((registro) {
        final matchesQuery =
            registro.nome.toLowerCase().contains(query) ||
            registro.local.toLowerCase().contains(query);

        final matchesStatus =
            _filtroStatusSelecionado == "Todos" ||
            (_filtroStatusSelecionado == "Liberado" &&
                (registro.status == TipoStatusAcesso.liberado || registro.status == TipoStatusAcesso.dentro)) ||
            (_filtroStatusSelecionado == "Pendente" &&
                registro.status == TipoStatusAcesso.pendente) ||
            (_filtroStatusSelecionado == "Livre" &&
                registro.status == TipoStatusAcesso.livre);

        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09398E),
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          "HISTÓRICO DE ENTRADAS",
          style: TextStyle(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            // Filtros Data e Status
            Row(
              children: [
                Expanded(
                  child: _construirSeletorFiltro(
                    icone: Icons.calendar_today_outlined,
                    valor: _filtroDataSelecionado,
                    opcoes: ["Hoje", "Ontem", "Esta semana"],
                    aoAlterar: (novoValor) {
                      setState(() {
                        _filtroDataSelecionado = novoValor!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _construirSeletorFiltro(
                    icone: Icons.filter_alt_outlined,
                    valor: _filtroStatusSelecionado,
                    opcoes: ["Todos", "Liberado", "Pendente", "Livre"],
                    aoAlterar: (novoValor) {
                      setState(() {
                        _filtroStatusSelecionado = novoValor!;
                        _filtrarRegistros();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campo de busca
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _controladorPesquisa,
                decoration: const InputDecoration(
                  hintText: "Buscar por nome ou quadra...",
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de Logs
            Expanded(
              child: _registrosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum registro encontrado.",
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _registrosFiltrados.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final registro = _registrosFiltrados[index];
                        return _construirItemRegistro(registro);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirSeletorFiltro({
    required IconData icone,
    required String valor,
    required List<String> opcoes,
    required void Function(String?) aoAlterar,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valor,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF09398E),
            size: 20,
          ),
          isExpanded: true,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          onChanged: aoAlterar,
          items: opcoes.map<DropdownMenuItem<String>>((String opcao) {
            return DropdownMenuItem<String>(
              value: opcao,
              child: Row(
                children: [
                  Icon(icone, color: const Color(0xFF09398E), size: 16),
                  const SizedBox(width: 8),
                  Text(opcao),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _construirItemRegistro(RegistroAcessoHistorico registro) {
    // Busca o cliente correspondente no estado central
    final cliente = _estadoCentral.clientes.firstWhere(
      (c) => c.nome.toLowerCase() == registro.nome.toLowerCase(),
      orElse: () => ClienteArena(
        nome: registro.nome,
        cpf: "000.000.000-00",
        matricula: "0000",
        localReserva: registro.local,
        horarioPrevisto: "00:00",
        statusAcesso: registro.status,
        fotoUrl: "",
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TelaPerfilDetalhado(cliente: cliente),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF09398E).withOpacity(0.1),
              child: Text(
                registro.nome.substring(0, min(2, registro.nome.length)).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF09398E),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registro.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    registro.local,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        registro.dataHora,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge de status
            _construirChipStatus(registro.status),
            const SizedBox(width: 8),

            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _construirChipStatus(TipoStatusAcesso status) {
    String rotulo;
    Color corTexto;
    Color corFundo;
    Color corBorda;

    switch (status) {
      case TipoStatusAcesso.liberado:
      case TipoStatusAcesso.dentro:
        rotulo = "LIBERADO";
        corTexto = Colors.white;
        corFundo = const Color(0xFF0B7F38);
        corBorda = const Color(0xFF0B7F38);
        break;
      case TipoStatusAcesso.pendente:
        rotulo = "PENDENTE";
        corTexto = const Color(0xFFD97706);
        corFundo = const Color(0xFFFEF3C7);
        corBorda = const Color(0xFFF59E0B);
        break;
      case TipoStatusAcesso.livre:
        rotulo = "LIVRE";
        corTexto = const Color(0xFF64748B);
        corFundo = const Color(0xFFF1F5F9);
        corBorda = const Color(0xFFCBD5E1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: corFundo,
        border: Border.all(color: corBorda),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        rotulo,
        style: TextStyle(
          color: corTexto,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
