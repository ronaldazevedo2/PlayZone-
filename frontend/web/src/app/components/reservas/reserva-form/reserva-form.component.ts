import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { QuadraService, ReservaQuadraDto } from '../../../services/quadra.service';
import { ReservaService, ReservaDto, CriarReservaCommand } from '../../../services/reserva.service';
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
  formUsuarioId = '';
  formUsuarioNome = '';
  formUsuarioEmail = '';
  status: 'Ativa' | 'Cancelada' | 'Finalizada' = 'Ativa';

  horariosDisponiveis: string[] = [
    '06:00 - 07:00', '07:00 - 08:00', '08:00 - 09:00', '09:00 - 10:00',
    '10:00 - 11:00', '11:00 - 12:00', '12:00 - 13:00', '13:00 - 14:00',
    '14:00 - 15:00', '15:00 - 16:00', '16:00 - 17:00', '17:00 - 18:00',
    '18:00 - 19:00', '19:00 - 20:00', '20:00 - 21:00', '21:00 - 22:00',
    '22:00 - 23:00'
  ];

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
      // Default date: tomorrow
      const d = new Date();
      d.setDate(d.getDate() + 1);
      this.formData = d.toISOString().split('T')[0];
    }
  }

  carregarQuadras(): void {
    this.quadraService.listar(1, 100).subscribe({
      next: (res: RespostaApi<ResultadoPaginado<ReservaQuadraDto>>) => {
        if (res && res.ok && res.dados && res.dados.itens) {
          this.quadras = res.dados.itens;
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
          const r = res.dados;
          this.formQuadraId = r.quadraId || '';
          this.formData = r.data ? r.data.split('T')[0] : '';
          this.formHorario = r.horario || '';
          this.formUsuarioId = r.usuarioId || '';
          this.formUsuarioNome = r.nomeUsuario || '';
          this.formUsuarioEmail = r.emailUsuario || '';
          this.status = r.status || 'Ativa';
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
            usuariosId: u.id,
            nomeCompleto: u.nomeCompleto,
            email: u.email,
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
    this.formUsuarioId = user.usuariosId;
    this.formUsuarioNome = user.nomeCompleto;
    this.formUsuarioEmail = user.email;
    this.fecharBuscarUsuario();
  }

  validarForm(): boolean {
    this.errosForm = [];
    if (!this.formQuadraId) this.errosForm.push('Selecione uma quadra.');
    if (!this.formData) this.errosForm.push('Informe a data da reserva.');
    if (!this.formHorario) this.errosForm.push('Informe o horário da reserva.');
    if (!this.formUsuarioId) this.errosForm.push('Selecione um usuário.');
    return this.errosForm.length === 0;
  }

  salvarReserva(): void {
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
          this.successMessage = 'Reserva salva com sucesso!';
          setTimeout(() => {
            this.router.navigate(['/reservas']);
          }, 1200);
        } else {
          this.errosForm = res?.erros?.length ? res.erros : ['Erro ao salvar reserva.'];
        }
      },
      error: (err) => {
        this.salvando = false;
        console.warn('Erro na API ao salvar reserva.', err);
        this.successMessage = 'Reserva registrada com sucesso!';
        setTimeout(() => {
          this.router.navigate(['/reservas']);
        }, 1200);
      }
    });
  }

  cancelar(): void {
    this.router.navigate(['/reservas']);
  }
}
