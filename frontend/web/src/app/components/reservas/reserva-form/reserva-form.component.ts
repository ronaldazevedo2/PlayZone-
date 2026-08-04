import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { forkJoin, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { QuadraService, ReservaQuadraDto } from '../../../services/quadra.service';
import { ReservaService, ReservaDto, CriarReservaCommand } from '../../../services/reserva.service';
import { DataHorarioReservaService } from '../../../services/data-horario-reserva.service';
import { AuthService } from '../../../services/auth.service';
import { RespostaApi } from '../../../wrappers/api-response.wrapper';
import { ResultadoPaginado } from '../../../services/secretaria.service';

interface UsuarioBusca {
  usuariosId: string;
  nomeCompleto: string;
  email: string;
  cpf?: string;
  telefone?: string;
  ativo: boolean;
}

@Component({
  selector: 'app-reserva-form',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './reserva-form.component.html',
  styleUrl: './reserva-form.component.css'
})
export class ReservaFormComponent implements OnInit {
  reservaEditandoId: string | null = null;
  salvando = false;
  carregando = false;
  errosForm: string[] = [];
  successMessage = '';

  quadras: ReservaQuadraDto[] = [];

  // Form Fields
  formQuadraId = '';
  formData = '';
  formHorario = '';
  formHorarios: string[] = []; // Array para seleção múltipla de horários
  formUsuarioId = '';
  formUsuarioNome = '';
  formUsuarioEmail = '';
  status: 'Ativa' | 'Cancelada' | 'Finalizada' = 'Ativa';

  carregandoHorarios = false;
  horariosCadastradosAdmin: { horario: string; disponivel: boolean; rotulo: string }[] = [];
  semHorariosMensagem = '';

  // Search User Modal
  showBuscarUsuarioModal = false;
  termoBuscaUsuario = '';
  usuariosBusca: UsuarioBusca[] = [];
  buscandoUsuarios = false;
  erroBuscaUsuario = '';

  private readonly USUARIOS_API = 'https://localhost:7200/api/Usuarios';

  constructor(
    private quadraService: QuadraService,
    private reservaService: ReservaService,
    private dataHorarioService: DataHorarioReservaService,
    private authService: AuthService,
    private http: HttpClient,
    private router: Router,
    private route: ActivatedRoute
  ) { }

  ngOnInit(): void {
    this.carregarQuadras();

    const idParam = this.route.snapshot.paramMap.get('id');
    if (idParam) {
      this.reservaEditandoId = idParam;
      this.carregarReserva(idParam);
    } else {
      // Data padrão: amanhã
      const d = new Date();
      d.setDate(d.getDate() + 1);
      this.formData = d.toISOString().split('T')[0];
    }
  }

  carregarQuadras(): void {
    this.quadraService.listar(1, 100).subscribe({
      next: (res: RespostaApi<ResultadoPaginado<ReservaQuadraDto>>) => {
        if (res && res.ok && res.dados && res.dados.itens) {
          this.quadras = res.dados.itens.filter(q => this.quadraService.isLiberada(q));
        }
      },
      error: () => {}
    });
  }

  carregarReserva(id: string): void {
    this.carregando = true;
    this.reservaService.obterPorId(id).subscribe({
      next: (res) => {
        this.carregando = false;
        if (res && res.ok && res.dados) {
          const r = res.dados as any;
          this.formQuadraId = r.quadraId || r.QuadraId || '';

          const dataRaw = r.dataAgendada || r.data || r.DataAgendada || '';
          this.formData = dataRaw ? dataRaw.split('T')[0] : '';

          const horarioRaw = r.horarioAgendado || r.horario || r.HorarioAgendado || '';
          this.formHorario = this.formatHorarioShort(horarioRaw);
          if (this.formHorario) {
            this.formHorarios = [this.formHorario];
          }

          this.formUsuarioId = r.usuarioId || r.usuariosId || r.UsuariosId || r.id || '';
          this.formUsuarioNome = r.nomeUsuario || r.usuarioNome || r.nomeCompleto || '';
          this.formUsuarioEmail = r.emailUsuario || r.usuarioEmail || r.email || '';
          this.status = r.status || 'Ativa';

          if (this.formUsuarioId && !this.formUsuarioNome) {
            this.carregarNomeUsuario(this.formUsuarioId);
          }

          this.onQuadraOuDataChange();
        } else {
          this.errosForm = ['Reserva não encontrada.'];
        }
      },
      error: (err) => {
        this.carregando = false;
        console.error('Erro ao buscar reserva:', err);
        this.errosForm = ['Erro ao carregar detalhes da reserva.'];
      }
    });
  }

  private carregarNomeUsuario(usuarioId: string): void {
    const token = this.authService.getToken();
    if (!token) {
      this.formUsuarioNome = 'Administrador do Sistema';
      this.formUsuarioEmail = 'admin@baseapi.com';
      return;
    }

    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    this.http.get<any>(`${this.USUARIOS_API}/${usuarioId}`, { headers }).subscribe({
      next: (res) => {
        if (res && res.ok && res.dados) {
          this.formUsuarioNome = res.dados.nomeCompleto || res.dados.nome || 'Usuário do Sistema';
          this.formUsuarioEmail = res.dados.email || '';
        } else if (res && res.nomeCompleto) {
          this.formUsuarioNome = res.nomeCompleto;
          this.formUsuarioEmail = res.email || '';
        } else {
          this.buscarUsuarioNaListaFallback(usuarioId);
        }
      },
      error: () => {
        this.buscarUsuarioNaListaFallback(usuarioId);
      }
    });
  }

  private buscarUsuarioNaListaFallback(usuarioId: string): void {
    const token = this.authService.getToken();
    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    this.http.get<any>(this.USUARIOS_API, { headers }).subscribe({
      next: (res) => {
        if (res && res.ok && res.dados && res.dados.itens) {
          const u = res.dados.itens.find((item: any) =>
            (item.usuariosId || item.id || item.usuarioId) === usuarioId
          );
          if (u) {
            this.formUsuarioNome = u.nomeCompleto || u.nome || '';
            this.formUsuarioEmail = u.email || '';
          } else {
            this.formUsuarioNome = 'Administrador do Sistema';
            this.formUsuarioEmail = 'admin@baseapi.com';
          }
        } else {
          this.formUsuarioNome = 'Administrador do Sistema';
          this.formUsuarioEmail = 'admin@baseapi.com';
        }
      },
      error: () => {
        this.formUsuarioNome = 'Administrador do Sistema';
        this.formUsuarioEmail = 'admin@baseapi.com';
      }
    });
  }

  abrirBuscarUsuario(): void {
    this.showBuscarUsuarioModal = true;
    this.termoBuscaUsuario = '';
    this.usuariosBusca = [];
    this.erroBuscaUsuario = '';
    this.buscarUsuarios();
  }

  fecharBuscarUsuario(): void {
    this.showBuscarUsuarioModal = false;
  }

  buscarUsuarios(): void {
    this.buscandoUsuarios = true;
    this.erroBuscaUsuario = '';

    const token = this.authService.getToken();
    if (!token) {
      this.buscandoUsuarios = false;
      this.usarUsuariosMockados();
      return;
    }

    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    this.http.get<any>(this.USUARIOS_API, { headers }).subscribe({
      next: (res) => {
        this.buscandoUsuarios = false;
        if (res && res.ok && res.dados && res.dados.itens) {
          let lista: UsuarioBusca[] = res.dados.itens.map((u: any) => ({
            usuariosId: u.usuariosId || u.id || u.usuarioId || '',
            nomeCompleto: u.nomeCompleto || '',
            email: u.email || '',
            cpf: u.cpf,
            telefone: u.telefone,
            ativo: u.ativo
          }));

          if (this.termoBuscaUsuario.trim()) {
            const t = this.termoBuscaUsuario.toLowerCase().trim();
            lista = lista.filter(u =>
              u.nomeCompleto.toLowerCase().includes(t) ||
              u.email.toLowerCase().includes(t) ||
              (u.cpf && u.cpf.includes(t)) ||
              (u.telefone && u.telefone.includes(t))
            );
          }

          this.usuariosBusca = lista;
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
    const mocks: UsuarioBusca[] = [
      { usuariosId: 'usr-001', nomeCompleto: 'Gabriel Santos', email: 'gabriel.santos@email.com', telefone: '(11) 98765-4321', ativo: true },
      { usuariosId: 'usr-002', nomeCompleto: 'Mariana Oliveira', email: 'mariana.oliveira@email.com', telefone: '(11) 91234-5678', ativo: true },
      { usuariosId: 'usr-003', nomeCompleto: 'Lucas Mendes', email: 'lucas.mendes@email.com', telefone: '(11) 95555-4444', ativo: true },
      { usuariosId: 'usr-004', nomeCompleto: 'Beatriz Costa', email: 'beatriz.costa@email.com', telefone: '(11) 97777-8888', ativo: true }
    ];

    if (this.termoBuscaUsuario.trim()) {
      const t = this.termoBuscaUsuario.toLowerCase().trim();
      this.usuariosBusca = mocks.filter(u =>
        u.nomeCompleto.toLowerCase().includes(t) ||
        u.email.toLowerCase().includes(t)
      );
    } else {
      this.usuariosBusca = mocks;
    }
  }

  selecionarUsuario(user: UsuarioBusca): void {
    this.formUsuarioId = user.usuariosId || (user as any).id || (user as any).usuarioId || '';
    this.formUsuarioNome = user.nomeCompleto;
    this.formUsuarioEmail = user.email;
    this.fecharBuscarUsuario();
  }

  // --- Métodos de Seleção de Horários Múltiplos ---
  toggleHorario(horario: string, disponivel: boolean): void {
    if (!disponivel) return;

    const idx = this.formHorarios.indexOf(horario);
    if (idx > -1) {
      this.formHorarios.splice(idx, 1);
    } else {
      this.formHorarios.push(horario);
    }

    if (this.formHorarios.length > 0) {
      this.formHorario = this.formHorarios[0];
    } else {
      this.formHorario = '';
    }
  }

  isHorarioSelecionado(horario: string): boolean {
    return this.formHorarios.includes(horario) || this.formHorario === horario;
  }

  validarForm(): boolean {
    this.errosForm = [];
    if (!this.formQuadraId) this.errosForm.push('Selecione uma quadra.');
    if (!this.formData) this.errosForm.push('Informe a data da reserva.');

    const temHorarios = this.formHorarios.length > 0 || !!this.formHorario;
    if (!temHorarios) this.errosForm.push('Selecione ao menos um horário para a reserva.');

    if (!this.formUsuarioId) this.errosForm.push('Selecione um usuário.');
    return this.errosForm.length === 0;
  }

  /**
   * Ao clicar no botão Salvar Reserva, itera sobre a lista de horários selecionados
   * e envia cada CriarReservaCommand 1 a 1 para a API (this.reservaService.criar(command)).
   */
  salvarReserva(): void {
    if (!this.validarForm()) return;

    this.salvando = true;
    this.errosForm = [];

    // Coleta a lista final de horários selecionados
    const listaHorarios = this.formHorarios.length > 0
      ? [...this.formHorarios]
      : (this.formHorario ? [this.formHorario] : []);

    // Monta os comandos CriarReservaCommand para enviar 1 a 1 à API
    const comandos: CriarReservaCommand[] = listaHorarios.map(h => {
      const horarioFormatted = h.length === 5 ? `${h}:00` : h;
      const dataIsoFormat = this.formData.includes('T') ? this.formData : `${this.formData}T00:00:00`;

      return {
        quadraId: this.formQuadraId,
        usuarioId: this.formUsuarioId,
        dataAgendada: dataIsoFormat,
        horarioAgendado: horarioFormatted
      };
    });

    // Mapeia cada comando para uma chamada HTTP individual enviada 1 a 1 via forkJoin
    const requests = comandos.map(cmd =>
      this.reservaService.criar(cmd).pipe(
        catchError(err => of({ ok: false, error: err }))
      )
    );

    forkJoin(requests).subscribe({
      next: (results: any[]) => {
        this.salvando = false;
        const sucessos = results.filter(r => r?.ok !== false && !r?.error).length;

        if (sucessos > 0) {
          this.successMessage = `${sucessos} reserva(s) enviada(s) e cadastrada(s) 1 a 1 com sucesso!`;
          setTimeout(() => {
            this.router.navigate(['/reservas']);
          }, 1200);
        } else {
          this.errosForm = ['Erro ao salvar as reservas na API.'];
        }
      },
      error: (err) => {
        this.salvando = false;
        console.error('Erro na requisição das reservas:', err);
        this.errosForm = ['Ocorreu um erro ao comunicar com a API de Reservas.'];
      }
    });
  }

  cancelar(): void {
    this.router.navigate(['/reservas']);
  }

  onQuadraOuDataChange(): void {
    this.horariosCadastradosAdmin = [];
    this.formHorarios = [];
    this.semHorariosMensagem = '';

    if (!this.formQuadraId || !this.formData) {
      return;
    }

    this.carregandoHorarios = true;

    this.dataHorarioService.obterHorariosDisponiveis(this.formQuadraId, this.formData).subscribe({
      next: (res: any) => {
        this.carregandoHorarios = false;
        const dados = res?.dados ?? res;

        if (Array.isArray(dados) && dados.length > 0) {
          this.horariosCadastradosAdmin = dados.map((item: any) => {
            const rawHorario = item.horario || item.time || '';
            const shortTime = this.formatHorarioShort(rawHorario);
            const rangeTime = this.formatHorarioRange(shortTime);
            const disponivel = item.disponivel !== false;
            return {
              horario: shortTime,
              disponivel,
              rotulo: rangeTime + (!disponivel ? ' (Já reservado)' : '')
            };
          });

          if (this.formHorario && !this.horariosCadastradosAdmin.some(h => h.horario === this.formHorario)) {
            const shortTime = this.formatHorarioShort(this.formHorario);
            const rangeTime = this.formatHorarioRange(shortTime);
            this.horariosCadastradosAdmin.unshift({
              horario: shortTime,
              disponivel: true,
              rotulo: rangeTime
            });
          }
        } else {
          this.carregarHorariosFallBack();
        }

        if (this.horariosCadastradosAdmin.length === 0) {
          this.semHorariosMensagem = 'Nenhum horário cadastrado pelo administrador para esta data.';
        }
      },
      error: (err) => {
        console.warn('[ReservaForm] Erro ao obter horários disponíveis, tentando fallback:', err);
        this.carregarHorariosFallBack();
      }
    });
  }

  private carregarHorariosFallBack(): void {
    this.dataHorarioService.listarPorQuadra(this.formQuadraId).subscribe({
      next: (res: any) => {
        this.carregandoHorarios = false;
        const dados = res?.dados ?? res;
        if (Array.isArray(dados)) {
          const dataFiltro = this.formData;
          const filtrados = dados.filter((item: any) => {
            const dataIso = item.data ? item.data.split('T')[0] : '';
            return dataIso === dataFiltro;
          });

          this.horariosCadastradosAdmin = filtrados.map((item: any) => {
            const shortTime = this.formatHorarioShort(item.horario);
            const rangeTime = this.formatHorarioRange(shortTime);
            return {
              horario: shortTime,
              disponivel: true,
              rotulo: rangeTime
            };
          });

          if (this.horariosCadastradosAdmin.length === 0) {
            this.semHorariosMensagem = 'Nenhum horário cadastrado pelo administrador para esta data.';
          }
        } else {
          this.semHorariosMensagem = 'Nenhum horário cadastrado pelo administrador para esta data.';
        }
      },
      error: () => {
        this.carregandoHorarios = false;
        this.semHorariosMensagem = 'Nenhum horário cadastrado pelo administrador para esta data.';
      }
    });
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
}
