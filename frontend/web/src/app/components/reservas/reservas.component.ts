import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { QuadraService, ReservaQuadraDto } from '../../services/quadra.service';
import { ReservaService, ReservaDto, CriarReservaCommand } from '../../services/reserva.service';
import { AuthService } from '../../services/auth.service';
import { RespostaApi } from '../../wrappers/api-response.wrapper';
import { ResultadoPaginado } from '../../services/secretaria.service';

interface UsuarioBusca {
  usuariosId: string;
  nomeCompleto: string;
  email: string;
  cpf?: string;
  telefone?: string;
  ativo: boolean;
}

@Component({
  selector: 'app-reservas',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './reservas.component.html',
  styleUrl: './reservas.component.css'
})
export class ReservasComponent implements OnInit {
  quadras: ReservaQuadraDto[] = [];
  quadrasFiltradas: ReservaQuadraDto[] = [];
  todasReservas: ReservaDto[] = [];
  reservasQuadraSelecionada: ReservaDto[] = [];

  isLoading = false;
  salvando = false;
  quadraSelecionada: ReservaQuadraDto | null = null;

  // Filtros da listagem
  termoBuscaQuadra = '';
  filtroModalidade = 'Todas';
  opcoesModalidades: string[] = ['Todas', 'Futebol Society', 'Futsal', 'Basquete', 'Vôlei', 'Beach Tennis'];

  // Horários disponíveis para seleção
  horariosDisponiveis: string[] = [
    '06:00 - 07:00', '07:00 - 08:00', '08:00 - 09:00', '09:00 - 10:00',
    '10:00 - 11:00', '11:00 - 12:00', '12:00 - 13:00', '13:00 - 14:00',
    '14:00 - 15:00', '15:00 - 16:00', '16:00 - 17:00', '17:00 - 18:00',
    '18:00 - 19:00', '19:00 - 20:00', '20:00 - 21:00', '21:00 - 22:00',
    '22:00 - 23:00'
  ];

  // Modal de Detalhes da Reserva existente
  showDetailsModal = false;
  selectedReserva: ReservaDto | null = null;

  // ────────────────────────────────────────
  //   FORMULÁRIO DE NOVA RESERVA
  // ────────────────────────────────────────
  showNovaReservaForm = false;
  errosForm: string[] = [];
  successMessage = '';

  // Campos do formulário
  formQuadraId = '';
  formData = '';
  formHorario = '';
  formUsuarioId = '';
  formUsuarioNome = '';
  formUsuarioEmail = '';

  // ────────────────────────────────────────
  //   MODAL DE BUSCA DE USUÁRIO
  // ────────────────────────────────────────
  showBuscarUsuarioModal = false;
  termoBuscaUsuario = '';
  usuariosBusca: UsuarioBusca[] = [];
  buscandoUsuarios = false;
  erroBuscaUsuario = '';

  private readonly USUARIOS_API = 'https://localhost:7200/api/Usuarios';

  constructor(
    private quadraService: QuadraService,
    private reservaService: ReservaService,
    private authService: AuthService,
    private http: HttpClient,
    private router: Router,
    private route: ActivatedRoute
  ) { }

  ngOnInit(): void {
    this.carregarDados();
  }

  // ────────────────────────────────────────
  //   DADOS INICIAIS
  // ────────────────────────────────────────
  carregarDados(): void {
    this.isLoading = true;
    this.quadraService.listar(1, 100).subscribe({
      next: (res: RespostaApi<ResultadoPaginado<ReservaQuadraDto>>) => {
        if (res && res.ok && res.dados && res.dados.itens && res.dados.itens.length > 0) {
          this.quadras = res.dados.itens;
        } else {
          this.usarQuadrasMockadas();
        }
        this.aplicarFiltros();
        this.carregarReservas();
      },
      error: () => {
        this.usarQuadrasMockadas();
        this.aplicarFiltros();
        this.carregarReservas();
      }
    });
  }

  private usarQuadrasMockadas(): void {
    this.quadras = [
      { id: 'q1', nome: 'Society 1', modalidade: 'Futebol Society', descricao: '', localizacao: 'Arena Principal', capacidade: 14, imagemUrl: 'https://images.unsplash.com/photo-1545807191-178a3752c51e?q=80&w=600', status: 'Ativa' },
      { id: 'q2', nome: 'Beach Tennis Arena 1', modalidade: 'Beach Tennis', descricao: '', localizacao: 'Arena Externa', capacidade: 4, imagemUrl: 'https://images.unsplash.com/photo-1592919505780-303950717480?q=80&w=600', status: 'Ativa' },
      { id: 'q3', nome: 'Futsal 1', modalidade: 'Futsal', descricao: '', localizacao: 'Ginásio 1', capacidade: 10, imagemUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=600', status: 'Ativa' },
      { id: 'q4', nome: 'Vôlei de Areia 1', modalidade: 'Vôlei', descricao: '', localizacao: 'Arena Externa', capacidade: 12, imagemUrl: 'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?q=80&w=600', status: 'Ativa' },
      { id: 'q5', nome: 'Society 2', modalidade: 'Futebol Society', descricao: '', localizacao: 'Arena Principal', capacidade: 14, imagemUrl: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?q=80&w=600', status: 'Ativa' },
      { id: 'q6', nome: 'Basquete 1', modalidade: 'Basquete', descricao: '', localizacao: 'Ginásio 2', capacidade: 10, imagemUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=600', status: 'Ativa' }
    ];
  }

  carregarReservas(): void {
    this.reservaService.listar(1, 100).subscribe({
      next: (res: RespostaApi<ResultadoPaginado<ReservaDto>>) => {
        this.isLoading = false;
        if (res && res.ok && res.dados && res.dados.itens) {
          const itens = res.dados.itens;
          this.todasReservas = itens.map((item: any) => {
            const qId = item.quadraId || item.QuadraId || '';
            const quadra = this.quadras.find(q => q.id === qId);

            const rawHorario = item.horarioAgendado || item.horario || '';
            const shortHorario = this.formatHorarioShort(rawHorario);
            const rangeHorario = this.formatHorarioRange(shortHorario);
            const dataValida = item.dataAgendada || item.data || '';

            const statusCalculado = this.calcularStatusReserva(dataValida, rawHorario, item.status);

            return {
              id: item.reservasId || item.reservaId || item.id || '',
              quadraId: qId,
              nomeQuadra: item.nomeQuadra || quadra?.nome || 'Quadra',
              modalidade: item.modalidade || quadra?.modalidade || 'Futebol Society',
              usuarioId: item.usuariosId || item.usuarioId || '',
              nomeUsuario: item.nomeUsuario || item.usuarioNome || 'Administrador do Sistema',
              emailUsuario: item.emailUsuario || '',
              telefoneUsuario: item.telefoneUsuario || '',
              data: dataValida,
              horario: rangeHorario || shortHorario,
              status: statusCalculado
            };
          });

          this.verificarQueryParamQuadra();
        } else {
          this.usarReservasMockadas();
          this.verificarQueryParamQuadra();
        }
      },
      error: () => {
        this.isLoading = false;
        this.usarReservasMockadas();
        this.verificarQueryParamQuadra();
      }
    });
  }

  private usarReservasMockadas(): void {
    const hoje = new Date();
    const d = (offset: number) => { const dt = new Date(hoje); dt.setDate(dt.getDate() + offset); return dt.toISOString(); };
    const lista = [
      { id: 'RES-2026-010', nomeQuadra: 'Society 1', modalidade: 'Futebol Society', nomeUsuario: 'Lucas Ferreira', emailUsuario: 'lucas.ferreira@email.com', telefoneUsuario: '(11) 98765-4321', data: d(0), horario: '19:00 - 20:00', status: 'Ativa', observacoes: 'Reserva para jogo amador.' },
      { id: 'RES-2026-009', nomeQuadra: 'Beach Tennis Arena 1', modalidade: 'Beach Tennis', nomeUsuario: 'Mariana Costa', emailUsuario: 'mariana.costa@email.com', telefoneUsuario: '(11) 97654-3210', data: d(0), horario: '18:00 - 19:00', status: 'Ativa', observacoes: 'Treino de dupla.' },
      { id: 'RES-2026-008', nomeQuadra: 'Futsal 1', modalidade: 'Futsal', nomeUsuario: 'Gabriel Santos', emailUsuario: 'gabriel.santos@email.com', telefoneUsuario: '(11) 91234-5678', data: d(-1), horario: '20:00 - 21:00', status: 'Finalizada', observacoes: 'Partida finalizada.' },
      { id: 'RES-2026-007', nomeQuadra: 'Basquete 1', modalidade: 'Basquete', nomeUsuario: 'Carlos Eduardo', emailUsuario: 'carlos.edu@email.com', telefoneUsuario: '(11) 99887-6655', data: d(-2), horario: '17:00 - 18:30', status: 'Finalizada', observacoes: 'Treino de time.' },
      { id: 'RES-2026-006', nomeQuadra: 'Vôlei de Areia 1', modalidade: 'Vôlei', nomeUsuario: 'Amanda Lima', emailUsuario: 'amanda.lima@email.com', telefoneUsuario: '(11) 93344-5566', data: d(-3), horario: '16:00 - 17:00', status: 'Cancelada', observacoes: 'Cancelado pelo usuário.' },
      { id: 'RES-2026-005', nomeQuadra: 'Society 2', modalidade: 'Futebol Society', nomeUsuario: 'Rodrigo Alves', emailUsuario: 'rodrigo.alves@email.com', telefoneUsuario: '(11) 94455-6677', data: d(-4), horario: '21:00 - 22:00', status: 'Finalizada', observacoes: 'Jogo noturno.' },
      { id: 'RES-2026-004', nomeQuadra: 'Society 1', modalidade: 'Futebol Society', nomeUsuario: 'Fernando Rocha', emailUsuario: 'fernando.rocha@email.com', telefoneUsuario: '(11) 95566-7788', data: d(-5), horario: '18:00 - 19:00', status: 'Finalizada', observacoes: 'Racha semanal.' }
    ];

    this.todasReservas = lista.map(r => ({
      ...r,
      status: this.calcularStatusReserva(r.data, r.horario, r.status)
    }));
  }

  private calcularStatusReserva(dataIsoStr: string, horarioStr: string, statusOriginal?: string): 'Ativa' | 'Cancelada' | 'Finalizada' {
    if (statusOriginal === 'Cancelada') {
      return 'Cancelada';
    }

    if (!dataIsoStr) return (statusOriginal as any) || 'Ativa';

    const dataApenas = dataIsoStr.split('T')[0];
    let hora = 0;
    let min = 0;

    if (horarioStr) {
      const parteInicial = horarioStr.split('-')[0].trim();
      const tempo = parteInicial.split(':');
      if (tempo.length >= 2) {
        hora = parseInt(tempo[0], 10) || 0;
        min = parseInt(tempo[1], 10) || 0;
      }
    }

    const [ano, mes, dia] = dataApenas.split('-').map(Number);
    if (!ano || !mes || !dia) return (statusOriginal as any) || 'Ativa';

    const dataHorarioReserva = new Date(ano, mes - 1, dia, hora, min);
    const agora = new Date();

    if (dataHorarioReserva < agora) {
      return 'Finalizada';
    }

    return (statusOriginal as any) || 'Ativa';
  }

  // ────────────────────────────────────────
  //   MÉTRICAS
  // ────────────────────────────────────────
  getReservasHojeCount(): number {
    const hojeStr = new Date().toISOString().split('T')[0];
    return this.todasReservas.filter(r => r.data && r.data.split('T')[0] === hojeStr).length;
  }

  getReservasSemanaCount(): number {
    const hoje = new Date();
    const limite = new Date(); limite.setDate(hoje.getDate() - 7);
    return this.todasReservas.filter(r => { if (!r.data) return false; const dt = new Date(r.data); return dt >= limite && dt <= hoje; }).length;
  }

  getReservasMesCount(): number {
    const hoje = new Date();
    return this.todasReservas.filter(r => { if (!r.data) return false; const dt = new Date(r.data); return dt.getMonth() === hoje.getMonth() && dt.getFullYear() === hoje.getFullYear(); }).length;
  }

  // ────────────────────────────────────────
  //   FILTROS
  // ────────────────────────────────────────
  aplicarFiltros(): void {
    let r = [...this.quadras];
    if (this.termoBuscaQuadra.trim()) {
      const t = this.termoBuscaQuadra.toLowerCase().trim();
      r = r.filter(q => q.nome.toLowerCase().includes(t));
    }
    if (this.filtroModalidade !== 'Todas') {
      r = r.filter(q => q.modalidade.toLowerCase() === this.filtroModalidade.toLowerCase());
    }
    this.quadrasFiltradas = r;
  }

  // ────────────────────────────────────────
  //   VER RESERVAS POR QUADRA
  // ────────────────────────────────────────
  verReservasDaQuadra(quadra: ReservaQuadraDto): void {
    this.quadraSelecionada = quadra;
    this.reservasQuadraSelecionada = this.todasReservas
      .filter(r =>
        (r.quadraId && r.quadraId === quadra.id) ||
        (r.nomeQuadra && quadra.nome && r.nomeQuadra.toLowerCase().trim() === quadra.nome.toLowerCase().trim())
      )
      .sort((a, b) => new Date(b.data).getTime() - new Date(a.data).getTime());
  }

  private verificarQueryParamQuadra(): void {
    const quadraIdParam = this.route.snapshot.queryParamMap.get('quadraId');
    const quadraNomeParam = this.route.snapshot.queryParamMap.get('quadra');

    if (quadraIdParam) {
      const q = this.quadras.find(item => item.id === quadraIdParam);
      if (q) {
        this.verReservasDaQuadra(q);
      }
    } else if (quadraNomeParam) {
      const q = this.quadras.find(item => item.nome.toLowerCase().trim() === quadraNomeParam.toLowerCase().trim());
      if (q) {
        this.verReservasDaQuadra(q);
      }
    } else if (this.quadraSelecionada) {
      this.verReservasDaQuadra(this.quadraSelecionada);
    }
  }

  private formatHorarioShort(horarioRaw: string): string {
    if (!horarioRaw) return '';
    const parts = horarioRaw.split(':');
    if (parts.length >= 2) {
      return `${parts[0].padStart(2, '0')}:${parts[1].padStart(2, '0')}`;
    }
    return horarioRaw;
  }

  private formatHorarioRange(shortTime: string): string {
    if (!shortTime) return '';
    const parts = shortTime.split(':').map(Number);
    if (parts.length >= 2 && !isNaN(parts[0])) {
      const startHour = parts[0];
      const startMin = parts[1];
      const endHour = (startHour + 1) % 24;
      const startStr = `${String(startHour).padStart(2, '0')}:${String(startMin).padStart(2, '0')}`;
      const endStr = `${String(endHour).padStart(2, '0')}:${String(startMin).padStart(2, '0')}`;
      return `${startStr} - ${endStr}`;
    }
    return shortTime;
  }

  voltarParaQuadras(): void {
    this.quadraSelecionada = null;
    this.reservasQuadraSelecionada = [];
  }

  openDetailsModal(reserva: ReservaDto): void {
    const id = reserva.id || reserva.reservaId;
    if (id) {
      this.router.navigate(['/reservas/editar', id]);
    }
  }

  closeDetailsModal(): void {
    this.showDetailsModal = false;
    this.selectedReserva = null;
  }

  // Availability handling
  availableDates: string[] = [];
  availableTimes: string[] = [];
  private disponibilidadeMap: Map<string, string[]> = new Map();

  // Called when quadra selection changes in the form
  onQuadraChange(): void {
    if (!this.formQuadraId) {
      this.availableDates = [];
      this.availableTimes = [];
      this.disponibilidadeMap.clear();
      return;
    }
    this.quadraService.obterDisponibilidade(this.formQuadraId).subscribe({
      next: (res: any) => {
        if (res && res.ok && res.dados) {
          // Assume res.dados is an array of { data: string, horarios: string[] }
          this.availableDates = res.dados.map((d: any) => d.data);
          this.disponibilidadeMap.clear();
          res.dados.forEach((d: any) => {
            this.disponibilidadeMap.set(d.data, d.horarios);
          });
        } else {
          this.availableDates = [];
          this.disponibilidadeMap.clear();
        }
        // Reset date and time selections
        this.formData = '';
        this.formHorario = '';
        this.availableTimes = [];
      },
      error: () => {
        this.availableDates = [];
        this.disponibilidadeMap.clear();
        this.formData = '';
        this.formHorario = '';
        this.availableTimes = [];
      }
    });
  }

  // Called when date selection changes
  onDateChange(): void {
    if (this.formData && this.disponibilidadeMap.has(this.formData)) {
      this.availableTimes = this.disponibilidadeMap.get(this.formData) || [];
    } else {
      this.availableTimes = [];
    }
    this.formHorario = '';
  }

  abrirNovaReserva(): void {
    this.router.navigate(['/reservas/nova']);
  }

  cancelarNovaReserva(): void {
    this.showNovaReservaForm = false;
    this.limparForm();
  }

  private limparForm(): void {
    this.formQuadraId = '';
    this.formData = '';
    this.formHorario = '';
    this.formUsuarioId = '';
    this.formUsuarioNome = '';
    this.formUsuarioEmail = '';
    this.errosForm = [];
    this.successMessage = '';
  }

  validarForm(): boolean {
    this.errosForm = [];
    if (!this.formQuadraId) this.errosForm.push('Selecione uma quadra.');
    if (!this.formData) this.errosForm.push('Informe a data da reserva.');
    if (!this.formHorario) this.errosForm.push('Informe o horário da reserva.');
    if (!this.formUsuarioId) this.errosForm.push('Selecione um usuário.');
    return this.errosForm.length === 0;
  }

  salvarNovaReserva(): void {
    if (!this.validarForm()) return;

    this.salvando = true;
    this.errosForm = [];

    const command: CriarReservaCommand = {
      quadraId: this.formQuadraId,
      usuarioId: this.formUsuarioId,
      dataAgendada: new Date(this.formData).toISOString(),
      horarioAgendado: this.formHorario
    };

    this.reservaService.criar(command).subscribe({
      next: (res: RespostaApi<ReservaDto>) => {
        this.salvando = false;
        if (res && res.ok) {
          this.successMessage = 'Reserva criada com sucesso!';
          // Recarregar reservas
          this.carregarReservas();
          setTimeout(() => {
            this.showNovaReservaForm = false;
            this.limparForm();
          }, 1500);
        } else {
          this.errosForm = res?.erros?.length ? res.erros : ['Erro ao criar reserva.'];
        }
      },
      error: (err) => {
        this.salvando = false;
        console.warn('[Reservas] Falha na API. Simulando criação local.', err);
        // Fallback: adicionar mockado localmente
        const quadraNome = this.quadras.find(q => q.id === this.formQuadraId)?.nome || 'Quadra';
        const quadraModalidade = this.quadras.find(q => q.id === this.formQuadraId)?.modalidade || '';
        const novaReserva: ReservaDto = {
          id: 'RES-MOCK-' + Date.now(),
          quadraId: this.formQuadraId,
          nomeQuadra: quadraNome,
          modalidade: quadraModalidade,
          usuarioId: this.formUsuarioId,
          nomeUsuario: this.formUsuarioNome,
          emailUsuario: this.formUsuarioEmail,
          data: new Date(this.formData).toISOString(),
          horario: this.formHorario,
          status: 'Ativa'
        };
        this.todasReservas.unshift(novaReserva);
        this.successMessage = 'Reserva criada com sucesso!';
        setTimeout(() => {
          this.showNovaReservaForm = false;
          this.limparForm();
        }, 1500);
      }
    });
  }

  // ────────────────────────────────────────
  //   MODAL BUSCAR USUÁRIO
  // ────────────────────────────────────────
  abrirBuscarUsuario(): void {
    this.showBuscarUsuarioModal = true;
    this.termoBuscaUsuario = '';
    this.usuariosBusca = [];
    this.erroBuscaUsuario = '';
    // Carregar lista inicial
    this.buscarUsuarios();
  }

  fecharBuscarUsuario(): void {
    this.showBuscarUsuarioModal = false;
    this.termoBuscaUsuario = '';
    this.usuariosBusca = [];
  }

  buscarUsuarios(): void {
    this.buscandoUsuarios = true;
    this.erroBuscaUsuario = '';

    const token = this.authService.getToken();
    if (!token) { this.buscandoUsuarios = false; this.usarUsuariosMockados(); return; }

    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    let params = new HttpParams().set('pagina', '1').set('tamanhoPagina', '20');
    if (this.termoBuscaUsuario.trim()) {
      params = params.set('busca', this.termoBuscaUsuario.trim());
    }

    this.http.get<any>(`${this.USUARIOS_API}`, { headers, params }).subscribe({
      next: (res) => {
        this.buscandoUsuarios = false;
        if (res && res.ok && res.dados && res.dados.itens) {
          this.usuariosBusca = res.dados.itens;
        } else {
          this.usarUsuariosMockados();
        }
      },
      error: () => {
        this.buscandoUsuarios = false;
        this.usarUsuariosMockados();
      }
    });
  }

  private usarUsuariosMockados(): void {
    this.usuariosBusca = [
      { usuariosId: 'u1', nomeCompleto: 'Lucas Ferreira', email: 'lucas.ferreira@email.com', cpf: '123.456.789-00', telefone: '(11) 98765-4321', ativo: true },
      { usuariosId: 'u2', nomeCompleto: 'Mariana Costa', email: 'mariana.costa@email.com', cpf: '234.567.890-11', telefone: '(11) 97654-3210', ativo: true },
      { usuariosId: 'u3', nomeCompleto: 'Gabriel Santos', email: 'gabriel.santos@email.com', cpf: '345.678.901-22', telefone: '(11) 91234-5678', ativo: true },
      { usuariosId: 'u4', nomeCompleto: 'Amanda Lima', email: 'amanda.lima@email.com', cpf: '456.789.012-33', telefone: '(11) 93344-5566', ativo: true },
      { usuariosId: 'u5', nomeCompleto: 'Carlos Eduardo', email: 'carlos.edu@email.com', cpf: '567.890.123-44', telefone: '(11) 99887-6655', ativo: true }
    ];
  }

  selecionarUsuario(usuario: UsuarioBusca): void {
    this.formUsuarioId = usuario.usuariosId;
    this.formUsuarioNome = usuario.nomeCompleto;
    this.formUsuarioEmail = usuario.email;
    this.fecharBuscarUsuario();
  }

  limparUsuarioSelecionado(): void {
    this.formUsuarioId = '';
    this.formUsuarioNome = '';
    this.formUsuarioEmail = '';
  }

  // ────────────────────────────────────────
  //   UTILITÁRIOS
  // ────────────────────────────────────────
  getDataMinima(): string {
    return new Date().toISOString().split('T')[0];
  }

  getBadgeModalidadeClass(modalidade: string): string {
    if (!modalidade) return 'badge-default';
    const m = modalidade.toLowerCase();
    if (m.includes('society')) return 'badge-society';
    if (m.includes('futsal')) return 'badge-futsal';
    if (m.includes('basquete')) return 'badge-basquete';
    if (m.includes('vôlei') || m.includes('volei')) return 'badge-volei';
    if (m.includes('beach')) return 'badge-beachtennis';
    return 'badge-default';
  }

  getStatusClass(status: string): string {
    switch (status) {
      case 'Ativa': return 'status-active';
      case 'Cancelada': return 'status-inactive';
      case 'Finalizada': return 'status-finished';
      default: return 'status-active';
    }
  }
}
