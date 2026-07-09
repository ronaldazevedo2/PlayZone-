import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../componentes/campo_texto.dart';
import '../servicos/servico_autenticacao.dart';
import 'tela_inicial.dart';

/// Formatter personalizado para aplicar a máscara do CPF (000.000.000-00)
class MascaraCpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    final textoLimpo = newValue.text.replaceAll(RegExp(r'\D'), '');
    final comprimento = textoLimpo.length;
    final resultado = StringBuffer();

    if (comprimento > 0) {
      if (comprimento <= 3) {
        resultado.write(textoLimpo);
      } else {
        resultado.write(textoLimpo.substring(0, 3));
        resultado.write('.');
        if (comprimento <= 6) {
          resultado.write(textoLimpo.substring(3));
        } else {
          resultado.write(textoLimpo.substring(3, 6));
          resultado.write('.');
          if (comprimento <= 9) {
            resultado.write(textoLimpo.substring(6));
          } else {
            resultado.write(textoLimpo.substring(6, 9));
            resultado.write('-');
            resultado.write(textoLimpo.substring(9, math.min(11, comprimento)));
          }
        }
      }
    }

    final textoFormatado = resultado.toString();
    return TextEditingValue(
      text: textoFormatado,
      selection: TextSelection.collapsed(offset: textoFormatado.length),
    );
  }
}

/// Formatter personalizado para aplicar a máscara de Telefone brasileira dynamically
class MascaraTelefoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    final textoLimpo = newValue.text.replaceAll(RegExp(r'\D'), '');
    final comprimento = textoLimpo.length;
    final resultado = StringBuffer();

    if (comprimento > 0) {
      resultado.write('(');
      if (comprimento <= 2) {
        resultado.write(textoLimpo);
      } else {
        resultado.write(textoLimpo.substring(0, 2));
        resultado.write(') ');
        if (comprimento <= 7) {
          resultado.write(textoLimpo.substring(2));
        } else if (comprimento <= 10) {
          // Fixo: (XX) XXXX-XXXX
          resultado.write(textoLimpo.substring(2, 6));
          resultado.write('-');
          resultado.write(textoLimpo.substring(6));
        } else {
          // Celular: (XX) XXXXX-XXXX
          resultado.write(textoLimpo.substring(2, 7));
          resultado.write('-');
          resultado.write(textoLimpo.substring(7, math.min(11, comprimento)));
        }
      }
    }

    final textoFormatado = resultado.toString();
    return TextEditingValue(
      text: textoFormatado,
      selection: TextSelection.collapsed(offset: textoFormatado.length),
    );
  }
}

class TelaCadastroUsuario extends StatefulWidget {
  const TelaCadastroUsuario({super.key});

  @override
  State<TelaCadastroUsuario> createState() => _TelaCadastroUsuarioEstado();
}

class _TelaCadastroUsuarioEstado extends State<TelaCadastroUsuario> {
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();

  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();
  final TextEditingController _controladorNome = TextEditingController();
  final TextEditingController _controladorCpf = TextEditingController();
  final TextEditingController _controladorTelefone = TextEditingController();
  final TextEditingController _controladorDataNascimento =
      TextEditingController();

  final FocusNode _focoEmail = FocusNode();
  final FocusNode _focoSenha = FocusNode();
  final FocusNode _focoNome = FocusNode();
  final FocusNode _focoCpf = FocusNode();
  final FocusNode _focoTelefone = FocusNode();

  bool _termosAceitos = false;
  bool _estaCarregando = false;

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    _controladorNome.dispose();
    _controladorCpf.dispose();
    _controladorTelefone.dispose();
    _controladorDataNascimento.dispose();

    _focoEmail.dispose();
    _focoSenha.dispose();
    _focoNome.dispose();
    _focoCpf.dispose();
    _focoTelefone.dispose();
    super.dispose();
  }

  /// Validador oficial de CPF brasileiro
  bool _validarCpfAlgoritmo(String cpf) {
    final cpfLimpo = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpfLimpo.length != 11) return false;

    // Números idênticos são inválidos
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfLimpo)) return false;

    // Cálculo do primeiro dígito
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpfLimpo[i]) * (10 - i);
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;
    if (int.parse(cpfLimpo[9]) != digito1) return false;

    // Cálculo do segundo dígito
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpfLimpo[i]) * (11 - i);
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;
    if (int.parse(cpfLimpo[10]) != digito2) return false;

    return true;
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O e-mail é obrigatório';
    }
    final expressaoRegularEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!expressaoRegularEmail.hasMatch(valor.trim())) {
      return 'Insira um e-mail válido';
    }
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'A senha é obrigatória';
    }
    if (valor.length < 8) {
      return 'Mínimo de 8 caracteres';
    }
    // Para bater com as validações de segurança do backend
    if (!RegExp(r'[A-Z]').hasMatch(valor)) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(valor)) {
      return 'Senha deve conter pelo menos um número';
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(valor)) {
      return 'Senha deve conter pelo menos um caractere especial';
    }
    return null;
  }

  String? _validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O nome completo é obrigatório';
    }
    if (valor.trim().length < 3) {
      return 'Mínimo de 3 caracteres';
    }
    return null;
  }

  String? _validarCpf(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O CPF é obrigatório';
    }
    if (!_validarCpfAlgoritmo(valor)) {
      return 'CPF inválido';
    }
    return null;
  }

  String? _validarTelefone(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O telefone é obrigatório';
    }
    final textoLimpo = valor.replaceAll(RegExp(r'\D'), '');
    if (textoLimpo.length < 10 || textoLimpo.length > 11) {
      return 'Telefone inválido. Formato esperado: (XX) 99999-9999';
    }
    return null;
  }

  String? _validarDataNascimento(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'A data de nascimento é obrigatória';
    }

    final partes = valor.split('/');
    if (partes.length != 3) {
      return 'Formato inválido. Use DD/MM/AAAA';
    }

    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);

    if (dia == null || mes == null || ano == null) {
      return 'Data de nascimento inválida';
    }

    try {
      final dataNascimento = DateTime(ano, mes, dia);
      final hoje = DateTime.now();

      int idade = hoje.year - dataNascimento.year;
      if (hoje.month < dataNascimento.month ||
          (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
        idade--;
      }

      if (idade < 14) {
        return 'Cadastro permitido apenas para maiores de 14 anos';
      }
    } catch (_) {
      return 'Data de nascimento inválida';
    }

    return null;
  }

  /// Abre o selecionador de data
  Future<void> _abrirSeletorData() async {
    // Tira o foco dos outros campos antes de abrir
    FocusScope.of(context).unfocus();

    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 14),
      ), // 14 anos atrás como padrão
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF254EDB), // Azul do botão principal
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null) {
      final dia = dataSelecionada.day.toString().padLeft(2, '0');
      final mes = dataSelecionada.month.toString().padLeft(2, '0');
      final ano = dataSelecionada.year;
      _controladorDataNascimento.text = '$dia/$mes/$ano';
    }
  }

  void _abrirTermosDeUso() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termos de Uso'),
        content: const SingleChildScrollView(
          child: Text(
            'Estes são os Termos de Uso da PlayZone. Ao utilizar este aplicativo, você concorda em cumprir todas as regras aqui descritas, incluindo o uso adequado das quadras esportivas e horários reservados.\n\nTodo agendamento deve respeitar a política de cancelamento com pelo menos 24 horas de antecedência. Reservas não pagas até 1 hora antes do início do jogo poderão ser canceladas automaticamente pelo estabelecimento.',
            style: TextStyle(height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _abrirPoliticaPrivacidade() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidade'),
        content: const SingleChildScrollView(
          child: Text(
            'Sua privacidade é importante para nós. A PlayZone coleta e processa seus dados pessoais apenas para fins de gerenciamento da sua conta de usuário, agendamento de partidas e segurança de login.\n\nSeus dados de contato como telefone e e-mail serão visíveis aos administradores da arena e nunca serão compartilhados com terceiros sem seu consentimento expresso. As senhas de acesso são criptografadas por algoritmos seguros no servidor.',
            style: TextStyle(height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Efetua a lógica de cadastro
  Future<void> _efetuarCadastro() async {
    if (!_chaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      _estaCarregando = true;
    });

    final nomeCompleto = _controladorNome.text.trim();
    final email = _controladorEmail.text.trim();
    final senha = _controladorSenha.text;

    try {
      // 1. Cadastra o usuário no banco
      await ServicoAutenticacao.cadastrarUsuario(
        nomeCompleto: nomeCompleto,
        email: email,
        senha: senha,
      );

      // 2. Realiza o login (autenticação automática)
      final sessao = await ServicoAutenticacao.realizarLogin(
        email: email,
        senha: senha,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro concluído e autenticado com sucesso!'),
          backgroundColor: Color(0xFF22C55E),
          duration: Duration(seconds: 2),
        ),
      );

      // 3. Navega para a Tela Inicial substituindo a de Cadastro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaInicial(sessao: sessao)),
      );
    } catch (erro) {
      if (!mounted) return;

      final stringErro = erro.toString();

      if (stringErro.contains('Sem conexão com o servidor') ||
          stringErro.contains('Exception: Sem conexão')) {
        // Fallback para fins de teste offline do frontend
        _mostrarDialogoFallbackOffline(nomeCompleto, email);
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

  /// Exibe um diálogo amigável oferecendo login offline caso a API esteja inacessível
  void _mostrarDialogoFallbackOffline(String nomeCompleto, String email) {
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

              // Cria uma sessão mock e salva localmente
              final sessaoMock = SessaoUsuario(
                tokenAcesso: 'jwt_mock_token_playzone_offline',
                nomeCompleto: nomeCompleto,
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

  @override
  Widget build(BuildContext context) {
    const corCinzaIcones = Color(0xFF64748B);
    const corAzulDestaque = Color(0xFF254EDB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Linha com botão de voltar no canto superior esquerdo
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF1E293B),
                    size: 26,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Form(
                  key: _chaveFormulario,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título Bem-vindo!
                      const Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Subtítulo
                      const Text(
                        'Crie sua conta para agendar sua partida.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // E-mail
                      CampoTexto(
                        rotulo: 'E-mail',
                        dicaTexto: 'exemplo@email.com',
                        icone: Icons.email_outlined,
                        corIcone: corCinzaIcones,
                        controlador: _controladorEmail,
                        noFoco: _focoEmail,
                        proximoNoFoco: _focoSenha,
                        tipoTeclado: TextInputType.emailAddress,
                        validador: _validarEmail,
                      ),
                      const SizedBox(height: 18),

                      // Senha
                      CampoTexto(
                        rotulo: 'Senha',
                        dicaTexto: 'Digite sua senha',
                        icone: Icons.lock_outline,
                        corIcone: corCinzaIcones,
                        controlador: _controladorSenha,
                        noFoco: _focoSenha,
                        proximoNoFoco: _focoNome,
                        ehSenha: true,
                        validador: _validarSenha,
                      ),
                      const SizedBox(height: 18),

                      // Seu nome
                      CampoTexto(
                        rotulo: 'Seu nome',
                        dicaTexto: 'Digite seu nome',
                        icone: Icons.person_outline,
                        corIcone: corCinzaIcones,
                        controlador: _controladorNome,
                        noFoco: _focoNome,
                        proximoNoFoco: _focoCpf,
                        tipoTeclado: TextInputType.name,
                        validador: _validarNome,
                      ),
                      const SizedBox(height: 18),

                      // CPF (com máscara)
                      CampoTexto(
                        rotulo: 'CPF',
                        dicaTexto: '000.000.000-00',
                        icone: Icons.badge_outlined,
                        corIcone: corCinzaIcones,
                        controlador: _controladorCpf,
                        noFoco: _focoCpf,
                        proximoNoFoco: _focoTelefone,
                        tipoTeclado: TextInputType.number,
                        validador: _validarCpf,
                        formatadores: [
                          FilteringTextInputFormatter.digitsOnly,
                          MascaraCpfFormatter(),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Telefone (com máscara)
                      CampoTexto(
                        rotulo: 'Telefone',
                        dicaTexto: '(11) 99999-9999',
                        icone: Icons.phone_outlined,
                        corIcone: corCinzaIcones,
                        controlador: _controladorTelefone,
                        noFoco: _focoTelefone,
                        tipoTeclado: TextInputType.phone,
                        validador: _validarTelefone,
                        formatadores: [
                          FilteringTextInputFormatter.digitsOnly,
                          MascaraTelefoneFormatter(),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Data de nascimento
                      CampoTexto(
                        rotulo: 'Data de nascimento',
                        dicaTexto: 'Selecione sua data',
                        icone: Icons.calendar_today_outlined,
                        corIcone: corCinzaIcones,
                        controlador: _controladorDataNascimento,
                        somenteLeitura: true,
                        tipoTeclado: TextInputType.datetime,
                        aoClicar: _abrirSeletorData,
                        validador: _validarDataNascimento,
                      ),
                      const SizedBox(height: 20),

                      // Checkbox Termos de Uso
                      FormField<bool>(
                        initialValue: _termosAceitos,
                        validator: (valor) {
                          if (valor != true) {
                            return 'Você deve aceitar os Termos de Uso';
                          }
                          return null;
                        },
                        builder: (estadoCampo) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _termosAceitos,
                                      activeColor: corAzulDestaque,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (valor) {
                                        setState(() {
                                          _termosAceitos = valor ?? false;
                                        });
                                        estadoCampo.didChange(valor);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 13.5,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'Li e aceito os ',
                                          ),
                                          TextSpan(
                                            text: 'Termos de Uso',
                                            style: const TextStyle(
                                              color: corAzulDestaque,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = _abrirTermosDeUso,
                                          ),
                                          const TextSpan(text: ' e a '),
                                          TextSpan(
                                            text: 'Política de Privacidade',
                                            style: const TextStyle(
                                              color: corAzulDestaque,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap =
                                                  _abrirPoliticaPrivacidade,
                                          ),
                                          const TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (estadoCampo.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 36.0,
                                    top: 6.0,
                                  ),
                                  child: Text(
                                    estadoCampo.errorText!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Botão CADASTRAR
                      ElevatedButton(
                        onPressed: _estaCarregando ? null : _efetuarCadastro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: corAzulDestaque,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          elevation: 0,
                          disabledBackgroundColor: corAzulDestaque.withOpacity(
                            0.6,
                          ),
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
                                'CADASTRAR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Divisor "ou"
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 16),
                              color: const Color(0xFFE2E8F0),
                              height: 1,
                            ),
                          ),
                          const Text(
                            'ou',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 16),
                              color: const Color(0xFFE2E8F0),
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Footer: Já tem uma conta? Entrar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Já tem uma conta? ',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                color: corAzulDestaque,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
