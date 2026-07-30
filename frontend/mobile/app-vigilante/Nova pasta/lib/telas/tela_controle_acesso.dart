import 'dart:math';
import 'package:flutter/material.dart';
import '../estado_central.dart';
import 'tela_perfil_detalhado.dart';

class TelaControleAcesso extends StatefulWidget {
  final Function(int) aoNavegarParaAba;

  const TelaControleAcesso({
    super.key,
    required this.aoNavegarParaAba,
  });

  @override
  State<TelaControleAcesso> createState() => _TelaControleAcessoEstado();
}

class _TelaControleAcessoEstado extends State<TelaControleAcesso> with SingleTickerProviderStateMixin {
  late AnimationController _controladorAnimacao;
  late Animation<double> _animacaoLinhaScanner;
  final EstadoCentral _estadoCentral = EstadoCentral();

  @override
  void initState() {
    super.initState();
    _estadoCentral.addListener(_aoAtualizarEstado);
    // Configura animação da linha verde do scanner de QR Code
    _controladorAnimacao = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animacaoLinhaScanner = Tween<double>(begin: 0.0, end: 1.0).animate(_controladorAnimacao);
  }

  @override
  void dispose() {
    _estadoCentral.removeListener(_aoAtualizarEstado);
    _controladorAnimacao.dispose();
    super.dispose();
  }

  void _aoAtualizarEstado() {
    if (mounted) {
      setState(() {});
    }
  }

  void _simularLeituraQrCode() {
    // Sorteia um cliente cadastrado no estado central para simular a leitura do QR Code
    final clientesDisponiveis = _estadoCentral.clientes.where((c) => c.statusAcesso != TipoStatusAcesso.dentro).toList();
    if (clientesDisponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Todos os clientes simulados já estão dentro da arena!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final clienteSorteado = clientesDisponiveis[Random().nextInt(clientesDisponiveis.length)];

    // Abre diálogo mostrando as informações do QR Code lido
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Color(0xFF09398E), size: 28),
              SizedBox(width: 8),
              Text(
                "QR Code Identificado",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF09398E)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0B7F38), width: 2),
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(clienteSorteado.fotoUrl),
                  backgroundColor: const Color(0xFFE2E8F0),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                clienteSorteado.nome,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Text(
                "CPF: ${clienteSorteado.cpf}",
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Local reservado:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Text(clienteSorteado.localReserva, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF09398E))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Horário agendado:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Text(clienteSorteado.horarioPrevisto, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF09398E))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B7F38),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _estadoCentral.registrarEntrada(clienteSorteado);
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Acesso liberado para ${clienteSorteado.nome}!"),
                    backgroundColor: const Color(0xFF0B7F38),
                  ),
                );
              },
              child: const Text("Registrar Entrada"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Carrega o histórico de acessos
    final acessosRecentes = _estadoCentral.historico.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09398E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "CONTROLE DE ACESSO",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
                onPressed: () {
                  Navigator.of(context).pushNamed('/notificacoes');
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container do Scanner Fictício
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF09398E), // Azul escuro do fundo do scanner
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Escaneie o QR Code",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Posicione o QR Code do cliente para registrar a entrada.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Área de Escaneamento Visual
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Desenho do QR Code simulado no fundo
                          Opacity(
                            opacity: 0.8,
                            child: Icon(
                              Icons.qr_code,
                              size: 150,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),

                          // Cantoneiras do scanner (Molding Frame)
                          Positioned(
                            top: 10, left: 10,
                            child: _construirCantoneira(top: true, left: true),
                          ),
                          Positioned(
                            top: 10, right: 10,
                            child: _construirCantoneira(top: true, left: false),
                          ),
                          Positioned(
                            bottom: 10, left: 10,
                            child: _construirCantoneira(top: false, left: true),
                          ),
                          Positioned(
                            bottom: 10, right: 10,
                            child: _construirCantoneira(top: false, left: false),
                          ),

                          // Linha animada do scanner
                          AnimatedBuilder(
                            animation: _animacaoLinhaScanner,
                            builder: (context, child) {
                              return Positioned(
                                top: 20 + (_animacaoLinhaScanner.value * 160),
                                left: 20,
                                right: 20,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E), // Linha verde do scanner
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF22C55E).withOpacity(0.8),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão Abrir Scanner
                  ElevatedButton.icon(
                    onPressed: _simularLeituraQrCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B7F38), // Verde escuro exato
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.qr_code_scanner, size: 20),
                    label: const Text(
                      "ABRIR SCANNER (SIMULAR)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Cabeçalho de Entradas Recentes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Entradas recentes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Vai para a aba do histórico e desempilha a tela atual
                    Navigator.of(context).pop();
                    widget.aoNavegarParaAba(2);
                  },
                  child: const Text(
                    "Ver histórico completo",
                    style: TextStyle(
                      color: Color(0xFF0B7F38), // Verde para o link
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de entradas recentes
            if (acessosRecentes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text("Nenhuma entrada registrada recentemente.", style: TextStyle(color: Color(0xFF64748B))),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: acessosRecentes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entrada = acessosRecentes[index];
                  return _construirItemEntrada(entrada);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirCantoneira({required bool top, required bool left}) {
    const tamanhoCanto = 20.0;
    const espessuraCanto = 3.0;
    return SizedBox(
      width: tamanhoCanto,
      height: tamanhoCanto,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: !top ? 0 : null,
            left: left ? 0 : null,
            right: !left ? 0 : null,
            child: Container(
              width: tamanhoCanto,
              height: espessuraCanto,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: top ? 0 : null,
            bottom: !top ? 0 : null,
            left: left ? 0 : null,
            right: !left ? 0 : null,
            child: Container(
              width: espessuraCanto,
              height: tamanhoCanto,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirItemEntrada(RegistroAcessoHistorico entrada) {
    // Busca o cliente para poder abrir a tela de detalhes se o usuário clicar
    final cliente = _estadoCentral.clientes.firstWhere(
      (c) => c.nome.toLowerCase() == entrada.nome.toLowerCase(),
      orElse: () => ClienteArena(
        nome: entrada.nome,
        cpf: "000.000.000-00",
        matricula: "0000",
        localReserva: entrada.local,
        horarioPrevisto: "00:00",
        statusAcesso: entrada.status,
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
                entrada.nome.substring(0, min(2, entrada.nome.length)).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF09398E),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Informações da Entrada
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entrada.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        entrada.local,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entrada.dataHora,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chip de Status
            _construirChipStatus(entrada.status),
            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
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
        corFundo = const Color(0xFF0B7F38); // Verde exato
        corBorda = const Color(0xFF0B7F38);
        break;
      case TipoStatusAcesso.pendente:
        rotulo = "PENDENTE";
        corTexto = const Color(0xFFD97706); // Laranja exato
        corFundo = const Color(0xFFFEF3C7); // Fundo amarelo bem claro
        corBorda = const Color(0xFFF59E0B);
        break;
      case TipoStatusAcesso.livre:
        rotulo = "LIVRE";
        corTexto = const Color(0xFF64748B); // Cinza
        corFundo = const Color(0xFFF1F5F9); // Fundo cinza bem claro
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
