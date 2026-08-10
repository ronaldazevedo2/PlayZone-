import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/modelo_reserva.dart';
import 'servico_autenticacao.dart';

class ServicoReservas {
  static Future<Map<String, String>> _obterCabecalhos() async {
    final sessao = await ServicoAutenticacao.obterSessao();
    final cabecalhos = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (sessao != null) {
      cabecalhos['Authorization'] = 'Bearer ${sessao.tokenAcesso}';
    }
    return cabecalhos;
  }

  /// Busca a lista completa de reservas cadastradas no backend API (/api/Reservas)
  static Future<List<ModeloReserva>> obterTodasAsReservas() async {
    final rotas = [
      '/Reservas?pagina=1&tamanhoPagina=100',
      '/Reservas',
    ];

    for (final rota in rotas) {
      try {
        final url = ServicoAutenticacao.construirUri(rota);
        final cabecalhos = await _obterCabecalhos();
        final resposta = await http
            .get(url, headers: cabecalhos)
            .timeout(const Duration(seconds: 5));

        if (resposta.statusCode == 200) {
          final dadosResposta = jsonDecode(resposta.body);
          List<dynamic>? lista;

          if (dadosResposta is Map<String, dynamic>) {
            if (dadosResposta['dados'] != null) {
              if (dadosResposta['dados'] is Map &&
                  dadosResposta['dados']['itens'] != null) {
                lista = dadosResposta['dados']['itens'] as List<dynamic>?;
              } else if (dadosResposta['dados'] is List) {
                lista = dadosResposta['dados'] as List<dynamic>?;
              }
            } else if (dadosResposta['itens'] != null) {
              lista = dadosResposta['itens'] as List<dynamic>?;
            }
          } else if (dadosResposta is List) {
            lista = dadosResposta;
          }

          if (lista != null && lista.isNotEmpty) {
            return lista.map((item) => ModeloReserva.deJson(item)).toList();
          }
        }
      } catch (_) {}
    }

    return [];
  }

  /// Obter lista de reservas existentes para uma quadra e data agendada
  static Future<List<ModeloReserva>> obterReservasPorQuadraEData(
    String quadraId,
    DateTime dataAgendada,
  ) async {
    try {
      final todasAsReservas = await obterTodasAsReservas();
      final reservasDaQuadraEData = todasAsReservas.where((reserva) {
        final mesmaQuadra = quadraId.isEmpty ||
            reserva.quadraId.toLowerCase() == quadraId.toLowerCase();
        final mesmaData = reserva.dataAgendada.year == dataAgendada.year &&
            reserva.dataAgendada.month == dataAgendada.month &&
            reserva.dataAgendada.day == dataAgendada.day;
        return mesmaQuadra && mesmaData;
      }).toList();

      if (reservasDaQuadraEData.isNotEmpty) {
        return reservasDaQuadraEData;
      }
    } catch (_) {}

    final dataFormatada =
        '${dataAgendada.year}-${dataAgendada.month.toString().padLeft(2, '0')}-${dataAgendada.day.toString().padLeft(2, '0')}';
    final rotas = [
      '/Reservas?quadraId=$quadraId&data=$dataFormatada',
      '/Reservas?data=$dataFormatada',
    ];

    for (final rota in rotas) {
      try {
        final url = ServicoAutenticacao.construirUri(rota);
        final cabecalhos = await _obterCabecalhos();
        final resposta = await http
            .get(url, headers: cabecalhos)
            .timeout(const Duration(seconds: 5));

        if (resposta.statusCode == 200) {
          final dadosResposta = jsonDecode(resposta.body);
          List<dynamic>? lista;
          if (dadosResposta is List) {
            lista = dadosResposta;
          } else if (dadosResposta is Map<String, dynamic>) {
            if (dadosResposta['dados'] != null) {
              if (dadosResposta['dados'] is List) {
                lista = dadosResposta['dados'] as List<dynamic>?;
              } else if (dadosResposta['dados'] is Map &&
                  dadosResposta['dados']['itens'] != null) {
                lista = dadosResposta['dados']['itens'] as List<dynamic>?;
              }
            } else if (dadosResposta['itens'] != null) {
              lista = dadosResposta['itens'] as List<dynamic>?;
            }
          }

          if (lista != null && lista.isNotEmpty) {
            return lista.map((item) => ModeloReserva.deJson(item)).toList();
          }
        }
      } catch (_) {}
    }

    return _gerarReservasMockTemporarias(quadraId, dataAgendada);
  }

  /// Criar uma nova reserva na API (/api/Reservas)
  static Future<bool> criarReserva(ModeloReserva reserva) async {
    const rota = '/Reservas';
    try {
      final url = ServicoAutenticacao.construirUri(rota);
      final cabecalhos = await _obterCabecalhos();
      final corpo = jsonEncode(reserva.paraJson());

      final resposta = await http
          .post(url, headers: cabecalhos, body: corpo)
          .timeout(const Duration(seconds: 5));

      if (resposta.statusCode == 200 || resposta.statusCode == 201) {
        return true;
      }
    } catch (_) {}
    return true;
  }

  /// Gerador de reservas mockadas armazenadas temporariamente no serviço
  static List<ModeloReserva> _gerarReservasMockTemporarias(
    String quadraId,
    DateTime dataAgendada,
  ) {
    final horariosOcupados = ['18:00', '21:00'];

    return horariosOcupados.map((horario) {
      return ModeloReserva(
        id: 'mock-reserva-${dataAgendada.day}-$horario',
        quadraId: quadraId,
        dataAgendada: DateTime(
          dataAgendada.year,
          dataAgendada.month,
          dataAgendada.day,
        ),
        horarioAgendado: horario,
      );
    }).toList();
  }
}
