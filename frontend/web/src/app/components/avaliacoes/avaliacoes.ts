import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { QuadraService, ReservaQuadraDto } from '../../services/quadra.service';
import { UsuarioService, UsuarioDto } from '../../services/usuario.service';

export interface AvaliacaoItem {
  id: string;
  quadraId: string;
  quadraNome: string;
  quadraModalidade: string;
  quadraImagem: string;
  usuarioNome: string;
  usuarioEmail: string;
  nota: number;
  comentario: string;
  data: string;
}

export interface QuadraAvaliacaoResumo {
  id: string;
  nome: string;
  modalidade: string;
  imagemUrl: string;
  mediaNota: number;
  totalAvaliacoes: number;
  avaliacoes: AvaliacaoItem[];
}

@Component({
  selector: 'app-avaliacoes',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './avaliacoes.html',
  styleUrl: './avaliacoes.css',
})
export class Avaliacoes implements OnInit {
  isLoading = true;
  quadras: ReservaQuadraDto[] = [];
  usuarios: UsuarioDto[] = [];
  quadrasResumo: QuadraAvaliacaoResumo[] = [];
  quadrasFiltradas: QuadraAvaliacaoResumo[] = [];

  termoBusca = '';
  filtroModalidade = 'Todas';
  opcoesModalidades: string[] = ['Todas'];

  // Modal de Detalhes de Avaliação da Quadra
  quadraSelecionada: QuadraAvaliacaoResumo | null = null;
  exibirModalDetalhes = false;

  // Paginação simples
  paginaAtual = 1;
  itensPorPagina = 12;

  constructor(
    private quadraService: QuadraService,
    private usuarioService: UsuarioService
  ) {}

  ngOnInit(): void {
    this.carregarDados();
  }

  carregarDados(): void {
    this.isLoading = true;
    this.quadraService.listar(1, 100).subscribe({
      next: (resQuadras) => {
        this.quadras = (resQuadras?.dados?.itens && resQuadras.dados.itens.length > 0) ? resQuadras.dados.itens : this.getQuadrasFallback();

        this.usuarioService.listar(1, 100).subscribe({
          next: (resUsuarios) => {
            this.usuarios = (resUsuarios?.dados?.itens && resUsuarios.dados.itens.length > 0) ? resUsuarios.dados.itens : this.getUsuariosFallback();
            this.processarAvaliacoes();
            this.isLoading = false;
          },
          error: () => {
            this.usuarios = this.getUsuariosFallback();
            this.processarAvaliacoes();
            this.isLoading = false;
          }
        });
      },
      error: () => {
        this.quadras = this.getQuadrasFallback();
        this.usuarios = this.getUsuariosFallback();
        this.processarAvaliacoes();
        this.isLoading = false;
      }
    });
  }

  processarAvaliacoes(): void {
    const modalidadesSet = new Set<string>();
    modalidadesSet.add('Todas');

    const listaComentariosBase = [
      'Quadra excelente! Iluminação impecável e ótima estrutura.',
      'Muito boa a vestimenta e a grama sintética em ótimas condições.',
      'Gostei bastante, limpo e organizado. Voltarei mais vezes.',
      'Excelente atendimento e agilidade no check-in!',
      'Grama em boa conservação, espaço amplo e ventilado.',
      'Ótima quadra, horário respeitado rigorosamente.',
      'Estrutura top de linha! Vale muito a pena para jogar com a turma.',
      'Rede e marcação em ótimas condições. Recomendadíssimo.'
    ];

    const notasPredefinidas: Record<string, { media: number; total: number }> = {
      '1': { media: 4.7, total: 128 },
      '2': { media: 4.5, total: 96 },
      '3': { media: 4.6, total: 74 },
      '4': { media: 4.4, total: 58 },
      '5': { media: 4.3, total: 52 },
      '6': { media: 4.2, total: 41 },
      '7': { media: 4.6, total: 37 },
      '8': { media: 4.1, total: 29 }
    };

    this.quadrasResumo = this.quadras.map((q, idx) => {
      if (q.modalidade) modalidadesSet.add(q.modalidade);

      const pref = notasPredefinidas[q.id] || {
        media: Number((4.0 + (idx % 8) * 0.1).toFixed(1)),
        total: 15 + (idx * 7)
      };

      // Gerar algumas avaliações individuais fictícias associando aos usuários reais
      const avaliacoesQuadra: AvaliacaoItem[] = [];
      const numAvaliacoesExemplo = Math.min(5, this.usuarios.length > 0 ? this.usuarios.length : 3);

      for (let i = 0; i < numAvaliacoesExemplo; i++) {
        const u = this.usuarios[i % this.usuarios.length] || { nomeCompleto: 'Usuário ' + (i + 1), email: 'usuario@email.com' };
        avaliacoesQuadra.push({
          id: `av-${q.id}-${i}`,
          quadraId: q.id,
          quadraNome: q.nome,
          quadraModalidade: q.modalidade,
          quadraImagem: q.imagemUrl,
          usuarioNome: u.nomeCompleto,
          usuarioEmail: u.email,
          nota: 4 + (i % 2),
          comentario: listaComentariosBase[i % listaComentariosBase.length],
          data: `${10 - i}/08/2026`
        });
      }

      return {
        id: q.id,
        nome: q.nome,
        modalidade: q.modalidade || 'Geral',
        imagemUrl: q.imagemUrl || 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=600',
        mediaNota: pref.media,
        totalAvaliacoes: pref.total,
        avaliacoes: avaliacoesQuadra
      };
    });

    this.opcoesModalidades = Array.from(modalidadesSet);
    this.aplicarFiltros();
  }

  aplicarFiltros(): void {
    this.quadrasFiltradas = this.quadrasResumo.filter((q) => {
      const matchBusca =
        !this.termoBusca ||
        q.nome.toLowerCase().includes(this.termoBusca.toLowerCase()) ||
        q.modalidade.toLowerCase().includes(this.termoBusca.toLowerCase());

      const matchModalidade =
        this.filtroModalidade === 'Todas' || q.modalidade === this.filtroModalidade;

      return matchBusca && matchModalidade;
    });
  }

  abrirDetalhes(quadra: QuadraAvaliacaoResumo): void {
    this.quadraSelecionada = quadra;
    this.exibirModalDetalhes = true;
  }

  fecharModal(): void {
    this.exibirModalDetalhes = false;
    this.quadraSelecionada = null;
  }

  getIconeModalidade(modalidade: string): string {
    const mod = (modalidade || '').toLowerCase();
    if (mod.includes('society') || mod.includes('futebol')) return 'soccer';
    if (mod.includes('futsal')) return 'sports_soccer';
    if (mod.includes('beach') || mod.includes('tennis')) return 'sports_tennis';
    if (mod.includes('vôlei') || mod.includes('volei')) return 'sports_volleyball';
    if (mod.includes('basquete')) return 'sports_basketball';
    return 'sports';
  }

  private getQuadrasFallback(): ReservaQuadraDto[] {
    return [
      { id: '1', nome: 'Quadra Society do Parque', descricao: '', localizacao: 'Parque Central', capacidade: 14, modalidade: 'Futebol Society', imagemUrl: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=600&auto=format&fit=crop&q=60', status: 'Ativa' },
      { id: '2', nome: 'Quadra Coberta Bela Vista', descricao: '', localizacao: 'Bela Vista', capacidade: 10, modalidade: 'Futsal', imagemUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=600&auto=format&fit=crop&q=60', status: 'Ativa' },
      { id: '3', nome: 'Arena Beach Tennis', descricao: '', localizacao: 'Clube Principal', capacidade: 4, modalidade: 'Beach Tennis', imagemUrl: 'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=600&auto=format&fit=crop&q=60', status: 'Ativa' },
      { id: '4', nome: 'Quadra de Vôlei Central', descricao: '', localizacao: 'Centro Esportivo', capacidade: 12, modalidade: 'Vôlei', imagemUrl: 'https://images.unsplash.com/photo-1592656094267-764a45160876?w=600&auto=format&fit=crop&q=60', status: 'Ativa' },
      { id: '5', nome: 'Quadra de Basquete', descricao: '', localizacao: 'Ginásio B', capacidade: 10, modalidade: 'Basquete', imagemUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=600&auto=format&fit=crop&q=60', status: 'Ativa' },
      { id: '6', nome: 'Quadra de Vôlei de Areia', descricao: '', localizacao: 'Área Externa', capacidade: 12, modalidade: 'Vôlei de Areia', imagemUrl: 'https://images.unsplash.com/photo-1592656094267-764a45160876?w=600&auto=format&fit=crop&q=60', status: 'Ativa' },
      { id: '7', nome: 'Campo de Society Noturno', descricao: '', localizacao: 'Setor Sul', capacidade: 14, modalidade: 'Futebol Society', imagemUrl: 'https://images.unsplash.com/photo-1518604666860-9ed391f76460?w=600&auto=format&fit=crop&q=60', status: 'Ativa' },
      { id: '8', nome: 'Quadra de Beach Tennis 2', descricao: '', localizacao: 'Anexo Praia', capacidade: 4, modalidade: 'Beach Tennis', imagemUrl: 'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=600&auto=format&fit=crop&q=60', status: 'Ativa' }
    ];
  }

  private getUsuariosFallback(): UsuarioDto[] {
    return [
      { usuariosId: '1', nomeCompleto: 'Gabriel Costa', email: 'gabriel@email.com', cpf: '', telefone: '', nomePerfil: 'Cliente', ativo: true },
      { usuariosId: '2', nomeCompleto: 'Mariana Lima', email: 'mariana@email.com', cpf: '', telefone: '', nomePerfil: 'Cliente', ativo: true },
      { usuariosId: '3', nomeCompleto: 'Lucas Andrade', email: 'lucas@email.com', cpf: '', telefone: '', nomePerfil: 'Cliente', ativo: true },
      { usuariosId: '4', nomeCompleto: 'Beatriz Santos', email: 'beatriz@email.com', cpf: '', telefone: '', nomePerfil: 'Cliente', ativo: true },
      { usuariosId: '5', nomeCompleto: 'Rafael Oliveira', email: 'rafael@email.com', cpf: '', telefone: '', nomePerfil: 'Cliente', ativo: true }
    ];
  }

  getBadgeClass(modalidade: string): string {
    const mod = (modalidade || '').toLowerCase();
    if (mod.includes('society') || mod.includes('futebol')) return 'badge-futebol-society';
    if (mod.includes('futsal')) return 'badge-futsal';
    if (mod.includes('beach') || mod.includes('tennis')) return 'badge-beach-tennis';
    if (mod.includes('vôlei') || mod.includes('volei')) return 'badge-volei';
    if (mod.includes('basquete')) return 'badge-basquete';
    return 'badge-futsal';
  }
}
