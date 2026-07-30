import 'package:flutter/material.dart';
import '../componentes/cabecalho_autenticacao.dart';
import '../componentes/campo_texto.dart';
import '../estado_central.dart';

class TelaEsqueciSenha extends StatefulWidget {
  const TelaEsqueciSenha({super.key});

  @override
  State<TelaEsqueciSenha> createState() => _TelaEsqueciSenhaEstado();
}

class _TelaEsqueciSenhaEstado extends State<TelaEsqueciSenha> {
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();
  final TextEditingController _controladorEmail = TextEditingController();
  final FocusNode _focoEmail = FocusNode();

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
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  }

  void _recuperarSenha() {
    if (_chaveFormulario.currentState!.validate()) {
      final email = _controladorEmail.text.trim();
      final existe = EstadoCentral().recuperarSenha(email);

      if (!existe) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Email não encontrado",
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
                Icon(Icons.mark_email_read_outlined, color: Color(0xFF0B7F38), size: 28),
                SizedBox(width: 8),
                Text(
                  "E-mail Enviado",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF09398E),
                  ),
                ),
              ],
            ),
            content: Text(
              "Email de recuperação enviado com sucesso para: $email. Verifique sua caixa de entrada.",
              style: const TextStyle(color: Color(0xFF64748B)),
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
                    titulo: 'Recuperar Senha',
                    subtitulo: 'Digite seu e-mail cadastrado para enviarmos as instruções de redefinição.',
                  ),
                  
                  CampoTexto(
                    rotulo: 'E-mail',
                    dicaTexto: 'Ex: vigilante@email.com',
                    icone: Icons.email_outlined,
                    controlador: _controladorEmail,
                    noFoco: _focoEmail,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: _validarEmail,
                    aoSubmeter: (_) => _recuperarSenha(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _recuperarSenha,
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
                      'Enviar Instruções',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                    ),
                    child: const Text(
                      'Voltar para o login',
                      style: TextStyle(
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
}
