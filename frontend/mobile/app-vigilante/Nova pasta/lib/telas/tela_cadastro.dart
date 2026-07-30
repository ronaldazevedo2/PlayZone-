import 'package:flutter/material.dart';
import '../componentes/cabecalho_autenticacao.dart';
import '../componentes/campo_texto.dart';
import '../estado_central.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroEstado();
}

class _TelaCadastroEstado extends State<TelaCadastro> {
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();
  
  final TextEditingController _controladorNome = TextEditingController();
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorMatricula = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();
  final TextEditingController _controladorConfirmarSenha = TextEditingController();

  final FocusNode _focoNome = FocusNode();
  final FocusNode _focoEmail = FocusNode();
  final FocusNode _focoMatricula = FocusNode();
  final FocusNode _focoSenha = FocusNode();
  final FocusNode _focoConfirmarSenha = FocusNode();

  @override
  void dispose() {
    _controladorNome.dispose();
    _controladorEmail.dispose();
    _controladorMatricula.dispose();
    _controladorSenha.dispose();
    _controladorConfirmarSenha.dispose();

    _focoNome.dispose();
    _focoEmail.dispose();
    _focoMatricula.dispose();
    _focoSenha.dispose();
    _focoConfirmarSenha.dispose();
    super.dispose();
  }

  String? _validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor, insira seu nome completo';
    }
    if (valor.trim().split(' ').length < 2) {
      return 'Por favor, insira nome e sobrenome';
    }
    return null;
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor, insira seu e-mail';
    }
    final expressaoRegularEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!expressaoRegularEmail.hasMatch(valor.trim())) {
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  }

  String? _validarMatricula(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor, insira sua matrícula';
    }
    if (int.tryParse(valor) == null) {
      return 'A matrícula deve conter apenas números';
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

  String? _validarConfirmarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    if (valor != _controladorSenha.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  void _cadastrarUsuario() {
    if (_chaveFormulario.currentState!.validate()) {
      final sucesso = EstadoCentral().cadastrarVigilante(
        _controladorNome.text,
        _controladorEmail.text,
        _controladorMatricula.text,
        _controladorSenha.text,
      );

      if (!sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Este e-mail já está sendo utilizado por outro vigilante.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Color(0xFF0B7F38), size: 28),
                SizedBox(width: 8),
                Text(
                  "Cadastro Realizado",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF09398E),
                  ),
                ),
              ],
            ),
            content: const Text(
              "Sua conta de vigilante foi criada com sucesso! Faça login para começar.",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  Navigator.of(context).pop(); // Volta para a tela de login
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Color(0xFF0B7F38),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF09398E)),
          onPressed: () => Navigator.of(context).pop(),
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CabecalhoAutenticacao(
                    titulo: 'Criar Conta',
                    subtitulo: 'Preencha os dados abaixo para cadastrar-se como Vigilante.',
                  ),
                  
                  CampoTexto(
                    rotulo: 'Nome Completo',
                    dicaTexto: 'Digite seu nome completo',
                    icone: Icons.person_outline,
                    controlador: _controladorNome,
                    noFoco: _focoNome,
                    proximoNoFoco: _focoEmail,
                    validador: _validarNome,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoTexto(
                    rotulo: 'E-mail',
                    dicaTexto: 'Ex: vigilante@email.com',
                    icone: Icons.email_outlined,
                    controlador: _controladorEmail,
                    noFoco: _focoEmail,
                    proximoNoFoco: _focoMatricula,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: _validarEmail,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoTexto(
                    rotulo: 'Matrícula',
                    dicaTexto: 'Digite o número de matrícula',
                    icone: Icons.badge_outlined,
                    controlador: _controladorMatricula,
                    noFoco: _focoMatricula,
                    proximoNoFoco: _focoSenha,
                    tipoTeclado: TextInputType.number,
                    validador: _validarMatricula,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoTexto(
                    rotulo: 'Senha',
                    dicaTexto: 'Escolha uma senha de acesso',
                    icone: Icons.lock_outline,
                    controlador: _controladorSenha,
                    noFoco: _focoSenha,
                    proximoNoFoco: _focoConfirmarSenha,
                    ehSenha: true,
                    validador: _validarSenha,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoTexto(
                    rotulo: 'Confirmar Senha',
                    dicaTexto: 'Digite a senha novamente',
                    icone: Icons.lock_clock_outlined,
                    controlador: _controladorConfirmarSenha,
                    noFoco: _focoConfirmarSenha,
                    ehSenha: true,
                    validador: _validarConfirmarSenha,
                    aoSubmeter: (_) => _cadastrarUsuario(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _cadastrarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B7F38),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Cadastrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Já tem uma conta?',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: const Color(0xFF0B7F38),
                        ),
                        child: const Text(
                          'Entre',
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
