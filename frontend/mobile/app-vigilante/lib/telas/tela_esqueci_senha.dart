import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../componentes/cabecalho_autenticacao.dart';
import '../componentes/campo_texto.dart';
import '../estado_central.dart';
import '../traducao.dart';

class TelaEsqueciSenha extends StatefulWidget {
  const TelaEsqueciSenha({super.key});

  @override
  State<TelaEsqueciSenha> createState() => _TelaEsqueciSenhaEstado();
}

class _TelaEsqueciSenhaEstado extends State<TelaEsqueciSenha> {
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();
  final TextEditingController _controladorEmail = TextEditingController();
  final FocusNode _focoEmail = FocusNode();

  final EstadoCentral _estadoCentral = EstadoCentral();
  bool _carregando = false;
  bool _emailEnviado = false;

  @override
  void initState() {
    super.initState();
    _estadoCentral.addListener(_aoAtualizarEstado);
  }

  @override
  void dispose() {
    _estadoCentral.removeListener(_aoAtualizarEstado);
    _controladorEmail.dispose();
    _focoEmail.dispose();
    super.dispose();
  }

  void _aoAtualizarEstado() {
    if (mounted) setState(() {});
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return Tradutor.obter('validar_email_vazio');
    }
    final expressaoRegularEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!expressaoRegularEmail.hasMatch(valor.trim())) {
      return Tradutor.obter('validar_email_invalido');
    }
    return null;
  }

  Future<void> _recuperarSenha() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    final email = _controladorEmail.text.trim();
    final existe = _estadoCentral.recuperarSenha(email);

    if (!existe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Tradutor.obter('email_nao_encontrado'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _carregando = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    // Tenta abrir o cliente de e-mail nativo com assunto pré-preenchido
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Recuperação de Senha - PlayZone Vigilante',
        'body':
            'Olá! Você solicitou a recuperação de senha do App PlayZone Vigilante.\n\nClique no link abaixo para redefinir sua senha:\n\n[Link simulado - Sistema de recuperação]\n\nSe você não fez esta solicitação, ignore este e-mail.',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }

    if (!mounted) return;
    setState(() {
      _carregando = false;
      _emailEnviado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ehEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          ehEscuro ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ehEscuro ? Colors.white : const Color(0xFF09398E),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 16.0),
            child: _emailEnviado
                ? _construirTelaConfirmacao(ehEscuro)
                : Form(
                    key: _chaveFormulario,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CabecalhoAutenticacao(
                          titulo: Tradutor.obter('recuperar_senha_titulo'),
                          subtitulo:
                              Tradutor.obter('recuperar_senha_subtitulo'),
                        ),
                        CampoTexto(
                          rotulo: Tradutor.obter('email_rotulo'),
                          dicaTexto: Tradutor.obter('email_dica'),
                          icone: Icons.email_outlined,
                          controlador: _controladorEmail,
                          noFoco: _focoEmail,
                          tipoTeclado: TextInputType.emailAddress,
                          validador: _validarEmail,
                          aoSubmeter: (_) => _recuperarSenha(),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _carregando ? null : _recuperarSenha,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B7F38),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF0B7F38).withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _carregando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    Tradutor.obter('enviar_instrucoes'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: ehEscuro
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          child: Text(
                            Tradutor.obter('voltar_login'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _construirTelaConfirmacao(bool ehEscuro) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0B7F38).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Color(0xFF0B7F38),
            size: 64,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          Tradutor.obter('email_enviado_titulo'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ehEscuro ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          Tradutor.obter(
            'email_enviado_msg',
            parametros: {'email': _controladorEmail.text.trim()},
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: ehEscuro
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: ehEscuro
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ehEscuro
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF09398E),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'O cliente de e-mail do seu dispositivo foi aberto. Verifique também sua pasta de spam.',
                  style: TextStyle(
                    fontSize: 12,
                    color: ehEscuro
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B7F38),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              Tradutor.obter('voltar_login'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
