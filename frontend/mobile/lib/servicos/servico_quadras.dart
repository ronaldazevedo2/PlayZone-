import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/modelo_quadra.dart';
import 'servico_autenticacao.dart';

class ServicoQuadras {
  // URLs para conexao com a API local
  // Para emuladores Android, '10.0.2.2' mapeia para o localhost da maquina hospedeira.
  // Para iOS, web ou dispositivos na mesma rede, usamos 'localhost' ou o IP local.
  static const String _urlBasePadrao = 'https://10.0.2.2:7200';
  static const String _urlBaseAlternativa = 'https://localhost:7200';

  static String _urlBaseAtual = _urlBasePadrao;

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
    final url1 = Uri.parse('$_urlBaseAtual$rota');
    final corpoString = corpo != null ? jsonEncode(corpo) : null;
    final cabecalhos = await _obterCabecalhos();

    try {
      if (metodo == 'GET') {
        return await http.get(url1, headers: cabecalhos).timeout(const Duration(seconds: 5));
      } else if (metodo == 'POST') {
        return await http.post(url1, headers: cabecalhos, body: corpoString).timeout(const Duration(seconds: 5));
      } else if (metodo == 'PUT') {
        return await http.put(url1, headers: cabecalhos, body: corpoString).timeout(const Duration(seconds: 5));
      } else if (metodo == 'DELETE') {
        return await http.delete(url1, headers: cabecalhos).timeout(const Duration(seconds: 5));
      }
      throw Exception('Método HTTP não suportado: $metodo');
    } catch (_) {
      try {
        _urlBaseAtual = _urlBaseAtual == _urlBasePadrao ? _urlBaseAlternativa : _urlBasePadrao;
        final urlNova = Uri.parse('$_urlBaseAtual$rota');
        if (metodo == 'GET') {
          return await http.get(urlNova, headers: cabecalhos).timeout(const Duration(seconds: 5));
        } else if (metodo == 'POST') {
          return await http.post(urlNova, headers: cabecalhos, body: corpoString).timeout(const Duration(seconds: 5));
        } else if (metodo == 'PUT') {
          return await http.put(urlNova, headers: cabecalhos, body: corpoString).timeout(const Duration(seconds: 5));
        } else if (metodo == 'DELETE') {
          return await http.delete(urlNova, headers: cabecalhos).timeout(const Duration(seconds: 5));
        }
        throw Exception('Método HTTP não suportado: $metodo');
      } catch (erroConexao) {
        throw Exception('Sem conexão com o servidor de quadras ($erroConexao).');
      }
    }
  }

  /// Busca a lista completa de quadras
  static Future<List<QuadraEsportiva>> obterQuadras() async {
    final resposta = await _fazerRequisicao('GET', '/api/Quadra?pagina=1&tamanhoPagina=100', null);
    
    if (resposta.statusCode == 200) {
      final dadosResposta = jsonDecode(resposta.body);
      final bool ok = dadosResposta['ok'] ?? false;
      if (ok && dadosResposta['dados'] != null) {
        final itens = dadosResposta['dados']['itens'] as List<dynamic>?;
        if (itens != null) {
          return itens.map((item) => QuadraEsportiva.deJson(item)).toList();
        }
      }
      return [];
    } else {
      throw Exception('Falha ao obter quadras (${resposta.statusCode})');
    }
  }

  /// Busca uma quadra específica pelo seu ID
  static Future<QuadraEsportiva> obterQuadraPorId(String id) async {
    final resposta = await _fazerRequisicao('GET', '/api/Quadra/$id', null);
    
    if (resposta.statusCode == 200) {
      final dadosResposta = jsonDecode(resposta.body);
      final bool ok = dadosResposta['ok'] ?? false;
      if (ok && dadosResposta['dados'] != null) {
        return QuadraEsportiva.deJson(dadosResposta['dados']);
      }
      throw Exception(dadosResposta['mensagem'] ?? 'Erro desconhecido ao obter quadra.');
    } else {
      throw Exception('Quadra não encontrada (${resposta.statusCode})');
    }
  }

  /// Cria uma nova quadra na API
  static Future<QuadraEsportiva> criarQuadra(QuadraEsportiva quadra) async {
    final resposta = await _fazerRequisicao('POST', '/api/Quadra', quadra.paraJson());
    
    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      final dadosResposta = jsonDecode(resposta.body);
      final bool ok = dadosResposta['ok'] ?? false;
      if (ok && dadosResposta['dados'] != null) {
        return QuadraEsportiva.deJson(dadosResposta['dados']);
      }
      throw Exception(dadosResposta['mensagem'] ?? 'Erro desconhecido ao criar quadra.');
    } else {
      throw Exception('Falha ao criar quadra (${resposta.statusCode})');
    }
  }

  /// Atualiza os dados de uma quadra específica
  static Future<void> atualizarQuadra(QuadraEsportiva quadra) async {
    final resposta = await _fazerRequisicao('PUT', '/api/Quadra/${quadra.id}', quadra.paraJson());
    
    if (resposta.statusCode != 200) {
      final dadosResposta = jsonDecode(resposta.body);
      final String msg = dadosResposta['mensagem'] ?? 'Erro ao atualizar quadra.';
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
