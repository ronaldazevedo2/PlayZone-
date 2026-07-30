import 'package:flutter/material.dart';
import '../componentes/cabecalho_autenticacao.dart';
import '../componentes/campo_texto.dart';
import '../estado_central.dart';
import '../traducao.dart';

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

  final EstadoCentral _estadoCentral = EstadoCentral();

  @override
  void initState() {
    super.initState();
    _estadoCentral.addListener(_aoAtualizarEstado);
  }

  @override
  void dispose() {
    _estadoCentral.removeListener(_aoAtualizarEstado);
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

  void _aoAtualizarEstado() {
    if (mounted) {
      setState(() {});
    }
  }

  String? _validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return Tradutor.obter('validar_nome_vazio');
    }
    if (valor.trim().split(' ').length < 2) {
      return Tradutor.obter('validar_nome_incompleto');
    }
    return null;
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

  String? _validarMatricula(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return Tradutor.obter('validar_matricula_vazio');
    }
    if (int.tryParse(valor) == null) {
      return Tradutor.obter('validar_matricula_numeros');
    }
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return Tradutor.obter('validar_senha_vazio');
    }
    if (valor.length < 6) {
      return Tradutor.obter('validar_senha_tamanho');
    }
    return null;
  }

  String? _validarConfirmarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return Tradutor.obter('validar_confirmacao_vazio');
    }
    if (valor != _controladorSenha.text) {
      return Tradutor.obter('validar_confirmacao_diferente');
    }
    return null;
  }

  Future<void> _cadastrarUsuario() async {
    if (_chaveFormulario.currentState!.validate()) {
      final sucesso = await _estadoCentral.cadastrarVigilante(
        _controladorNome.text,
        _controladorEmail.text,
        _controladorMatricula.text,
        _controladorSenha.text,
      );

      if (!mounted) return;

      if (!sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Tradutor.obter('email_ja_usado'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final ehEscuro = Theme.of(context).brightness == Brightness.dark;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: ehEscuro ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF0B7F38), size: 28),
                const SizedBox(width: 8),
                Text(
                  Tradutor.obter('cadastro_realizado'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ehEscuro ? Colors.white : const Color(0xFF09398E),
                  ),
                ),
              ],
            ),
            content: Text(
              Tradutor.obter('cadastro_sucesso_msg'),
              style: TextStyle(color: ehEscuro ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  Navigator.of(context).pop(); // Volta para a tela de login
                },
                child: Text(
                  Tradutor.obter('ok'),
                  style: const TextStyle(
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
    final ehEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ehEscuro ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ehEscuro ? Colors.white : const Color(0xFF09398E)),
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
                  CabecalhoAutenticacao(
                    titulo: Tradutor.obter('cadastro_titulo'),
                    subtitulo: Tradutor.obter('cadastro_subtitulo'),
                  ),
                  
                  CampoTexto(
                    rotulo: Tradutor.obter('nome_rotulo'),
                    dicaTexto: Tradutor.obter('nome_dica'),
                    icone: Icons.person_outline,
                    controlador: _controladorNome,
                    noFoco: _focoNome,
                    proximoNoFoco: _focoEmail,
                    validador: _validarNome,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoTexto(
                    rotulo: Tradutor.obter('email_rotulo'),
                    dicaTexto: Tradutor.obter('email_dica'),
                    icone: Icons.email_outlined,
                    controlador: _controladorEmail,
                    noFoco: _focoEmail,
                    proximoNoFoco: _focoMatricula,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: _validarEmail,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoTexto(
                    rotulo: Tradutor.obter('matricula_rotulo'),
                    dicaTexto: Tradutor.obter('matricula_dica'),
                    icone: Icons.badge_outlined,
                    controlador: _controladorMatricula,
                    noFoco: _focoMatricula,
                    proximoNoFoco: _focoSenha,
                    tipoTeclado: TextInputType.number,
                    validador: _validarMatricula,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoTexto(
                    rotulo: Tradutor.obter('senha_rotulo'),
                    dicaTexto: Tradutor.obter('senha_dica'),
                    icone: Icons.lock_outline,
                    controlador: _controladorSenha,
                    noFoco: _focoSenha,
                    proximoNoFoco: _focoConfirmarSenha,
                    ehSenha: true,
                    validador: _validarSenha,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoTexto(
                    rotulo: Tradutor.obter('confirmar_senha_rotulo'),
                    dicaTexto: Tradutor.obter('confirmar_senha_dica'),
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
                    child: Text(
                      Tradutor.obter('cadastrar'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Tradutor.obter('ja_tem_conta'),
                        style: TextStyle(
                          color: ehEscuro ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                        child: Text(
                          Tradutor.obter('entre'),
                          style: const TextStyle(
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
