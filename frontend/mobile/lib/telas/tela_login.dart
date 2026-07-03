import 'package:flutter/material.dart';
import '../componentes/cabecalho_autenticacao.dart';
import '../componentes/campo_texto.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginEstado();
}

class _TelaLoginEstado extends State<TelaLogin> {
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();
  
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();
  
  final FocusNode _focoEmail = FocusNode();
  final FocusNode _focoSenha = FocusNode();

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    _focoEmail.dispose();
    _focoSenha.dispose();
    super.dispose();
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor, insira seu e-mail';
    }
    // Regex simples para validação de e-mail
    final expressaoRegularEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!expressaoRegularEmail.hasMatch(valor.trim())) {
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (valor.length < 6) {
      return 'A senha deve conter no mínimo 6 caracteres';
    }
    return null;
  }

  void _realizarLogin() {
    if (_chaveFormulario.currentState!.validate()) {
      // O formulário é válido, realiza a lógica de autenticação
      final email = _controladorEmail.text.trim();

      // Exibe um feedback visual de carregamento/sucesso temporário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entrando com o e-mail: $email...'),
          backgroundColor: const Color(0xFF22C55E), // Verde de sucesso
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _irParaEsqueciSenha() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade "Esqueci minha senha" em desenvolvimento.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _irParaCadastro() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade "Cadastro" em desenvolvimento.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _chaveFormulario,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabeçalho com logo e boas-vindas
                  const CabecalhoAutenticacao(
                    titulo: 'Bem-vindo de volta!',
                    subtitulo: 'Entre com seus dados para acessar sua conta na PlayZone.',
                  ),
                  
                  // Campo de Entrada para E-mail
                  CampoTexto(
                    rotulo: 'E-mail',
                    dicaTexto: 'Ex: jogador@email.com',
                    icone: Icons.email_outlined,
                    controlador: _controladorEmail,
                    noFoco: _focoEmail,
                    proximoNoFoco: _focoSenha,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: _validarEmail,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Campo de Entrada para Senha
                  CampoTexto(
                    rotulo: 'Senha',
                    dicaTexto: 'Digite sua senha de acesso',
                    icone: Icons.lock_outline,
                    controlador: _controladorSenha,
                    noFoco: _focoSenha,
                    ehSenha: true,
                    validador: _validarSenha,
                    aoSubmeter: (_) => _realizarLogin(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Link para recuperar a senha
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _irParaEsqueciSenha,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      child: const Text(
                        'Esqueci minha senha',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botão de Entrar
                  ElevatedButton(
                    onPressed: _realizarLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E), // Verde clássico do app
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Rodapé para criar conta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não tem uma conta?',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _irParaCadastro,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: const Color(0xFF22C55E),
                        ),
                        child: const Text(
                          'Cadastre-se',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
