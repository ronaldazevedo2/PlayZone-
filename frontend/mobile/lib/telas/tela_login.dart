import 'package:flutter/material.dart';
import '../componentes/cabecalho_autenticacao.dart';
import '../componentes/campo_texto.dart';
import '../servicos/servico_autenticacao.dart';
import 'tela_cadastro_usuario.dart';
import 'tela_esqueceu_senha.dart';
import 'tela_inicial.dart';

class TelaLoginUsuario extends StatefulWidget {
  const TelaLoginUsuario({super.key});

  @override
  State<TelaLoginUsuario> createState() => _TelaLoginUsuarioEstado();
}

class _TelaLoginUsuarioEstado extends State<TelaLoginUsuario> {
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();
  bool _estaCarregando = false;

  final TextEditingController _controladorEmail = TextEditingController(text: 'jogador@email.com');
  final TextEditingController _controladorSenha = TextEditingController(text: 'PlayZone123!');

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

  Future<void> _realizarLogin() async {
    if (!_chaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      _estaCarregando = true;
    });

    final email = _controladorEmail.text.trim();
    final senha = _controladorSenha.text;

    try {
      final sessao = await ServicoAutenticacao.realizarLogin(
        email: email,
        senha: senha,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Color(0xFF22C55E),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaInicial(sessao: sessao)),
      );
    } catch (erro) {
      if (!mounted) return;

      final stringErro = erro.toString();

      if (stringErro.contains('Sem conexão com o servidor') ||
          stringErro.contains('Exception: Sem conexão')) {
        _mostrarDialogoFallbackOffline(email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(stringErro.replaceAll('Exception: ', '')),
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

  void _mostrarDialogoFallbackOffline(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange),
            SizedBox(width: 10),
            Text('Conexão Offline'),
          ],
        ),
        content: const Text(
          'Não foi possível se conectar ao servidor local da PlayZone.\n\nDeseja realizar um login de demonstração offline para testar o aplicativo?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final sessaoMock = SessaoUsuario(
                tokenAcesso: 'jwt_mock_token_playzone_offline',
                nomeCompleto: 'Jogador de Demonstração',
                email: email,
                perfil: 'jogador',
              );
              await ServicoAutenticacao.salvarSessao(sessaoMock);

              if (!mounted) return;

              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Text('Sessão simulada offline criada com sucesso!'),
                  backgroundColor: Color(0xFF22C55E),
                ),
              );

              Navigator.pushReplacement(
                this.context,
                MaterialPageRoute(
                  builder: (context) => TelaInicial(sessao: sessaoMock),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF254EDB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sim, Entrar'),
          ),
        ],
      ),
    );
  }

  void _irParaEsqueciSenha() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaEsqueceuSenha()),
    );
  }

  void _irParaCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaCadastroUsuario()),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _chaveFormulario,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabeçalho com logo e boas-vindas
                  const CabecalhoAutenticacao(
                    titulo: 'Bem-vindo de volta! v1',
                    subtitulo:
                        'Entre com seus dados para acessar sua conta na PlayZone.',
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
                    onPressed: _estaCarregando ? null : _realizarLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF22C55E,
                      ), // Verde clássico do app
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      elevation: 0,
                      disabledBackgroundColor: const Color(
                        0xFF22C55E,
                      ).withOpacity(0.6),
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
