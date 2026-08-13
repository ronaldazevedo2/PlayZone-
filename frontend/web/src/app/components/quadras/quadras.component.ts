import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { QuadraService, ReservaQuadraDto } from '../../services/quadra.service';

interface QuadraExibicao extends ReservaQuadraDto {
  status: 'Ativa' | 'Manutenção' | 'Inativa';
  diasDisponiveis: string[];
  horariosDisponiveis: string;
  totalHorarios: number;
}

@Component({
  selector: 'app-quadras',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './quadras.component.html',
  styleUrl: './quadras.component.css'
})
export class QuadrasComponent implements OnInit {
  quadras: QuadraExibicao[] = [];
  quadrasFiltradas: QuadraExibicao[] = [];

  // Filtros e busca da listagem
  buscaTexto = '';
  termoBusca = '';
  filtroStatus: 'Todas' | 'Ativas' | 'Agendadas' | 'Manutenção' | 'Inativas' = 'Todas';
  abaAtiva: 'Todas' | 'Ativas' | 'Agendadas' | 'Manutenção' | 'Inativas' = 'Todas';
  ordenacao: 'nome-asc' | 'nome-desc' | 'capacidade-asc' | 'capacidade-desc' = 'nome-asc';

  // Paginação
  paginaAtual = 1;
  tamanhoPagina = 10;
  totalItens = 0;
  totalPaginas = 1;

  // Estatísticas
  totalQuadrasCount = 0;
  ativasCount = 0;
  agendadasCount = 0;
  manutencaoCount = 0;
  horariosCount = 0;

  carregando = false;
  erro = '';
  menuAbertoId: string | null = null;

  // Toast notification
  toastMensagem = '';
  toastTitulo = '';
  toastTipo: 'erro' | 'aviso' | 'sucesso' = 'erro';
  private toastTimer: any = null;

  defaultQuadraImage = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="300" height="200" viewBox="0 0 300 200"><rect width="300" height="200" fill="%231e2248"/><rect x="20" y="20" width="260" height="160" fill="none" stroke="%233b82f6" stroke-width="3" rx="8"/><line x1="150" y1="20" x2="150" y2="180" stroke="%233b82f6" stroke-width="3"/><circle cx="150" cy="100" r="35" fill="none" stroke="%233b82f6" stroke-width="3"/><text x="150" y="105" fill="%23ffffff" font-family="sans-serif" font-size="14" font-weight="bold" text-anchor="middle">PLAYZONE</text></svg>`;

  onImageError(event: Event): void {
    const img = event.target as HTMLImageElement;
    if (img) {
      img.onerror = null;
      img.src = this.defaultQuadraImage;
    }
  }

  constructor(
    private quadraService: QuadraService,
    private router: Router
  ) { }

  ngOnInit(): void {
    this.carregarQuadras();
  }

  mostrarToast(titulo: string, mensagem: string, tipo: 'erro' | 'aviso' | 'sucesso' = 'erro', duracaoMs = 6000): void {
    if (this.toastTimer) clearTimeout(this.toastTimer);
    this.toastTitulo = titulo;
    this.toastMensagem = mensagem;
    this.toastTipo = tipo;
    this.toastTimer = setTimeout(() => this.fecharToast(), duracaoMs);
  }

  fecharToast(): void {
    this.toastMensagem = '';
    this.toastTitulo = '';
    if (this.toastTimer) { clearTimeout(this.toastTimer); this.toastTimer = null; }
  }

  carregarQuadras(): void {
    this.carregando = true;
    this.erro = '';

    // Busca todas as quadras (até 1000) de uma só vez para permitir busca global entre páginas
    this.quadraService.listar(1, 1000, '').subscribe({
      next: (res) => {
        const itens = res.dados?.itens ?? [];

        this.quadras = itens.map(q => {
          const status = (q as any).status || 'Ativa';
          const nomeStr = q.nome?.toLowerCase() || '';

          const diasDisponiveis = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

          let horariosDisponiveis = '06:00 - 23:00';
          let totalHorarios = 17;
          if (nomeStr.includes('beach') || nomeStr.includes('vôlei')) {
            horariosDisponiveis = '07:00 - 22:00';
            totalHorarios = 15;
          }

          return {
            ...q,
            status,
            diasDisponiveis,
            horariosDisponiveis,
            totalHorarios
          };
        });

        this.aplicarFiltrosBusca();
        this.atualizarEstatisticas();
        this.carregando = false;
      },
      error: (err) => {
        console.error(err);
        this.erro = 'Erro ao carregar as quadras da API.';
        this.carregando = false;
      }
    });
  }

  isAgendada(q: ReservaQuadraDto): boolean {
    if (!q || !q.dataLiberacao) return false;
    const hojeStr = new Date().toISOString().split('T')[0];
    const dataLibStr = q.dataLiberacao.split('T')[0];
    return dataLibStr > hojeStr;
  }

  aplicarFiltrosLocais(): void {
    this.aplicarFiltrosBusca();
  }

  aplicarFiltrosBusca(): void {
    let resultado = [...this.quadras];

    const statusFiltro = this.filtroStatus !== 'Todas' ? this.filtroStatus : this.abaAtiva;

    if (statusFiltro === 'Ativas') {
      resultado = resultado.filter(q => q.status === 'Ativa' && !this.isAgendada(q));
    } else if (statusFiltro === 'Agendadas') {
      resultado = resultado.filter(q => this.isAgendada(q));
    } else if (statusFiltro === 'Manutenção') {
      resultado = resultado.filter(q => q.status === 'Manutenção');
    } else if (statusFiltro === 'Inativas') {
      resultado = resultado.filter(q => q.status === 'Inativa');
    }

    const termo = (this.termoBusca || this.buscaTexto).toLowerCase().trim();
    if (termo) {
      resultado = resultado.filter(q =>
        q.nome?.toLowerCase().includes(termo) ||
        q.localizacao?.toLowerCase().includes(termo) ||
        q.modalidade?.toLowerCase().includes(termo)
      );
    }

    if (this.ordenacao === 'nome-asc') {
      resultado.sort((a, b) => a.nome.localeCompare(b.nome));
    } else if (this.ordenacao === 'nome-desc') {
      resultado.sort((a, b) => b.nome.localeCompare(a.nome));
    } else if (this.ordenacao === 'capacidade-asc') {
      resultado.sort((a, b) => a.capacidade - b.capacidade);
    } else if (this.ordenacao === 'capacidade-desc') {
      resultado.sort((a, b) => b.capacidade - a.capacidade);
    }

    this.totalItens = resultado.length;
    this.totalPaginas = Math.ceil(this.totalItens / this.tamanhoPagina) || 1;

    if (this.paginaAtual > this.totalPaginas) {
      this.paginaAtual = 1;
    }

    const inicio = (this.paginaAtual - 1) * this.tamanhoPagina;
    this.quadrasFiltradas = resultado.slice(inicio, inicio + this.tamanhoPagina);
  }

  atualizarEstatisticas(): void {
    this.totalQuadrasCount = this.quadras.length;
    this.ativasCount = Math.max(0, this.quadras.filter(q => q.status === 'Ativa' && !this.isAgendada(q)).length);
    this.agendadasCount = Math.max(0, this.quadras.filter(q => this.isAgendada(q)).length);
    this.manutencaoCount = Math.max(0, this.quadras.filter(q => q.status === 'Manutenção').length);

    this.horariosCount = this.quadras.reduce((sum, q) => sum + q.totalHorarios, 0);
    if (this.horariosCount === 0) {
      this.horariosCount = 156;
    }
  }

  selecionarAba(aba: 'Todas' | 'Ativas' | 'Agendadas' | 'Manutenção' | 'Inativas'): void {
    this.abaAtiva = aba;
    this.filtroStatus = aba;
    this.paginaAtual = 1;
    this.aplicarFiltrosBusca();
  }

  buscar(): void {
    this.paginaAtual = 1;
    this.aplicarFiltrosBusca();
  }

  mudarOrdenacao(event: Event): void {
    const value = (event.target as HTMLSelectElement).value as any;
    this.ordenacao = value;
    this.aplicarFiltrosBusca();
  }

  mudarPagina(pagina: number): void {
    if (pagina >= 1 && pagina <= this.totalPaginas) {
      this.paginaAtual = pagina;
      this.aplicarFiltrosBusca();
    }
  }

  getObjetoPaginas(): number[] {
    const paginas = [];
    for (let i = 1; i <= this.totalPaginas; i++) {
      paginas.push(i);
    }
    return paginas;
  }

  // --- Navegação via Roteador ---
  adicionarQuadra(): void {
    this.router.navigate(['/quadras/nova']);
  }

  editarQuadra(quadra: QuadraExibicao): void {
    this.router.navigate(['/quadras/editar', quadra.id]);
  }

  verReservasQuadra(quadra: QuadraExibicao): void {
    this.router.navigate(['/reservas'], { queryParams: { quadraId: quadra.id } });
  }

  abrirOpcoes(quadra: QuadraExibicao, event: MouseEvent): void {
    event.stopPropagation();
    this.menuAbertoId = this.menuAbertoId === quadra.id ? null : quadra.id;
  }

  fecharMenus(): void {
    this.menuAbertoId = null;
  }

  excluirQuadra(quadra: QuadraExibicao): void {
    this.menuAbertoId = null;
    if (!confirm(`Tem certeza que deseja excluir a quadra "${quadra.nome}"?`)) return;

    this.carregando = true;
    this.quadraService.excluir(quadra.id).subscribe({
      next: (res: any) => {
        if (res && res.ok === false) {
          const rawMsg = (res.erros?.join(' ') || res.mensagem || '').toLowerCase();
          const msgFriendly = this.traduzirErroExclusao(rawMsg, res.erros?.join(', ') || res.mensagem);
          this.mostrarToast('Não foi possível excluir', msgFriendly, 'aviso');
        } else {
          this.quadras = this.quadras.filter(q => q.id !== quadra.id);
          this.quadrasFiltradas = this.quadrasFiltradas.filter(q => q.id !== quadra.id);
          this.totalItens = Math.max(0, this.totalItens - 1);
          this.mostrarToast('Quadra excluída', `A quadra "${quadra.nome}" foi removida com sucesso.`, 'sucesso', 4000);
          this.carregarQuadras();
        }
        this.carregando = false;
      },
      error: (err: any) => {
        this.carregando = false;
        const rawMsg = (
          err.error?.erros?.join(' ') ||
          err.error?.mensagem ||
          err.error?.title ||
          (typeof err.error === 'string' ? err.error : '') ||
          ''
        ).toLowerCase();
        const msgFriendly = this.traduzirErroExclusao(rawMsg,
          err.error?.erros?.join(', ') || err.error?.mensagem || err.error?.title || err.message || '');
        const titulo = err.status === 403 ? 'Acesso negado' : 'Não foi possível excluir';
        this.mostrarToast(titulo, msgFriendly, 'aviso');
      }
    });
  }

  private traduzirErroExclusao(rawLower: string, original: string): string {
    const reservaPatterns = ['reserva', 'agendamento', 'booking', 'foreign key', 'constraint', 'fk_', 'reference', 'related', 'vinculad', 'depend'];
    if (reservaPatterns.some(p => rawLower.includes(p))) {
      return 'Esta quadra possui reservas vinculadas e não pode ser excluída. Cancele ou conclua todas as reservas associadas antes de removê-la.';
    }
    if (rawLower.includes('not found') || rawLower.includes('não encontrad') || rawLower.includes('404')) {
      return 'Quadra não encontrada. Ela pode já ter sido excluída.';
    }
    if (rawLower.includes('unauthorized') || rawLower.includes('forbidden') || rawLower.includes('permiss')) {
      return 'Você não tem permissão para excluir esta quadra.';
    }
    return original || 'Ocorreu um erro ao tentar excluir a quadra. Tente novamente.';
  }
}
