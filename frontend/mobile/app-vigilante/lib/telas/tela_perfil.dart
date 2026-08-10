import 'package:flutter/material.dart';
import 'package:playzone_mobile/traducao.dart';
import '../estado_central.dart';

class TelaPerfil extends StatefulWidget {
  final VoidCallback aoEfetuarLogoff;

  const TelaPerfil({super.key, required this.aoEfetuarLogoff});

  @override
  State<TelaPerfil> createState() => _TelaPerfilEstado();
}

class _TelaPerfilEstado extends State<TelaPerfil> {
  final EstadoCentral _estadoCentral = EstadoCentral();

  bool get ehEscuro => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _estadoCentral.addListener(_aoAtualizarEstado);
  }

  @override
  void dispose() {
    _estadoCentral.removeListener(_aoAtualizarEstado);
    super.dispose();
  }

  void _aoAtualizarEstado() {
    if (mounted) {
      setState(() {});
    }
  }

  void _mostrarConfirmacaoSaida() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            Tradutor.obter('perfil_confirmacao_titulo'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ehEscuro ? Colors.white : const Color(0xFF09398E),
            ),
          ),
          content: Text(
            Tradutor.obter('perfil_confirmacao_msg'),
            style: TextStyle(
              color: ehEscuro
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                Tradutor.obter('cancelar'),
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _estadoCentral.deslogarVigilante();
                widget.aoEfetuarLogoff();
              },
              child: Text(
                Tradutor.obter('perfil_sair'),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vigilante = _estadoCentral.vigilanteLogado;

    final nome = vigilante?.nome ?? "João da Silva";
    final cargo = "Vigilante";
    final matricula = vigilante?.matricula ?? "4587";
    final local = "Arena PlayZone";

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
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
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
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO "MEU PERFIL"
            Text(
              Tradutor.obter('perfil_titulo'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800, // Corrigido de extrabold para w800
                color: ehEscuro ? Colors.white : const Color(0xFF09398E),
              ),
            ),
            const SizedBox(height: 16),

            // CARD PRINCIPAL DO USUÁRIO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!ehEscuro)
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.04,
                      ), // Atualizado para withValues
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
                border: Border.all(
                  color: ehEscuro
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                children: [
                  // Foto de perfil
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFCBD5E1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: ehEscuro
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Informações textuais
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: ehEscuro
                                ? Colors.white
                                : const Color(0xFF09398E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cargo,
                          style: TextStyle(
                            fontSize: 13,
                            color: ehEscuro
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Matrícula: $matricula",
                          style: TextStyle(
                            fontSize: 12,
                            color: ehEscuro
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          local,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CARD COM OPÇÕES DE MENU
            Container(
              decoration: BoxDecoration(
                color: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!ehEscuro)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
                border: Border.all(
                  color: ehEscuro
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                ),
              ),
              child: Column(
                children: [
                  _construirOpcaoMenu(
                    icon: Icons.settings_outlined,
                    titulo: 'Configurações',
                    onTap: () {
                      Navigator.of(context).pushNamed('/configuracoes');
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: ehEscuro
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9),
                  ),
                  _construirOpcaoMenu(
                    icon: Icons.notifications_none_outlined,
                    titulo: 'Notificações',
                    onTap: () {
                      Navigator.of(context).pushNamed('/notificacoes');
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: ehEscuro
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9),
                  ),
                  _construirOpcaoMenu(
                    icon: Icons.info_outline,
                    titulo: 'Sobre o aplicativo',
                    onTap: () {
                      Navigator.of(context).pushNamed('/sobre');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // BOTÃO SAIR DA CONTA
            Container(
              decoration: BoxDecoration(
                color: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!ehEscuro)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
                border: Border.all(
                  color: ehEscuro
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 2,
                ),
                leading: const Icon(Icons.logout, color: Color(0xFF0B7F38)),
                title: Text(
                  Tradutor.obter('perfil_sair'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B7F38),
                  ),
                ),
                onTap: _mostrarConfirmacaoSaida,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirOpcaoMenu({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
  }) {
    final corItem = ehEscuro ? Colors.white : const Color(0xFF09398E);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, color: corItem),
      title: Text(
        titulo,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: corItem,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: corItem, size: 22),
      onTap: onTap,
    );
  }
}
