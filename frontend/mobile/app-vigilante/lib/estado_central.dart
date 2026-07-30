import 'package:flutter/material.dart';
import 'servicos/servico_armazenamento.dart';
import 'servicos/servico_banco_dados.dart';

enum TipoStatusAcesso {
  liberado,
  pendente,
  livre,
  dentro, // novo status para quando o usuário está dentro da arena
}

class Vigilante {
  final String nome;
  final String email;
  final String matricula;
  final String senha;

  Vigilante({
    required this.nome,
    required this.email,
    required this.matricula,
    required this.senha,
  });
}

class ClienteArena {
  final String nome;
  final String cpf;
  final String matricula;
  final String localReserva;
  final String horarioPrevisto;
  TipoStatusAcesso statusAcesso;
  final String fotoUrl;

  ClienteArena({
    required this.nome,
    required this.cpf,
    required this.matricula,
    required this.localReserva,
    required this.horarioPrevisto,
    required this.statusAcesso,
    required this.fotoUrl,
  });
}

class RegistroAcessoHistorico {
  final String nome;
  final String local;
  final String dataHora;
  final TipoStatusAcesso status;

  RegistroAcessoHistorico({
    required this.nome,
    required this.local,
    required this.dataHora,
    required this.status,
  });
}

class MensagemChat {
  final String texto;
  final DateTime dataHora;
  final bool enviadaPorMim;

  MensagemChat({
    required this.texto,
    required this.dataHora,
    required this.enviadaPorMim,
  });
}

enum TipoFeedback {
  sugestao,
  problema,
  elogio,
}

class FeedbackUsuario {
  final String id;
  final TipoFeedback tipo;
  final int avaliacao; // 1-5 estrelas
  final String descricao;
  final DateTime dataHora;
  final String nomeVigilante;

  FeedbackUsuario({
    required this.id,
    required this.tipo,
    required this.avaliacao,
    required this.descricao,
    required this.dataHora,
    required this.nomeVigilante,
  });
}

class NotificacaoVigilante {
  final String id;
  final String titulo;
  final String descricao;
  final String tempoPassado;
  final IconData icone;
  final Color corIcone;
  bool lida;
  final List<MensagemChat> conversa;

  NotificacaoVigilante({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tempoPassado,
    required this.icone,
    required this.corIcone,
    this.lida = false,
    required this.conversa,
  });
}

class EstadoCentral extends ChangeNotifier {
  // Singleton
  static final EstadoCentral _instancia = EstadoCentral._interno();
  factory EstadoCentral() => _instancia;
  EstadoCentral._interno() {
    _inicializarDadosFicticios();
  }

  final ServicoArmazenamento _armazenamento = ServicoArmazenamento();
  final ServicoBancoDados _bancoDados = ServicoBancoDados();

  // Sessão e Usuários
  final List<Vigilante> _vigilantes = [];
  Vigilante? _vigilanteLogado;

  // Clientes na Arena
  final List<ClienteArena> _clientes = [];

  // Histórico de acessos
  final List<RegistroAcessoHistorico> _historico = [];

  // Notificações
  final List<NotificacaoVigilante> _notificacoes = [];

  // Feedbacks do usuário
  final List<FeedbackUsuario> _feedbacks = [];

  // Configurações
  bool _modoEscuroAtivo = false;
  bool _biometriaAtiva = true;
  bool _notificacoesAtivas = true;
  String _idiomaSelecionado = 'Português (BR)';

  // Controle de sessão carregada
  bool _sessaoCarregada = false;
  bool get sessaoCarregada => _sessaoCarregada;

  // Getters
  List<Vigilante> get vigilantes => _vigilantes;
  Vigilante? get vigilanteLogado => _vigilanteLogado;
  List<ClienteArena> get clientes => _clientes;
  List<RegistroAcessoHistorico> get historico => _historico;
  List<NotificacaoVigilante> get notificacoes => _notificacoes;
  List<FeedbackUsuario> get feedbacks => _feedbacks;
  bool get modoEscuroAtivo => _modoEscuroAtivo;
  bool get biometriaAtiva => _biometriaAtiva;
  bool get notificacoesAtivas => _notificacoesAtivas;
  String get idiomaSelecionado => _idiomaSelecionado;

  // Inicialização de dados simulados e carregamento do banco de dados
  void _inicializarDadosFicticios() {
    carregarVigilantesDoBanco();

    // Adiciona clientes mockados da arena
    _clientes.addAll([
      ClienteArena(
        nome: "Ricardo Silva",
        cpf: "123.456.789-00",
        matricula: "1001",
        localReserva: "Quadra A",
        horarioPrevisto: "18:00",
        statusAcesso: TipoStatusAcesso.liberado,
        fotoUrl: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80",
      ),
      ClienteArena(
        nome: "André Costa",
        cpf: "987.654.321-00",
        matricula: "1002",
        localReserva: "Quadra 2",
        horarioPrevisto: "19:00",
        statusAcesso: TipoStatusAcesso.pendente,
        fotoUrl: "https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=150&q=80",
      ),
      ClienteArena(
        nome: "Juliana Alves",
        cpf: "654.321.987-00",
        matricula: "1003",
        localReserva: "Quadra 1",
        horarioPrevisto: "14:00",
        statusAcesso: TipoStatusAcesso.liberado,
        fotoUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80",
      ),
      ClienteArena(
        nome: "Carlos Pereira",
        cpf: "321.987.654-00",
        matricula: "1004",
        localReserva: "Quadra B",
        horarioPrevisto: "16:00",
        statusAcesso: TipoStatusAcesso.liberado,
        fotoUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80",
      ),
      ClienteArena(
        nome: "Mariana Lima",
        cpf: "432.109.876-00",
        matricula: "1005",
        localReserva: "Quadra C",
        horarioPrevisto: "12:00",
        statusAcesso: TipoStatusAcesso.livre,
        fotoUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150&q=80",
      ),
    ]);

    // Histórico de acessos inicial
    _historico.addAll([
      RegistroAcessoHistorico(
        nome: "Ricardo Silva",
        local: "Quadra A",
        dataHora: "17:55 - 29/05/2026",
        status: TipoStatusAcesso.liberado,
      ),
      RegistroAcessoHistorico(
        nome: "André Costa",
        local: "Quadra 2",
        dataHora: "19:03 - 29/05/2026",
        status: TipoStatusAcesso.pendente,
      ),
      RegistroAcessoHistorico(
        nome: "Juliana Alves",
        local: "Quadra 1",
        dataHora: "14:50 - 29/05/2026",
        status: TipoStatusAcesso.liberado,
      ),
      RegistroAcessoHistorico(
        nome: "Carlos Pereira",
        local: "Quadra B",
        dataHora: "16:18 - 29/05/2026",
        status: TipoStatusAcesso.liberado,
      ),
      RegistroAcessoHistorico(
        nome: "Mariana Lima",
        local: "Quadra C",
        dataHora: "12:45 - 29/05/2026",
        status: TipoStatusAcesso.livre,
      ),
    ]);

    // Notificações iniciais com conversas estilo chat
    _notificacoes.addAll([
      NotificacaoVigilante(
        id: "notif_1",
        titulo: "Entrada registrada - Quadra A",
        descricao: "O cliente Ricardo Silva acessou a arena após validação de QR Code.",
        tempoPassado: "Há 10 min",
        icone: Icons.check_circle_outline,
        corIcone: const Color(0xFF0B7F38),
        conversa: [
          MensagemChat(
            texto: "Ricardo Silva acabou de entrar na Quadra A.",
            dataHora: DateTime.now().subtract(const Duration(minutes: 10)),
            enviadaPorMim: false,
          ),
          MensagemChat(
            texto: "Tudo certo com a identificação dele?",
            dataHora: DateTime.now().subtract(const Duration(minutes: 9)),
            enviadaPorMim: true,
          ),
          MensagemChat(
            texto: "Sim, reserva validada via QR Code com sucesso.",
            dataHora: DateTime.now().subtract(const Duration(minutes: 8)),
            enviadaPorMim: false,
          ),
        ],
      ),
      NotificacaoVigilante(
        id: "notif_2",
        titulo: "Alerta de atraso detectado",
        descricao: "A partida da Quadra 2 agendada para André Costa ultrapassou 10 minutos do horário previsto.",
        tempoPassado: "Há 1 hora",
        icone: Icons.warning_amber_outlined,
        corIcone: const Color(0xFFF59E0B),
        conversa: [
          MensagemChat(
            texto: "Atenção: A partida de André Costa na Quadra 2 está atrasada.",
            dataHora: DateTime.now().subtract(const Duration(hours: 1)),
            enviadaPorMim: false,
          ),
          MensagemChat(
            texto: "Vou verificar na quadra se eles já estão finalizando.",
            dataHora: DateTime.now().subtract(const Duration(minutes: 50)),
            enviadaPorMim: true,
          ),
        ],
      ),
      NotificacaoVigilante(
        id: "notif_3",
        titulo: "Nova reserva cadastrada",
        descricao: "A Quadra E foi agendada para hoje das 17:00 às 18:00.",
        tempoPassado: "Há 3 horas",
        icone: Icons.event_note,
        corIcone: const Color(0xFF09398E),
        conversa: [
          MensagemChat(
            texto: "Nova reserva confirmada na Quadra E.",
            dataHora: DateTime.now().subtract(const Duration(hours: 3)),
            enviadaPorMim: false,
          ),
        ],
      ),
      NotificacaoVigilante(
        id: "notif_4",
        titulo: "Atualização de sistema",
        descricao: "O aplicativo do vigilante foi atualizado com melhorias de desempenho.",
        tempoPassado: "Há 1 dia",
        icone: Icons.system_update_alt,
        corIcone: const Color(0xFF64748B),
        lida: true,
        conversa: [
          MensagemChat(
            texto: "Olá! Atualizamos o app com melhorias importantes de performance e estabilidade do scanner.",
            dataHora: DateTime.now().subtract(const Duration(days: 1)),
            enviadaPorMim: false,
          ),
        ],
      ),
    ]);
  }

  /// Carrega a lista de vigilantes do banco de dados local
  Future<void> carregarVigilantesDoBanco() async {
    final cadastradosBanco = await _bancoDados.obterTodosVigilantes();
    if (cadastradosBanco.isEmpty) {
      // Adiciona o vigilante padrão no banco de dados se a tabela estiver vazia
      final vigilantePadrao = VigilanteRegistro(
        nome: "João da Silva",
        email: "joao@gmail.com",
        matricula: "4587",
        senha: "123456",
      );
      await _bancoDados.salvarVigilante(vigilantePadrao);
      _vigilantes.clear();
      _vigilantes.add(Vigilante(
        nome: vigilantePadrao.nome,
        email: vigilantePadrao.email,
        matricula: vigilantePadrao.matricula,
        senha: vigilantePadrao.senha,
      ));
    } else {
      _vigilantes.clear();
      for (final reg in cadastradosBanco) {
        _vigilantes.add(Vigilante(
          nome: reg.nome,
          email: reg.email,
          matricula: reg.matricula,
          senha: reg.senha,
        ));
      }
    }
    notifyListeners();
  }

  // Métodos de Autenticação
  Future<bool> cadastrarVigilante(String nome, String email, String matricula, String senha) async {
    final vigilanteExistente = await _bancoDados.buscarVigilantePorEmail(email);
    if (vigilanteExistente != null || _vigilantes.any((v) => v.email.toLowerCase() == email.trim().toLowerCase())) {
      return false;
    }

    final novoRegistro = VigilanteRegistro(
      nome: nome.trim(),
      email: email.trim(),
      matricula: matricula.trim(),
      senha: senha,
    );

    await _bancoDados.salvarVigilante(novoRegistro);

    _vigilantes.add(Vigilante(
      nome: novoRegistro.nome,
      email: novoRegistro.email,
      matricula: novoRegistro.matricula,
      senha: novoRegistro.senha,
    ));

    notifyListeners();
    return true;
  }

  String? autenticarVigilante(String email, String senha) {
    final vigilante = _vigilantes.firstWhere(
      (v) => v.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => Vigilante(nome: '', email: '', matricula: '', senha: ''),
    );

    if (vigilante.email.isEmpty) {
      return "Usuário não cadastrado";
    }

    if (vigilante.senha != senha) {
      return "Senha incorreta";
    }

    _vigilanteLogado = vigilante;
    notifyListeners();
    return null; // Sucesso
  }

  /// Tenta restaurar a sessão salva a partir do email armazenado.
  /// Retorna true se a sessão foi restaurada com sucesso.
  Future<bool> restaurarSessao() async {
    await carregarVigilantesDoBanco();
    final emailSalvo = await _armazenamento.obterEmailSessao();
    if (emailSalvo != null) {
      final vigilante = _vigilantes.firstWhere(
        (v) => v.email.toLowerCase() == emailSalvo.toLowerCase(),
        orElse: () => Vigilante(nome: '', email: '', matricula: '', senha: ''),
      );
      if (vigilante.email.isNotEmpty) {
        _vigilanteLogado = vigilante;
        _sessaoCarregada = true;
        notifyListeners();
        return true;
      }
    }
    _sessaoCarregada = true;
    return false;
  }

  /// Salva a sessão do vigilante atualmente logado.
  Future<void> salvarSessao() async {
    if (_vigilanteLogado != null) {
      await _armazenamento.salvarSessao(_vigilanteLogado!.email);
    }
  }

  void deslogarVigilante() {
    _vigilanteLogado = null;
    _armazenamento.limparSessao();
    notifyListeners();
  }

  bool recuperarSenha(String email) {
    return _vigilantes.any((v) => v.email.toLowerCase() == email.trim().toLowerCase());
  }

  // Métodos de Configuração
  void alterarModoEscuro(bool valor) {
    _modoEscuroAtivo = valor;
    _armazenamento.salvarModoEscuro(valor);
    notifyListeners();
  }

  void alterarBiometria(bool valor) {
    _biometriaAtiva = valor;
    notifyListeners();
  }

  void alterarNotificacoes(bool valor) {
    _notificacoesAtivas = valor;
    _armazenamento.salvarNotificacoes(valor);
    notifyListeners();
  }

  void alterarIdioma(String valor) {
    _idiomaSelecionado = valor;
    _armazenamento.salvarIdioma(valor);
    notifyListeners();
  }

  /// Carrega as preferências salvas no dispositivo.
  Future<void> carregarPreferencias() async {
    await carregarVigilantesDoBanco();
    _modoEscuroAtivo = await _armazenamento.obterModoEscuro();
    _idiomaSelecionado = await _armazenamento.obterIdioma();
    _notificacoesAtivas = await _armazenamento.obterNotificacoes();
    notifyListeners();
  }


  // ─── Feedback ────────────────────────────────────────────────────────────────

  /// Registra um novo feedback do usuário.
  void enviarFeedback({
    required TipoFeedback tipo,
    required int avaliacao,
    required String descricao,
  }) {
    final agora = DateTime.now();
    final novoFeedback = FeedbackUsuario(
      id: 'fb_${agora.millisecondsSinceEpoch}',
      tipo: tipo,
      avaliacao: avaliacao,
      descricao: descricao,
      dataHora: agora,
      nomeVigilante: _vigilanteLogado?.nome ?? 'Anônimo',
    );
    _feedbacks.insert(0, novoFeedback);
    notifyListeners();
  }

  // Métodos da Arena e Acesso
  void registrarEntrada(ClienteArena cliente) {
    cliente.statusAcesso = TipoStatusAcesso.dentro;
    
    // Obter data e hora atual formatada
    final agora = DateTime.now();
    final horaFormatada = "${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}";
    final dataFormatada = "${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}";

    _historico.insert(
      0,
      RegistroAcessoHistorico(
        nome: cliente.nome,
        local: cliente.localReserva,
        dataHora: "$horaFormatada - $dataFormatada",
        status: TipoStatusAcesso.liberado,
      ),
    );

    // Adiciona notificação de entrada
    final novaNotif = NotificacaoVigilante(
      id: "notif_${agora.millisecondsSinceEpoch}",
      titulo: "Entrada registrada - ${cliente.localReserva}",
      descricao: "O cliente ${cliente.nome} acessou a arena.",
      tempoPassado: "Agora mesmo",
      icone: Icons.check_circle_outline,
      corIcone: const Color(0xFF0B7F38),
      conversa: [
        MensagemChat(
          texto: "Entrada de ${cliente.nome} registrada com sucesso na Quadra ${cliente.localReserva}.",
          dataHora: agora,
          enviadaPorMim: false,
        )
      ],
    );
    _notificacoes.insert(0, novaNotif);

    notifyListeners();
  }

  void registrarSaida(ClienteArena cliente) {
    cliente.statusAcesso = TipoStatusAcesso.livre;

    final agora = DateTime.now();
    final horaFormatada = "${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}";
    final dataFormatada = "${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}";

    _historico.insert(
      0,
      RegistroAcessoHistorico(
        nome: cliente.nome,
        local: cliente.localReserva,
        dataHora: "$horaFormatada - $dataFormatada",
        status: TipoStatusAcesso.livre,
      ),
    );

    // Adiciona notificação de saída
    final novaNotif = NotificacaoVigilante(
      id: "notif_${agora.millisecondsSinceEpoch}",
      titulo: "Saída registrada - ${cliente.localReserva}",
      descricao: "O cliente ${cliente.nome} deixou a arena.",
      tempoPassado: "Agora mesmo",
      icone: Icons.info_outline,
      corIcone: const Color(0xFF09398E),
      conversa: [
        MensagemChat(
          texto: "${cliente.nome} registrou a saída da arena.",
          dataHora: agora,
          enviadaPorMim: false,
        )
      ],
    );
    _notificacoes.insert(0, novaNotif);

    notifyListeners();
  }

  // Notificações e Chat
  void marcarNotificacaoComoLida(String id) {
    final notifIndex = _notificacoes.indexWhere((n) => n.id == id);
    if (notifIndex != -1) {
      _notificacoes[notifIndex].lida = true;
      notifyListeners();
    }
  }

  void limparNotificacoes() {
    _notificacoes.clear();
    notifyListeners();
  }

  void enviarMensagemChat(String notificacaoId, String texto) {
    final notifIndex = _notificacoes.indexWhere((n) => n.id == notificacaoId);
    if (notifIndex != -1) {
      _notificacoes[notifIndex].conversa.add(
        MensagemChat(
          texto: texto,
          dataHora: DateTime.now(),
          enviadaPorMim: true,
        ),
      );
      
      // Resposta fictícia do suporte/sistema após 1.5 segundos
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_notificacoes.length > notifIndex) {
          _notificacoes[notifIndex].conversa.add(
            MensagemChat(
              texto: "Mensagem recebida e registrada no sistema da arena.",
              dataHora: DateTime.now(),
              enviadaPorMim: false,
            ),
          );
          notifyListeners();
        }
      });

      notifyListeners();
    }
  }
}
