import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from '../../../services/auth.service';
import { QuadraService, ReservaQuadraDto } from '../../../services/quadra.service';

export interface Vigilante {
  id?: string;
  nomeCompleto: string;
  cpf: string;
  email: string;
  telefone: string;
  dataNascimento: string;
  fotoPerfil?: string;
  matricula: string;
  arena: string;
  ativo: boolean;
}

interface ApiResponse<T> {
  ok: boolean;
  mensagem: string;
  dados: T;
  erros: string[];
}

interface PaginatedResult<T> {
  itens: T[];
  total: number;
  pagina: number;
  tamanhoPagina: number;
}

@Component({
  selector: 'app-vigilante-form',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './vigilante-form.component.html',
  styleUrl: './vigilante-form.component.css'
})
export class VigilanteFormComponent implements OnInit {
  vigilanteEditandoId: string | null = null;
  salvando = false;
  carregando = false;
  errorMessages: string[] = [];
  successMessage = '';

  nomeCompleto = '';
  cpf = '';
  email = '';
  telefone = '';
  dataNascimento = '';
  fotoPerfil = '';
  matricula = '';
  arena = '';
  ativo = true;

  quadras: ReservaQuadraDto[] = [];

  private readonly API_URL = 'https://localhost:7200/api/Vigilantes';

  constructor(
    private http: HttpClient,
    private authService: AuthService,
    private quadraService: QuadraService,
    private router: Router,
    private route: ActivatedRoute
  ) { }

  ngOnInit(): void {
    this.carregarQuadras();

    const idParam = this.route.snapshot.paramMap.get('id');
    if (idParam) {
      this.vigilanteEditandoId = idParam;
      this.carregarVigilante(idParam);
    }
  }

  carregarQuadras(): void {
    this.quadraService.listar(1, 100).subscribe({
      next: (res) => {
        if (res.ok && res.dados && res.dados.itens) {
          this.quadras = res.dados.itens;
          if (!this.arena && this.quadras.length > 0) {
            this.arena = this.quadras[0].nome;
          }
        }
      },
      error: (err) => {
        console.error('Erro ao carregar quadras:', err);
      }
    });
  }

  carregarVigilante(id: string): void {
    this.carregando = true;
    const token = this.authService.getToken();
    if (!token) {
      this.errorMessages = ['Usuário não autenticado.'];
      this.carregando = false;
      return;
    }

    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    this.http.get<ApiResponse<PaginatedResult<Vigilante>>>(this.API_URL, { headers }).subscribe({
      next: (res) => {
        this.carregando = false;
        if (res.ok && res.dados && res.dados.itens) {
          const g = res.dados.itens.find(v => v.id === id);
          if (g) {
            this.nomeCompleto = g.nomeCompleto;
            this.cpf = this.formatarCpf(g.cpf || '');
            this.email = g.email;
            this.telefone = this.formatarTelefone(g.telefone || '');
            this.dataNascimento = this.formatDateForInput(g.dataNascimento);
            this.fotoPerfil = g.fotoPerfil || '';
            this.matricula = g.matricula || '';
            this.arena = g.arena || '';
            this.ativo = g.ativo;
          } else {
            this.errorMessages = ['Vigilante não encontrado.'];
          }
        }
      },
      error: (err) => {
        this.carregando = false;
        console.error('Erro ao buscar vigilante:', err);
        this.errorMessages = ['Erro ao carregar dados do vigilante.'];
      }
    });
  }

  applyCpfMask(event: Event): void {
    const input = event.target as HTMLInputElement;
    let value = input.value.replace(/\D/g, '');
    if (value.length > 11) value = value.slice(0, 11);

    if (value.length > 9) {
      value = `${value.slice(0, 3)}.${value.slice(3, 6)}.${value.slice(6, 9)}-${value.slice(9)}`;
    } else if (value.length > 6) {
      value = `${value.slice(0, 3)}.${value.slice(3, 6)}.${value.slice(6)}`;
    } else if (value.length > 3) {
      value = `${value.slice(0, 3)}.${value.slice(3)}`;
    }
    this.cpf = value;
    input.value = value;
  }

  applyPhoneMask(event: Event): void {
    const input = event.target as HTMLInputElement;
    let value = input.value.replace(/\D/g, '');
    if (value.length > 11) value = value.slice(0, 11);

    if (value.length > 10) {
      value = `(${value.slice(0, 2)}) ${value.slice(2, 7)}-${value.slice(7)}`;
    } else if (value.length > 6) {
      value = `(${value.slice(0, 2)}) ${value.slice(2, 6)}-${value.slice(6)}`;
    } else if (value.length > 2) {
      value = `(${value.slice(0, 2)}) ${value.slice(2)}`;
    }
    this.telefone = value;
    input.value = value;
  }

  private formatarCpf(cpf: string): string {
    const digits = cpf.replace(/\D/g, '');
    if (digits.length !== 11) return cpf;
    return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9)}`;
  }

  private formatarTelefone(telefone: string): string {
    const digits = telefone.replace(/\D/g, '');
    if (digits.length === 11) {
      return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7)}`;
    } else if (digits.length === 10) {
      return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}-${digits.slice(6)}`;
    }
    return telefone;
  }

  formatDateForInput(dateVal: any): string {
    if (!dateVal) return '';
    const str = String(dateVal).trim();
    if (str.includes('/')) {
      const parts = str.split('/');
      if (parts.length === 3) {
        const day = parts[0].padStart(2, '0');
        const month = parts[1].padStart(2, '0');
        const year = parts[2].split('T')[0].split(' ')[0];
        return `${year}-${month}-${day}`;
      }
    }
    if (str.includes('-')) {
      return str.split('T')[0].split(' ')[0];
    }
    try {
      const d = new Date(str);
      if (!isNaN(d.getTime())) {
        return d.toISOString().split('T')[0];
      }
    } catch (e) {
      console.error('Error parsing date:', e);
    }
    return '';
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files[0]) {
      const file = input.files[0];
      const reader = new FileReader();
      reader.onload = () => {
        this.fotoPerfil = reader.result as string;
      };
      reader.readAsDataURL(file);
    }
  }

  salvarVigilante(): void {
    if (!this.nomeCompleto || !this.cpf || !this.email || !this.telefone || !this.dataNascimento) {
      this.errorMessages = ['Por favor, preencha todos os campos obrigatórios.'];
      return;
    }

    const token = this.authService.getToken();
    if (!token) {
      this.errorMessages = ['Sua sessão expirou. Por favor, faça login novamente.'];
      return;
    }

    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    const sanitizedCpf = this.cpf.replace(/\D/g, '');
    const sanitizedTelefone = this.telefone.replace(/\D/g, '');
    const isoDate = new Date(this.dataNascimento).toISOString();

    const body: any = {
      nomeCompleto: this.nomeCompleto,
      cpf: sanitizedCpf,
      email: this.email,
      telefone: sanitizedTelefone,
      dataNascimento: isoDate,
      fotoPerfil: this.fotoPerfil,
      matricula: this.matricula,
      arena: this.arena,
      ativo: this.ativo
    };

    if (this.vigilanteEditandoId) {
      body.id = this.vigilanteEditandoId;
    }

    this.salvando = true;
    this.errorMessages = [];
    this.successMessage = '';

    const isEdit = !!this.vigilanteEditandoId;
    const request$ = isEdit
      ? this.http.put<any>(`${this.API_URL}/${this.vigilanteEditandoId}`, body, { headers })
      : this.http.post<any>(this.API_URL, body, { headers });

    request$.subscribe({
      next: (res) => {
        this.salvando = false;
        if (res && (res.ok || res.sucesso || !res.erros || res.erros.length === 0)) {
          this.successMessage = isEdit ? 'Vigilante atualizado com sucesso!' : 'Vigilante cadastrado com sucesso!';
          setTimeout(() => {
            this.router.navigate(['/vigilante']);
          }, 1200);
        } else if (res && res.erros && res.erros.length > 0) {
          this.errorMessages = res.erros;
        } else {
          this.errorMessages = [`Erro ao ${isEdit ? 'atualizar' : 'cadastrar'} vigilante.`];
        }
      },
      error: (err) => {
        this.salvando = false;
        console.error(`Erro ao ${isEdit ? 'atualizar' : 'cadastrar'} vigilante:`, err);
        if (err.error && err.error.erros && err.error.erros.length > 0) {
          this.errorMessages = err.error.erros;
        } else {
          this.errorMessages = [`Erro ao ${isEdit ? 'atualizar' : 'cadastrar'} vigilante.`];
        }
      }
    });
  }

  cancelar(): void {
    this.router.navigate(['/vigilante']);
  }
}
