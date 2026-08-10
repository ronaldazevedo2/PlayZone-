import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../servicos/servico_autenticacao.dart';
import 'tela_cadastro_usuario.dart';
import 'tela_login.dart';

/// Tela de Perfil do Usuário baseada no layout padrão
class TelaPerfilUsuario extends StatefulWidget {
  final SessaoUsuario sessao;
  final VoidCallback? aoVoltar;

  const TelaPerfilUsuario({
    super.key,
    required this.sessao,
    this.aoVoltar,
  });

  @override
  State<TelaPerfilUsuario> createState() => _TelaPerfilUsuarioEstado();
}

class _TelaPerfilUsuarioEstado extends State<TelaPerfilUsuario> {
  late SessaoUsuario _sessaoAtual;
  bool _estaCarregando = false;
  bool _modoEdicao = false;

  final TextEditingController _controladorNome = TextEditingController();
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorCpf = TextEditingController();
  final TextEditingController _controladorTelefone = TextEditingController();

  final FocusNode _focoNome = FocusNode();
  final FocusNode _focoEmail = FocusNode();
  final FocusNode _focoTelefone = FocusNode();

  @override
  void initState() {
    super.initState();
    _sessaoAtual = widget.sessao;
    _preencherCampos();
    _carregarPerfilLocalOuApi();

    // Sincroniza em tempo real as alterações do Nome e E-mail com o cabeçalho da tela
    _controladorNome.addListener(_aoMudarTexto);
    _controladorEmail.addListener(_aoMudarTexto);
  }

  void _aoMudarTexto() {
    if (mounted) {
      setState(() {});
    }
  }

  void _preencherCampos() {
    _controladorNome.text = _sessaoAtual.nomeCompleto;
    _controladorEmail.text = _sessaoAtual.email;
    _controladorCpf.text = _formatarCpfExibicao(_sessaoAtual.cpf);
    _controladorTelefone.text = _formatarTelefoneExibicao(_sessaoAtual.telefone);
  }

  String _formatarTelefoneExibicao(String telRaw) {
    final limpo = telRaw.replaceAll(RegExp(r'\D'), '');
    if (limpo.length == 11) {
      return '(${limpo.substring(0, 2)}) ${limpo.substring(2, 7)}-${limpo.substring(7)}';
    } else if (limpo.length == 10) {
      return '(${limpo.substring(0, 2)}) ${limpo.substring(2, 6)}-${limpo.substring(6)}';
    }
    return telRaw;
  }

  String _formatarCpfExibicao(String cpfRaw) {
    final limpo = cpfRaw.replaceAll(RegExp(r'\D'), '');
    if (limpo.length == 11) {
      return '***.${limpo.substring(3, 6)}.${limpo.substring(6, 9)}-**';
    }
    return cpfRaw.isNotEmpty ? cpfRaw : '***.452.898-**';
  }

  Future<void> _carregarPerfilLocalOuApi() async {
    final sessaoSalva = await ServicoAutenticacao.obterSessao();
    if (sessaoSalva != null && mounted) {
      setState(() {
        _sessaoAtual = sessaoSalva;
        _preencherCampos();
      });
    }

    try {
      final sessaoAtualizada = await ServicoAutenticacao.obterPerfilUsuarioDaApi();
      if (sessaoAtualizada != null && mounted) {
        setState(() {
          _sessaoAtual = sessaoAtualizada;
          _preencherCampos();
        });
      }
    } catch (_) {
      // Falha silenciosa se estiver offline, mantém dados locais
    }
  }

  @override
  void dispose() {
    _controladorNome.removeListener(_aoMudarTexto);
    _controladorEmail.removeListener(_aoMudarTexto);
    _controladorNome.dispose();
    _controladorEmail.dispose();
    _controladorCpf.dispose();
    _controladorTelefone.dispose();
    _focoNome.dispose();
    _focoEmail.dispose();
    _focoTelefone.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoesPerfil() async {
    final nome = _controladorNome.text.trim();
    final email = _controladorEmail.text.trim();
    final telefone = _controladorTelefone.text.trim();

    if (nome.isEmpty || nome.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um nome completo válido (mínimo 3 caracteres).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (nome.length > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome deve ter no máximo 150 caracteres.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final expressaoEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty || !expressaoEmail.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um e-mail válido.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final telefoneLimpo = telefone.replaceAll(RegExp(r'\D'), '');
    if (telefoneLimpo.length < 10 || telefoneLimpo.length > 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um telefone válido (10 ou 11 dígitos com DDD).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _estaCarregando = true;
    });

    try {
      final novaSessao = await ServicoAutenticacao.atualizarPerfilUsuario(
        nomeCompleto: nome,
        email: email,
        telefone: telefone,
        cpf: _sessaoAtual.cpf,
      );

      if (!mounted) return;

      setState(() {
        _sessaoAtual = novaSessao;
        _modoEdicao = false;
        _estaCarregando = false;
        _preencherCampos();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Color(0xFF238838),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _estaCarregando = false;
      });

      final msgErro = erro.toString().replaceAll('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msgErro),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _abrirModalRedefinirSenha() {
    final controladorSenhaAtual = TextEditingController();
    final controladorNovaSenha = TextEditingController();
    final controladorConfirmarSenha = TextEditingController();
    final chaveForm = GlobalKey<FormState>();
    bool carregandoModal = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (contextState, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Form(
                key: chaveForm,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Redefinir Senha',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF163791),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controladorSenhaAtual,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha Atual',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (val) => (val == null || val.isEmpty)
                          ? 'Informe sua senha atual'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controladorNovaSenha,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nova Senha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock_reset),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Informe a nova senha';
                        }
                        if (val.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controladorConfirmarSenha,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Nova Senha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.check_circle_outline),
                      ),
                      validator: (val) {
                        if (val != controladorNovaSenha.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF238838),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: carregandoModal
                            ? null
                            : () async {
                                if (chaveForm.currentState!.validate()) {
                                  setStateModal(() => carregandoModal = true);
                                  try {
                                    await ServicoAutenticacao.alterarSenhaLogado(
                                      senhaAtual: controladorSenhaAtual.text,
                                      novaSenha: controladorNovaSenha.text,
                                    );
                                    if (!mounted) return;
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Senha redefinida com sucesso!',
                                        ),
                                        backgroundColor: Color(0xFF238838),
                                      ),
                                    );
                                  } catch (e) {
                                    setStateModal(() => carregandoModal = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erro: $e'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: carregandoModal
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'CONFIRMAR REDEFINIÇÃO',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _fazerLogout() async {
    await ServicoAutenticacao.encerrarSessao();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TelaLoginUsuario()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nomeParaExibir = _controladorNome.text.trim().isNotEmpty
        ? _controladorNome.text.trim().toUpperCase()
        : (_sessaoAtual.nomeCompleto.isNotEmpty
            ? _sessaoAtual.nomeCompleto.toUpperCase()
            : 'USUÁRIO');

    final emailParaExibir = _controladorEmail.text.trim().isNotEmpty
        ? _controladorEmail.text.trim()
        : _sessaoAtual.email;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.aoVoltar != null || Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF163791)),
                onPressed: widget.aoVoltar ?? () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Avatar de Perfil com Botão de Câmera
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecione uma foto de perfil da galeria.'),
                          ),
                        );
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF238838),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Nome do Usuário em caixa alta (Editável) e E-mail
            if (_modoEdicao) ...[
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF238838), width: 1.5),
                ),
                child: TextField(
                  controller: _controladorNome,
                  focusNode: _focoNome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF163791),
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: InputBorder.none,
                    hintText: 'DIGITE SEU NOME',
                  ),
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _modoEdicao = true;
                  });
                  _focoNome.requestFocus();
                },
                child: Text(
                  _controladorNome.text.isNotEmpty
                      ? _controladorNome.text.toUpperCase()
                      : nomeParaExibir,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF163791),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              emailParaExibir,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 28),

            // 3. Campo Nome Completo (Editável)
            _construirCampoInformacao(
              rotulo: 'Nome Completo',
              controlador: _controladorNome,
              editavel: _modoEdicao,
              focoNode: _focoNome,
              iconeSufixo: Icons.edit,
              corIcone: const Color(0xFF238838),
              aoTocarIcone: () {
                setState(() {
                  _modoEdicao = true;
                });
                _focoNome.requestFocus();
              },
            ),

            const SizedBox(height: 18),

            // 4. Campo CPF (Bloqueado / Leitura)
            _construirCampoInformacao(
              rotulo: 'CPF',
              controlador: _controladorCpf,
              editavel: false,
              iconeSufixo: Icons.lock_outline,
              corIcone: const Color(0xFF238838),
              corFundo: const Color(0xFFF1F5F9),
            ),

            const SizedBox(height: 18),

            // 5. Campo E-mail (Editável)
            _construirCampoInformacao(
              rotulo: 'E-mail',
              controlador: _controladorEmail,
              editavel: _modoEdicao,
              focoNode: _focoEmail,
              tipoTeclado: TextInputType.emailAddress,
              iconeSufixo: Icons.edit,
              corIcone: const Color(0xFF238838),
              aoTocarIcone: () {
                setState(() {
                  _modoEdicao = true;
                });
                _focoEmail.requestFocus();
              },
            ),

            const SizedBox(height: 18),

            // 6. Campo Telefone (Editável com máscara)
            _construirCampoInformacao(
              rotulo: 'Telefone',
              controlador: _controladorTelefone,
              editavel: _modoEdicao,
              focoNode: _focoTelefone,
              tipoTeclado: TextInputType.phone,
              formatadores: [MascaraTelefoneFormatter()],
              iconeSufixo: Icons.edit,
              corIcone: const Color(0xFF238838),
              aoTocarIcone: () {
                setState(() {
                  _modoEdicao = true;
                });
                _focoTelefone.requestFocus();
              },
            ),

            const SizedBox(height: 28),

            // 6. Botão EDITAR CONTA / SALVAR ALTERAÇÕES (Azul Principal)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _estaCarregando
                    ? null
                    : () {
                        if (_modoEdicao) {
                          _salvarAlteracoesPerfil();
                        } else {
                          setState(() {
                            _modoEdicao = true;
                          });
                          _focoEmail.requestFocus();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF163791),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  _modoEdicao ? Icons.check_circle_outline : Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                label: _estaCarregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _modoEdicao ? 'SALVAR ALTERAÇÕES' : 'EDITAR CONTA',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 14),

            // 7. Botão REDEFINIR SENHA (Secundário Verde Claro)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _abrirModalRedefinirSenha,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0FDF4),
                  side: const BorderSide(color: Color(0xFFDCFCE7), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF238838),
                  size: 22,
                ),
                label: const Text(
                  'REDEFINIR SENHA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF238838),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 8. Botão Sair da conta (Vermelho)
            GestureDetector(
              onTap: _fazerLogout,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFDC2626),
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Sair da conta',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// WIDGET: Campo de Informação Estilizado conforme Layout da Foto
  Widget _construirCampoInformacao({
    required String rotulo,
    required TextEditingController controlador,
    required bool editavel,
    FocusNode? focoNode,
    TextInputType? tipoTeclado,
    List<TextInputFormatter>? formatadores,
    required IconData iconeSufixo,
    required Color corIcone,
    Color corFundo = Colors.white,
    VoidCallback? aoTocarIcone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: editavel ? const Color(0xFF238838) : const Color(0xFFE2E8F0),
              width: editavel ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controlador,
            enabled: editavel,
            focusNode: focoNode,
            keyboardType: tipoTeclado,
            inputFormatters: formatadores,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: editavel ? const Color(0xFF0F172A) : const Color(0xFF334155),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(iconeSufixo, color: corIcone, size: 20),
                onPressed: aoTocarIcone,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
