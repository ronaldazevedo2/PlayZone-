import 'dart:io';
import 'package:flutter/foundation.dart';
import '../servicos/servico_autenticacao.dart';

class QuadraEsportiva {
  final String id;
  final String nome;
  final String modalidade;
  final String bairro;
  final String endereco;
  final int capacidade;
  final String descricao;
  final double precoPorHora;
  final bool estaDisponivel;
  final String status;
  final double avaliacao;
  final double distanciaEmKm;
  final String caminhoImagem;

  const QuadraEsportiva({
    required this.id,
    required this.nome,
    required this.modalidade,
    required this.bairro,
    required this.endereco,
    required this.capacidade,
    required this.descricao,
    required this.precoPorHora,
    required this.estaDisponivel,
    this.status = 'Ativa',
    this.avaliacao = 4.8,
    required this.distanciaEmKm,
    required this.caminhoImagem,
  });

  factory QuadraEsportiva.deJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['Id'] ?? json['quadraId'] ?? json['QuadraId'])?.toString() ?? '';
    final nome = (json['nome'] ?? json['Nome'] ?? json['titulo'] ?? json['Titulo'])?.toString() ?? 'Quadra Poliesportiva';
    final modalidade = (json['modalidade'] ?? json['Modalidade'] ?? json['esporte'] ?? json['Esporte'])?.toString() ?? 'Futebol';
    final localizacao = (json['localizacao'] ?? json['Localizacao'] ?? json['endereco'] ?? json['Endereco'] ?? json['bairro'] ?? json['Bairro'] ?? json['localidade'])?.toString() ?? 'Centro';

    final capRaw = json['capacidade'] ?? json['Capacidade'];
    final int capacidade = capRaw is int
        ? capRaw
        : (int.tryParse(capRaw?.toString() ?? '') ?? 10);

    final descricao = (json['descricao'] ?? json['Descricao'])?.toString() ??
        'Quadra poliesportiva oficial para treinos e jogos.';
    final imagemUrl = (json['imagemUrl'] ?? json['ImagemUrl'] ?? json['caminhoImagem'] ?? json['CaminhoImagem'] ?? json['fotoUrl'] ?? json['FotoUrl'])?.toString();
    final status = (json['status'] ?? json['Status'])?.toString() ?? 'Ativa';

    final precoRaw = json['precoPorHora'] ?? json['PrecoPorHora'] ?? json['preco'] ?? json['Preco'] ?? json['valor'] ?? json['Valor'];
    final double precoPorHora = precoRaw != null
        ? (double.tryParse(precoRaw.toString()) ?? (capacidade > 0 ? capacidade * 15.0 : 150.0))
        : (capacidade > 0 ? (capacidade * 15.0) : 150.0);

    final bairro = _extrairBairro(localizacao);
    final endereco = localizacao;

    final hash = id.hashCode.abs();
    final distanciaEmKm = 1.0 + (hash % 40) / 10.0;
    final avaliacaoCalculada = 4.2 + (hash % 8) / 10.0;
    final caminhoImagem = _obterImagemEsporte(imagemUrl, modalidade);

    return QuadraEsportiva(
      id: id,
      nome: nome,
      modalidade: modalidade,
      bairro: bairro,
      endereco: endereco,
      capacidade: capacidade,
      descricao: descricao,
      precoPorHora: precoPorHora,
      estaDisponivel: status.toLowerCase() != 'inativa' &&
          status.toLowerCase() != 'indisponivel' &&
          status.toLowerCase() != 'indisponível',
      status: status,
      avaliacao: double.parse(avaliacaoCalculada.toStringAsFixed(1)),
      distanciaEmKm: distanciaEmKm,
      caminhoImagem: caminhoImagem,
    );
  }

  List<String> get listaModalidades {
    if (modalidade.trim().isEmpty) return [];
    final partes = modalidade.split(RegExp(r'[,/]|(?:\s+e\s+)|\s+E\s+', caseSensitive: false));
    return partes.map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'capacidade': capacidade,
      'localizacao': '$endereco - $bairro',
      'modalidade': modalidade,
      'imagemUrl': caminhoImagem,
      'status': status,
    };
  }

  static String _extrairBairro(String localizacao) {
    if (localizacao.contains('-')) {
      return localizacao.split('-').last.trim();
    }
    if (localizacao.contains(',')) {
      final partes = localizacao.split(',');
      if (partes.length > 1) {
        return partes[1].trim();
      }
    }
    return localizacao.trim().isEmpty ? 'Centro' : localizacao.trim();
  }

  static String _obterImagemEsporte(String? imagemUrl, String modalidade) {
    if (imagemUrl != null &&
        imagemUrl.trim().isNotEmpty &&
        !imagemUrl.contains('exemplo.com') &&
        !imagemUrl.contains('example.com')) {
      var url = imagemUrl.trim();
      if (!kIsWeb && Platform.isAndroid) {
        url = url.replaceAll('localhost', '10.0.2.2');
        url = url.replaceAll('127.0.0.1', '10.0.2.2');
      }
      if (url.startsWith('http://') || url.startsWith('https://')) {
        if (kIsWeb &&
            !url.contains('localhost') &&
            !url.contains('127.0.0.1') &&
            !url.contains('weserv.nl')) {
          return 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}';
        }
        return url;
      } else if (url.startsWith('/')) {
        final baseUrl = ServicoAutenticacao.obterUrlBase();
        final hostSemApi = baseUrl.replaceAll('/api', '');
        return '$hostSemApi$url';
      }
    }
    final mod = modalidade.toLowerCase();
    if (mod.contains('tenis') || mod.contains('tênis')) {
      return 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?q=80&w=600&auto=format&fit=crop';
    } else if (mod.contains('futebol') ||
        mod.contains('soccer') ||
        mod.contains('society') ||
        mod.contains('futsal')) {
      return 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop';
    } else if (mod.contains('basquete') || mod.contains('basketball')) {
      return 'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=600&auto=format&fit=crop';
    } else if (mod.contains('volei') || mod.contains('vôlei')) {
      return 'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?q=80&w=600&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=600&auto=format&fit=crop';
  }
}
