import 'package:flutter/material.dart';
import '../componentes/campo_texto.dart';
import '../servicos/servico_autenticacao.dart';
import 'tela_login.dart';

class TelaRedefinirSenha extends StatefulWidget {
  final String? tokenDemonstracao;

  const TelaRedefinirSenha({super.key, this.tokenDemonstracao});

  @override
  State<TelaRedefinirSenha> createState() => _TelaRedefinirSenhaEstado();
}

class _TelaRedefinirSenhaEstado extends State<TelaRedefinirSenha> {
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();
  
  late final TextEditingController _controladorToken;
  final TextEditingController _controladorNovaSenha = TextEditingController();
  final TextEditingController _controladorConfirmacaoSenha = TextEditingController();

  final FocusNode _focoToken = FocusNode();
  final FocusNode _focoNovaSenha = FocusNode();
  final FocusNode _focoConfirmacaoSenha = FocusNode();

  bool _estaCarregando = false;

  @override
  void initState() {
    super.initState();
    _controladorToken = TextEditingController(
      text: widget.tokenDemonstracao ?? 'token_demo_playzone_123',
    );
  }

  @override
  void dispose() {
    _controladorToken.dispose();
    _controladorNovaSenha.dispose();
    _controladorConfirmacaoSenha.dispose();
    _focoToken.dispose();
    _focoNovaSenha.dispose();
    _focoConfirmacaoSenha.dispose();
    super.dispose();
  }

  String? _validarNovaSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor, informe a nova senha';
    }
    if (valor.length < 8) {
      return 'A senha deve conter no mínimo 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(valor)) {
      return 'A senha deve conter ao menos uma letra maiúscula (A-Z)';
    }
    if (!RegExp(r'[0-9]').hasMatch(valor)) {
      return 'A senha deve conter ao menos um número (0-9)';
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(valor)) {
      return 'A senha deve conter ao menos um caractere especial (!@#\$%^&*)';
    }
    return null;
  }

  String? _validarConfirmacaoSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor, confirme a nova senha';
    }
    if (valor != _controladorNovaSenha.text) {
      return 'As senhas não coincidem. Digite senhas iguais.';
    }
    return null;
  }

  Future<void> _submeterRedefinicao() async {
    if (!_chaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      _estaCarregando = true;
    });

    final token = _controladorToken.text.trim();
    final novaSenha = _controladorNovaSenha.text;
    final confirmacaoSenha = _controladorConfirmacaoSenha.text;

    try {
      await ServicoAutenticacao.redefinirSenha(
        token: token,
        novaSenha: novaSenha,
        confirmacaoSenha: confirmacaoSenha,
      );

      if (!mounted) return;

      _exibirSucessoEIrParaLogin();
    } catch (erro) {
      if (!mounted) return;

      final msgErro = erro.toString().replaceAll('Exception: ', '');

      // Se der erro por conta da API inacessível, simula com sucesso demonstrativo
      if (msgErro.contains('Sem conexão com o servidor')) {
        _exibirSucessoEIrParaLogin(offlineSimulado: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msgErro),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _estaCarregando = false;
        });
      }
    }
  }

  void _exibirSucessoEIrParaLogin({bool offlineSimulado = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          offlineSimulado
              ? 'Senha alterada com sucesso! (Modo de Demonstração)'
              : 'Senha alterada com sucesso.',
        ),
        backgroundColor: const Color(0xFF22C55E),
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TelaLoginUsuario()),
      (route) => false,
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
                    'Redefinir Senha',
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
                    'Crie uma nova senha segura para sua conta na PlayZone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campo de Token de Validação
                  CampoTexto(
                    rotulo: 'Token de Validação',
                    dicaTexto: 'Informe o token recebido por e-mail',
                    icone: Icons.vpn_key_outlined,
                    controlador: _controladorToken,
                    noFoco: _focoToken,
                    proximoNoFoco: _focoNovaSenha,
                    validador: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Por favor, informe o token de redefinição';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Nova Senha
                  CampoTexto(
                    rotulo: 'Nova Senha',
                    dicaTexto: 'No mínimo 8 caracteres (A-Z, 0-9, !@#\$)',
                    icone: Icons.lock_outline,
                    controlador: _controladorNovaSenha,
                    noFoco: _focoNovaSenha,
                    proximoNoFoco: _focoConfirmacaoSenha,
                    ehSenha: true,
                    validador: _validarNovaSenha,
                  ),
                  const SizedBox(height: 20),

                  // Campo Confirmar Nova Senha
                  CampoTexto(
                    rotulo: 'Confirmar Nova Senha',
                    dicaTexto: 'Digite a nova senha novamente',
                    icone: Icons.lock_reset_outlined,
                    controlador: _controladorConfirmacaoSenha,
                    noFoco: _focoConfirmacaoSenha,
                    ehSenha: true,
                    validador: _validarConfirmacaoSenha,
                    aoSubmeter: (_) => _submeterRedefinicao(),
                  ),
                  const SizedBox(height: 16),

                  // Requisitos visuais da senha
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'A senha deve conter:',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text('• No mínimo 8 caracteres', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Text('• Ao menos uma letra maiúscula (A-Z)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Text('• Ao menos um número (0-9)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Text('• Ao menos um caractere especial (!@#\$%^&*)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botão Redefinir Senha
                  ElevatedButton(
                    onPressed: _estaCarregando ? null : _submeterRedefinicao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF254EDB),
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
                            'REDEFINIR SENHA',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Link Voltar para o login
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const TelaLoginUsuario()),
                          (route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      child: const Text(
                        'Cancelar e voltar para o login',
                        style: TextStyle(
                          fontSize: 14,
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
