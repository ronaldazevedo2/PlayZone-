import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { QuadraService, ReservaQuadraDto, CriarQuadraCommand } from '../../services/quadra.service';

interface QuadraExibicao extends ReservaQuadraDto {
  status: 'Ativa' | 'Manutenção' | 'Inativa';
  diasDisponiveis: string[];
  horariosDisponiveis: string;
  totalHorarios: number;
}

@Component({
  selector: 'app-quadras',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './quadras.component.html',
  styleUrl: './quadras.component.css'
})
export class QuadrasComponent implements OnInit {
  quadras: QuadraExibicao[] = [];
  quadrasFiltradas: QuadraExibicao[] = [];

  // Controle de Visualização
  exibirFormularioCadastro = false;
  quadraEditandoId: string | null = null;

  // Filtros e busca da listagem
  buscaTexto = '';
  termoBusca = '';
  filtroStatus: 'Todas' | 'Ativas' | 'Manutenção' | 'Inativas' = 'Todas';
  abaAtiva: 'Todas' | 'Ativas' | 'Manutenção' | 'Inativas' = 'Todas';
  ordenacao: 'nome-asc' | 'nome-desc' | 'capacidade-asc' | 'capacidade-desc' = 'nome-asc';

  // Paginação
  paginaAtual = 1;
  tamanhoPagina = 10;
  totalItens = 0;
  totalPaginas = 1;

  // Estatísticas
  totalQuadrasCount = 0;
  ativasCount = 0;
  manutencaoCount = 0;
  horariosCount = 0;

  carregando = false;
  salvando = false;
  erro = '';
  sucessoMsg = '';
  menuAbertoId: string | null = null;

  // Toast notification
  toastMensagem = '';
  toastTitulo = '';
  toastTipo: 'erro' | 'aviso' | 'sucesso' = 'erro';
  private toastTimer: any = null;

  // Estado do Formulário de Cadastro
  novaQuadra: CriarQuadraCommand = {
    nome: '',
    descricao: '',
    capacidade: 12,
    localizacao: '',
    modalidade: 'Futebol Society',
    imagemUrl: '',
    status: 'Ativa'
  };

  // Opções de Modalidades (Tipo)
  opcoesModalidades = [
    'Futebol Society',
    'Beach Tennis',
    'Futsal',
    'Vôlei de Areia'
  ];

  // Dias da semana para abas/toggles
  diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  // Dia selecionado atualmente no formulário de horários
  diaFormAtivo = 'Seg';

  // Grade de Horários Pré-definidos para Seleção Rápida
  slotsHorariosDisponiveis = [
    '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00',
    '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00'
  ];

  // Estrutura que guarda os horários selecionados para cada dia
  horariosPorDia: { [dia: string]: string[] } = {};

  constructor(private quadraService: QuadraService) { }

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

    this.quadraService.listar(this.paginaAtual, this.tamanhoPagina, this.buscaTexto).subscribe({
      next: (res) => {
        const itens = res.dados?.itens ?? [];
        this.totalItens = res.dados?.total ?? 0;
        this.totalPaginas = res.dados?.totalPaginas ?? 0;

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

        this.aplicarFiltrosLocais();
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

  aplicarFiltrosLocais(): void {
    let resultado = [...this.quadras];
    if (this.abaAtiva === 'Ativas') {
      resultado = resultado.filter(q => q.status === 'Ativa');
    } else if (this.abaAtiva === 'Manutenção') {
      resultado = resultado.filter(q => q.status === 'Manutenção');
    } else if (this.abaAtiva === 'Inativas') {
      resultado = resultado.filter(q => q.status === 'Inativa');
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

    this.quadrasFiltradas = resultado;
  }

  aplicarFiltrosBusca(): void {
    let resultado = [...this.quadras];

    // Filtro por status (dropdown)
    if (this.filtroStatus === 'Ativas') {
      resultado = resultado.filter(q => q.status === 'Ativa');
    } else if (this.filtroStatus === 'Manutenção') {
      resultado = resultado.filter(q => q.status === 'Manutenção');
    } else if (this.filtroStatus === 'Inativas') {
      resultado = resultado.filter(q => q.status === 'Inativa');
    }

    // Filtro por texto
    if (this.termoBusca.trim()) {
      const termo = this.termoBusca.toLowerCase();
      resultado = resultado.filter(q =>
        q.nome?.toLowerCase().includes(termo) ||
        q.localizacao?.toLowerCase().includes(termo) ||
        q.modalidade?.toLowerCase().includes(termo)
      );
    }

    this.quadrasFiltradas = resultado;
  }

  atualizarEstatisticas(): void {
    this.totalQuadrasCount = this.totalItens;
    this.ativasCount = Math.max(0, this.quadras.filter(q => q.status === 'Ativa').length);
    this.manutencaoCount = Math.max(0, this.quadras.filter(q => q.status === 'Manutenção').length);

    if (this.totalItens > this.quadras.length) {
      const proporcao = this.totalItens / this.quadras.length;
      this.ativasCount = Math.round(this.ativasCount * proporcao);
      this.manutencaoCount = Math.round(this.manutencaoCount * proporcao);
    }

    this.horariosCount = this.quadras.reduce((sum, q) => sum + q.totalHorarios, 0);
    if (this.totalItens > this.quadras.length) {
      this.horariosCount = Math.round(this.horariosCount * (this.totalItens / this.quadras.length));
    } else if (this.horariosCount === 0) {
      this.horariosCount = 156;
    }
  }

  selecionarAba(aba: 'Todas' | 'Ativas' | 'Manutenção' | 'Inativas'): void {
    this.abaAtiva = aba;
    this.paginaAtual = 1;
    this.carregarQuadras();
  }

  buscar(): void {
    this.paginaAtual = 1;
    this.carregarQuadras();
  }

  mudarOrdenacao(event: Event): void {
    const value = (event.target as HTMLSelectElement).value as any;
    this.ordenacao = value;
    this.aplicarFiltrosLocais();
  }

  mudarPagina(pagina: number): void {
    if (pagina >= 1 && pagina <= this.totalPaginas) {
      this.paginaAtual = pagina;
      this.carregarQuadras();
    }
  }

  getObjetoPaginas(): number[] {
    const paginas = [];
    for (let i = 1; i <= this.totalPaginas; i++) {
      paginas.push(i);
    }
    return paginas;
  }

  // Ações de cadastro
  adicionarQuadra(): void {
    this.exibirFormularioCadastro = true;
    this.quadraEditandoId = null;
    this.erro = '';
    this.sucessoMsg = '';
    this.novaQuadra = {
      nome: '',
      descricao: '',
      capacidade: 12,
      localizacao: '',
      modalidade: 'Futebol Society',
      imagemUrl: '',
      status: 'Ativa'
    };

    // Inicializa os horários padrão por dia conforme a planilha
    this.diaFormAtivo = 'Seg';
    this.horariosPorDia = {
      'Seg': ['18:00', '19:00', '20:00', '21:00'],
      'Ter': ['18:00', '19:00', '20:00', '21:00'],
      'Qua': ['18:00', '19:00', '20:00', '21:00'],
      'Qui': ['18:00', '19:00', '20:00', '21:00'],
      'Sex': ['18:00', '19:00', '20:00', '21:00'],
      'Sáb': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00'],
      'Dom': ['08:00', '09:00', '13:00', '14:00', '15:00', '16:00', '17:00']
    };
  }

  cancelarCadastro(): void {
    this.exibirFormularioCadastro = false;
    this.quadraEditandoId = null;
    this.erro = '';
  }

  // Lógica da grade de horários
  mudarDiaForm(dia: string): void {
    this.diaFormAtivo = dia;
  }

  alternarHorario(dia: string, slot: string): void {
    if (!this.horariosPorDia[dia]) {
      this.horariosPorDia[dia] = [];
    }

    const index = this.horariosPorDia[dia].indexOf(slot);
    if (index > -1) {
      this.horariosPorDia[dia].splice(index, 1); // remove se já existia
    } else {
      this.horariosPorDia[dia].push(slot); // adiciona se não existia
      // Mantém a ordenação dos horários
      this.horariosPorDia[dia].sort((a, b) => a.localeCompare(b));
    }
  }

  selecionarTodosHorarios(dia: string): void {
    this.horariosPorDia[dia] = [...this.slotsHorariosDisponiveis];
  }

  limparTodosHorarios(dia: string): void {
    this.horariosPorDia[dia] = [];
  }

  copiarParaTodosDias(diaOrigem: string): void {
    const listOrigem = [...(this.horariosPorDia[diaOrigem] ?? [])];
    this.diasSemana.forEach(dia => {
      if (dia !== diaOrigem) {
        this.horariosPorDia[dia] = [...listOrigem];
      }
    });
    alert(`Configuração do dia ${diaOrigem} replicada para todos os outros dias!`);
  }

  salvarQuadra(): void {
    if (this.novaQuadra.nome) {
      this.novaQuadra.nome = this.novaQuadra.nome.toUpperCase();
    }

    if (!this.novaQuadra.nome || !this.novaQuadra.localizacao || !this.novaQuadra.capacidade) {
      this.erro = 'Por favor, preencha todos os campos obrigatórios (*).';
      return;
    }

    if (!this.novaQuadra.imagemUrl) {
      if (this.novaQuadra.modalidade.includes('Beach')) {
        this.novaQuadra.imagemUrl = 'https://images.unsplash.com/photo-1593787406536-3676a152d9cb?q=80&w=300';
      } else if (this.novaQuadra.modalidade.includes('Futsal')) {
        this.novaQuadra.imagemUrl = 'https://images.unsplash.com/photo-1518063319789-7217e6706b04?q=80&w=300';
      } else if (this.novaQuadra.modalidade.includes('Vôlei')) {
        this.novaQuadra.imagemUrl = 'https://images.unsplash.com/photo-1547941126-3d5322b218b6?q=80&w=300';
      } else {
        this.novaQuadra.imagemUrl = 'https://images.unsplash.com/photo-1545807191-178a3752c51e?q=80&w=300';
      }
    }

    if (!this.novaQuadra.descricao) {
      this.novaQuadra.descricao = `Quadra de ${this.novaQuadra.modalidade} para ${this.novaQuadra.capacidade} jogadores.`;
    }

    this.salvando = true;
    this.erro = '';

    // Garantir tipos corretos
    const commandToSave = {
      ...this.novaQuadra,
      capacidade: Number(this.novaQuadra.capacidade)
    } as any;

    if (this.quadraEditandoId) {
      this.quadraService.atualizar(this.quadraEditandoId, commandToSave).subscribe({
        next: () => {
          this.salvando = false;
          this.exibirFormularioCadastro = false;
          this.quadraEditandoId = null;
          this.carregarQuadras();
        },
        error: (err) => {
          this.tratarErroSalvar(err);
        }
      });
    } else {
      this.quadraService.criar(commandToSave).subscribe({
        next: (res) => {
          this.salvando = false;
          this.exibirFormularioCadastro = false;
          this.quadraEditandoId = null;
          this.carregarQuadras();
        },
        error: (err) => {
          this.tratarErroSalvar(err);
        }
      });
    }
  }

  private tratarErroSalvar(err: any): void {
    console.error('Erro ao salvar quadra:', err);
    let mensagemErro = 'Ocorreu um erro ao salvar a quadra na API.';
    if (err.error) {
      if (err.error.erros && err.error.erros.length > 0) {
        mensagemErro = err.error.erros.join(', ');
      } else if (err.error.mensagem) {
        mensagemErro = err.error.mensagem;
      } else if (err.error.errors) {
        const msgs = Object.values(err.error.errors).flat();
        mensagemErro = msgs.join(', ');
      } else if (typeof err.error === 'string') {
        mensagemErro = err.error;
      }
    }
    this.erro = mensagemErro;
    this.salvando = false;
  }

  editarQuadra(quadra: QuadraExibicao): void {
    this.exibirFormularioCadastro = true;
    this.quadraEditandoId = quadra.id;
    this.erro = '';
    this.sucessoMsg = '';

    this.novaQuadra = {
      nome: quadra.nome || '',
      descricao: quadra.descricao || '',
      capacidade: quadra.capacidade || 12,
      localizacao: quadra.localizacao || '',
      modalidade: quadra.modalidade || 'Futebol Society',
      imagemUrl: quadra.imagemUrl || '',
      status: quadra.status || 'Ativa'
    };

    this.diaFormAtivo = 'Seg';
    this.horariosPorDia = {
      'Seg': ['18:00', '19:00', '20:00', '21:00'],
      'Ter': ['18:00', '19:00', '20:00', '21:00'],
      'Qua': ['18:00', '19:00', '20:00', '21:00'],
      'Qui': ['18:00', '19:00', '20:00', '21:00'],
      'Sex': ['18:00', '19:00', '20:00', '21:00'],
      'Sáb': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00'],
      'Dom': ['08:00', '09:00', '13:00', '14:00', '15:00', '16:00', '17:00']
    };
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
      next: (res) => {
        if (res && res.ok === false) {
          // API returned 200 but with ok: false (business rule error)
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
      error: (err) => {
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
    // Reservation-linked patterns (portuguese + english from .NET EF/SQL)
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
    // Fallback: show original but cleaned up
    return original || 'Ocorreu um erro ao tentar excluir a quadra. Tente novamente.';
  }

  onFileSelected(event: any): void {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e: any) => {
        this.novaQuadra.imagemUrl = e.target.result;
      };
      reader.readAsDataURL(file);
    }
  }
}
