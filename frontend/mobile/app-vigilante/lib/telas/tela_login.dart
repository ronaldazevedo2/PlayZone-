import 'package:flutter/material.dart';
import '../componentes/cabecalho_autenticacao.dart';
import '../componentes/campo_texto.dart';
import 'tela_principal.dart';
import '../estado_central.dart';
import '../traducao.dart';

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

  final EstadoCentral _estadoCentral = EstadoCentral();
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _estadoCentral.addListener(_aoAtualizarEstado);
  }

  @override
  void dispose() {
    _estadoCentral.removeListener(_aoAtualizarEstado);
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    _focoEmail.dispose();
    _focoSenha.dispose();
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

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return Tradutor.obter('validar_senha_vazio');
    }
    if (valor.length < 6) {
      return Tradutor.obter('validar_senha_tamanho');
    }
    return null;
  }

  Future<void> _realizarLogin() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    setState(() => _carregando = true);

    // Simula pequeno delay de autenticação para melhor UX
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final erro = await _estadoCentral.autenticarVigilante(
      _controladorEmail.text.trim(),
      _controladorSenha.text,
    );

    if (erro != null) {
      setState(() => _carregando = false);

      String erroTraduzido = erro;
      if (erro == 'Usuário não cadastrado') {
        erroTraduzido = Tradutor.obter('email_nao_encontrado');
      } else if (erro == 'Senha incorreta') {
        erroTraduzido = _estadoCentral.idiomaSelecionado == 'English'
            ? 'Incorrect password'
            : _estadoCentral.idiomaSelecionado == 'Español'
                ? 'Contraseña incorrecta'
                : 'Senha incorreta';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  erroTraduzido,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Salva sessão para login persistente
    await _estadoCentral.salvarSessao();

    if (!mounted) return;
    setState(() => _carregando = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const TelaPrincipal()),
    );
  }

  void _irParaEsqueciSenha() {
    Navigator.of(context).pushNamed('/esqueci_senha');
  }

  void _irParaCadastro() {
    Navigator.of(context).pushNamed('/cadastro');
  }

  @override
  Widget build(BuildContext context) {
    final ehEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ehEscuro
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
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
                  CabecalhoAutenticacao(
                    titulo: Tradutor.obter('login_titulo'),
                    subtitulo: Tradutor.obter('login_subtitulo'),
                  ),

                  // Campo de Entrada para E-mail
                  CampoTexto(
                    rotulo: Tradutor.obter('email_rotulo'),
                    dicaTexto: Tradutor.obter('email_dica'),
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
                    rotulo: Tradutor.obter('senha_rotulo'),
                    dicaTexto: Tradutor.obter('senha_dica'),
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
                        foregroundColor: ehEscuro
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      child: Text(
                        Tradutor.obter('esqueci_senha'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botão de Entrar com loading
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _realizarLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B7F38),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF0B7F38).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
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
                              Tradutor.obter('entrar'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Rodapé para criar conta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Tradutor.obter('nao_tem_conta'),
                        style: TextStyle(
                          color: ehEscuro
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _irParaCadastro,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: const Color(0xFF0B7F38),
                        ),
                        child: Text(
                          Tradutor.obter('cadastre_se'),
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
