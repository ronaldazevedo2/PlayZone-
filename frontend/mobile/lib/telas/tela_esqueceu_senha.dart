import 'package:flutter/material.dart';
import '../componentes/campo_texto.dart';
import '../servicos/servico_autenticacao.dart';
import 'tela_redefinir_senha.dart';

class TelaEsqueceuSenha extends StatefulWidget {
  const TelaEsqueceuSenha({super.key});

  @override
  State<TelaEsqueceuSenha> createState() => _TelaEsqueceuSenhaEstado();
}

class _TelaEsqueceuSenhaEstado extends State<TelaEsqueceuSenha> {
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();
  final TextEditingController _controladorEmail = TextEditingController();
  final FocusNode _focoEmail = FocusNode();
  bool _estaCarregando = false;

  @override
  void dispose() {
    _controladorEmail.dispose();
    _focoEmail.dispose();
    super.dispose();
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor, insira seu e-mail';
    }
    final expressaoRegularEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!expressaoRegularEmail.hasMatch(valor.trim())) {
      return 'Por favor, insira um e-mail com formato válido';
    }
    return null;
  }

  Future<void> _solicitarEnvioLink() async {
    if (!_chaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      _estaCarregando = true;
    });

    final email = _controladorEmail.text.trim();

    try {
      final mensagemRetornada = await ServicoAutenticacao.solicitarRecuperacaoSenha(email: email);
      
      if (!mounted) return;

      _exibirDialogoConfirmacao(mensagemRetornada);
    } catch (_) {
      if (!mounted) return;
      _exibirDialogoConfirmacao(
        'Se existir uma conta vinculada a este e-mail, você receberá um link para redefinição de senha.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _estaCarregando = false;
        });
      }
    }
  }

  void _exibirDialogoConfirmacao(String mensagem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextoDialogo) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_read_outlined, color: Color(0xFF254EDB), size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Solicitação Enviada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        content: Text(
          mensagem,
          style: const TextStyle(fontSize: 14.5, color: Color(0xFF475569), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(contextoDialogo); // Fecha modal
              Navigator.pop(context); // Volta pro login
            },
            child: const Text(
              'Voltar ao Login',
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(contextoDialogo);
              _irParaRedefinicaoSenha();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF254EDB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Testar Redefinição',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _irParaRedefinicaoSenha() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TelaRedefinirSenha(tokenDemonstracao: 'token_demo_playzone_123'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _chaveFormulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Título principal
                  const Text(
                    'Esqueceu a senha?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtítulo descritivo
                  const Text(
                    'Não se preocupe! Informe seu e-mail e enviaremos um link para redefinir sua senha.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Campo E-mail
                  CampoTexto(
                    rotulo: 'E-mail',
                    dicaTexto: 'exemplo@email.com',
                    icone: Icons.mail_outline,
                    controlador: _controladorEmail,
                    noFoco: _focoEmail,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: _validarEmail,
                    aoSubmeter: (_) => _solicitarEnvioLink(),
                  ),
                  const SizedBox(height: 28),

                  // Botão ENVIAR LINK
                  ElevatedButton(
                    onPressed: _estaCarregando ? null : _solicitarEnvioLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF254EDB), // Azul idêntico ao protótipo
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _estaCarregando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'ENVIAR LINK',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                  const SizedBox(height: 28),

                  // Divisor com texto "ou"
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'ou',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Link Voltar para o login
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF254EDB),
                      ),
                      child: const Text(
                        'Voltar para o login',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
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
}
