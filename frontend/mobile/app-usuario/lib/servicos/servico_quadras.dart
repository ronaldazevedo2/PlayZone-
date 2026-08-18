import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/modelo_quadra.dart';
import 'servico_autenticacao.dart';

class ServicoQuadras {
  /// Retorna o cabeçalho base com tipo de conteúdo JSON e autorização se logado
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

  /// Método auxiliar para realizar requisições HTTP, alternando URLs se necessário
  static Future<http.Response> _fazerRequisicao(
    String metodo,
    String rota,
    dynamic corpo,
  ) async {
    final url1 = ServicoAutenticacao.construirUri(rota);
    final corpoString = corpo != null ? jsonEncode(corpo) : null;
    final cabecalhos = await _obterCabecalhos();

    try {
      if (metodo == 'GET') {
        return await http
            .get(url1, headers: cabecalhos)
            .timeout(const Duration(seconds: 5));
      } else if (metodo == 'POST') {
        return await http
            .post(url1, headers: cabecalhos, body: corpoString)
            .timeout(const Duration(seconds: 5));
      } else if (metodo == 'PUT') {
        return await http
            .put(url1, headers: cabecalhos, body: corpoString)
            .timeout(const Duration(seconds: 5));
      } else if (metodo == 'DELETE') {
        return await http
            .delete(url1, headers: cabecalhos)
            .timeout(const Duration(seconds: 5));
      }
      throw Exception('Método HTTP não suportado: $metodo');
    } catch (_) {
      try {
        ServicoAutenticacao.alternarUrlBase();
        final urlNova = ServicoAutenticacao.construirUri(rota);
        if (metodo == 'GET') {
          return await http
              .get(urlNova, headers: cabecalhos)
              .timeout(const Duration(seconds: 5));
        } else if (metodo == 'POST') {
          return await http
              .post(urlNova, headers: cabecalhos, body: corpoString)
              .timeout(const Duration(seconds: 5));
        } else if (metodo == 'PUT') {
          return await http
              .put(urlNova, headers: cabecalhos, body: corpoString)
              .timeout(const Duration(seconds: 5));
        } else if (metodo == 'DELETE') {
          return await http
              .delete(urlNova, headers: cabecalhos)
              .timeout(const Duration(seconds: 5));
        }
        throw Exception('Método HTTP não suportado: $metodo');
      } catch (erroConexao) {
        throw Exception(
          'Sem conexão com o servidor de quadras ($erroConexao).',
        );
      }
    }
  }

  /// Busca a lista completa de quadras via ListaQuadraHandler do C# backend (/api/Quadra)
  static Future<List<QuadraEsportiva>> obterQuadras() async {
    final rotas = [
      '/Quadra?pagina=1&tamanhoPagina=100',
      '/Quadra',
      '/api/Quadra',
    ];

    for (final rota in rotas) {
      try {
        final resposta = await _fazerRequisicao('GET', rota, null);

        if (resposta.statusCode == 200) {
          final dadosResposta = jsonDecode(resposta.body);
          List<dynamic>? lista;

          if (dadosResposta is Map<String, dynamic>) {
            final dados = dadosResposta['dados'] ?? dadosResposta['Dados'];
            if (dados != null) {
              if (dados is Map) {
                lista = (dados['itens'] ?? dados['Itens']) as List<dynamic>?;
              } else if (dados is List) {
                lista = dados;
              }
            } else if (dadosResposta['itens'] != null || dadosResposta['Itens'] != null) {
              lista = (dadosResposta['itens'] ?? dadosResposta['Itens']) as List<dynamic>?;
            }
          } else if (dadosResposta is List) {
            lista = dadosResposta;
          }

          if (lista != null) {
            return lista.map((item) => QuadraEsportiva.deJson(item)).toList();
          }
        }
      } catch (_) {}
    }

    return [
      QuadraEsportiva(
        id: 'quadra-basquete-1',
        nome: 'ARENA BASQUETE ARAÇÁ',
        modalidade: 'Basquete',
        bairro: 'Araçá',
        endereco: 'Rua das Palmeiras, 250',
        capacidade: 10,
        descricao:
            'Quadra de basquete coberta com piso de alta performance e estrutura completa.',
        precoPorHora: 0.0,
        estaDisponivel: true,
        distanciaEmKm: 1.2,
        caminhoImagem:
            'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=600&auto=format&fit=crop',
      ),
      QuadraEsportiva(
        id: 'quadra-futebol-1',
        nome: 'ARENA FUTEBOL SÃO JOSÉ',
        modalidade: 'Futebol',
        bairro: 'São José',
        endereco: 'Rua Principal, 100',
        capacidade: 14,
        descricao:
            'Campo de futebol oficial com gramado sintético e iluminação noturna.',
        precoPorHora: 0.0,
        estaDisponivel: true,
        distanciaEmKm: 1.8,
        caminhoImagem:
            'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop',
      ),
      QuadraEsportiva(
        id: 'quadra-futsal-1',
        nome: 'GINÁSIO FUTSAL INTERLAGOS',
        modalidade: 'Futsal',
        bairro: 'Interlagos',
        endereco: 'Av. Interlagos, 500',
        capacidade: 12,
        descricao:
            'Ginásio coberto preparado para partidas oficiais de Futsal.',
        precoPorHora: 0.0,
        estaDisponivel: true,
        distanciaEmKm: 2.5,
        caminhoImagem:
            'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=600&auto=format&fit=crop',
      ),
      QuadraEsportiva(
        id: 'quadra-volei-1',
        nome: 'ARENA VÔLEI CENTRO',
        modalidade: 'Vôlei',
        bairro: 'Centro',
        endereco: 'Rua do Esporte, 420',
        capacidade: 12,
        descricao:
            'Quadra oficial para prática de Vôlei de quadra e areia.',
        precoPorHora: 0.0,
        estaDisponivel: true,
        distanciaEmKm: 3.1,
        caminhoImagem:
            'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?q=80&w=600&auto=format&fit=crop',
      ),
    ];
  }

  /// Busca uma quadra específica pelo seu ID
  static Future<QuadraEsportiva> obterQuadraPorId(String id) async {
    try {
      final resposta = await _fazerRequisicao('GET', '/api/Quadra/$id', null);

      if (resposta.statusCode == 200) {
        final dadosResposta = jsonDecode(resposta.body);
        if (dadosResposta is Map<String, dynamic>) {
          final bool ok = dadosResposta['ok'] ?? false;
          if (ok && dadosResposta['dados'] != null) {
            return QuadraEsportiva.deJson(dadosResposta['dados']);
          }
          if (dadosResposta['id'] != null || dadosResposta['nome'] != null) {
            return QuadraEsportiva.deJson(dadosResposta);
          }
        }
      }
    } catch (_) {
      // Silenciosamente utiliza o mock de reserva/desenvolvimento
    }

    return QuadraEsportiva(
      id: id,
      nome: 'ARENA CENTRAL - QUADRA A',
      modalidade: 'Sintético Pro',
      bairro: 'São Paulo',
      endereco: 'Rua dos Atletas, 1500',
      capacidade: 10,
      descricao:
          'Quadra oficial com gramado sintético de última geração, iluminação em LED e vestiários premium. Ideal para partidas competitivas e treinos intensos.',
      precoPorHora: 150.0,
      estaDisponivel: true,
      distanciaEmKm: 2.5,
      caminhoImagem:
          'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop',
    );
  }

  /// Cria uma nova quadra na API
  static Future<QuadraEsportiva> criarQuadra(QuadraEsportiva quadra) async {
    final resposta = await _fazerRequisicao(
      'POST',
      '/api/Quadra',
      quadra.paraJson(),
    );

    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      final dadosResposta = jsonDecode(resposta.body);
      final bool ok = dadosResposta['ok'] ?? false;
      if (ok && dadosResposta['dados'] != null) {
        return QuadraEsportiva.deJson(dadosResposta['dados']);
      }
      throw Exception(
        dadosResposta['mensagem'] ?? 'Erro desconhecido ao criar quadra.',
      );
    } else {
      throw Exception('Falha ao criar quadra (${resposta.statusCode})');
    }
  }

  /// Atualiza os dados de uma quadra específica
  static Future<void> atualizarQuadra(QuadraEsportiva quadra) async {
    final resposta = await _fazerRequisicao(
      'PUT',
      '/api/Quadra/${quadra.id}',
      quadra.paraJson(),
    );

    if (resposta.statusCode != 200) {
      final dadosResposta = jsonDecode(resposta.body);
      final String msg =
          dadosResposta['mensagem'] ?? 'Erro ao atualizar quadra.';
      throw Exception(msg);
    }
  }

  /// Remove uma quadra do sistema
  static Future<void> deletarQuadra(String id) async {
    final resposta = await _fazerRequisicao('DELETE', '/api/Quadra/$id', null);

    if (resposta.statusCode != 200) {
      final dadosResposta = jsonDecode(resposta.body);
      final String msg = dadosResposta['mensagem'] ?? 'Erro ao deletar quadra.';
      throw Exception(msg);
    }
  }
}
