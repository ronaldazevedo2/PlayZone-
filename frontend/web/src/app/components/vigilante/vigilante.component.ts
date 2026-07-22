import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from '../../services/auth.service';
import { QuadraService, ReservaQuadraDto } from '../../services/quadra.service';

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
  selector: 'app-vigilante',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './vigilante.component.html',
  styleUrl: './vigilante.component.css'
})
export class VigilanteComponent implements OnInit {
  guards: Vigilante[] = [];
  isLoading = false;
  errorMessage = '';
  successMessage = '';
  quadras: ReservaQuadraDto[] = [];

  // Modal State
  showModal = false;
  vigilanteEditandoId: string | null = null;
  menuAbertoId: string | null = null;

  // Form Fields
  nomeCompleto = '';
  cpf = '';
  email = '';
  telefone = '';
  dataNascimento = '';
  fotoPerfil = '';
  matricula = '';
  arena = '';
  ativo = true;

  private readonly API_URL = 'https://localhost:7200/api/Vigilantes';

  constructor(
    private http: HttpClient,
    private authService: AuthService,
    private quadraService: QuadraService
  ) { }

  private formatDate(dateStr: string): string {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toISOString();
  }

  ngOnInit(): void {
    this.carregarVigilantes();
    this.carregarQuadras();
  }

  carregarQuadras(): void {
    console.log('Entrou em carregarQuadras');

    this.quadraService.listar(1, 100).subscribe({
      next: (res) => {
        console.log('Resposta da API:', res);

        if (res.ok && res.dados) {
          this.quadras = res.dados.itens ?? [];
          console.log('Quadras:', this.quadras);
          if (!this.arena && this.quadras.length > 0) {
            this.arena = this.quadras[0].nome;
          }
        }
      },
      error: (err) => {
        console.error('Erro ao buscar quadras:', err);
      }
    });
  }

  carregarVigilantes(): void {
    this.isLoading = true;
    const token = this.authService.getToken();
    if (!token) {
      this.errorMessage = 'Usuário não autenticado.';
      this.isLoading = false;
      return;
    }

    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    this.http.get<ApiResponse<PaginatedResult<Vigilante>>>(this.API_URL, { headers }).subscribe({
      next: (res) => {
        this.isLoading = false;
        if (res.ok && res.dados) {
          this.guards = res.dados.itens;
        } else if (res.erros && res.erros.length > 0) {
          this.errorMessage = res.erros.join(', ');
        }
      },
      error: (err) => {
        this.isLoading = false;
        console.error('Erro ao buscar vigilantes:', err);
        this.errorMessage = 'Erro ao carregar a lista de vigilantes.';
      }
    });
  }

  openAddModal(): void {
    this.resetForm();
    this.carregarQuadras(); // Garante que a lista de quadras esteja sempre atualizada ao abrir o modal
    this.showModal = true;
  }

  editarVigilante(guard: any): void {
    console.log('Objeto vigilante recebido para edição:', guard);
    this.resetForm();
    this.carregarQuadras();

    this.vigilanteEditandoId = guard.id || guard.Id || null;
    if (!this.vigilanteEditandoId) return;

    const token = this.authService.getToken();
    if (!token) {
      this.errorMessage = 'Usuário não autenticado.';
      return;
    }

    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    this.isLoading = true;
    this.http.get<any>(`${this.API_URL}/${this.vigilanteEditandoId}`, { headers }).subscribe({
      next: (res) => {
        this.isLoading = false;
        if (res.ok && res.dados) {
          const detail = res.dados;
          this.nomeCompleto = detail.nomeCompleto || detail.NomeCompleto || '';
          this.cpf = this.formatCpf(detail.cpf || detail.Cpf || detail.CPF || '');
          this.email = detail.email || detail.Email || detail.eMail || '';
          this.telefone = this.formatTelefone(detail.telefone || detail.Telefone || detail.fone || detail.Fone || '');
          this.dataNascimento = this.formatDateForInput(detail.dataNascimento || detail.DataNascimento || detail.nascimento || '');
          this.fotoPerfil = this.getFoto(detail);
          this.matricula = detail.matricula || detail.Matricula || '';
          this.arena = detail.arena || detail.Arena || '';
          this.ativo = detail.ativo !== undefined ? detail.ativo : (detail.Ativo !== undefined ? detail.Ativo : true);
          
          this.showModal = true;
        } else {
          this.errorMessage = 'Erro ao carregar os detalhes do vigilante.';
        }
      },
      error: (err) => {
        this.isLoading = false;
        console.error('Erro ao buscar detalhes do vigilante:', err);
        this.errorMessage = 'Erro ao carregar detalhes do vigilante.';
      }
    });
  }

  excluirVigilante(guard: Vigilante): void {
    if (!guard.id) return;

    if (!confirm(`Tem certeza que deseja excluir o vigilante ${guard.nomeCompleto}?`)) {
      return;
    }

    const token = this.authService.getToken();
    if (!token) {
      this.errorMessage = 'Sua sessão expirou. Por favor, faça login novamente.';
      return;
    }

    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    this.isLoading = true;
    this.http.delete<any>(`${this.API_URL}/${guard.id}`, { headers }).subscribe({
      next: (res) => {
        this.isLoading = false;
        this.carregarVigilantes();
      },
      error: (err) => {
        this.isLoading = false;
        console.error('Erro ao excluir vigilante:', err);
        this.errorMessage = 'Erro ao excluir vigilante.';
      }
    });
  }

  abrirOpcoes(guard: Vigilante, event: MouseEvent): void {
    event.stopPropagation();
    this.menuAbertoId = this.menuAbertoId === guard.id ? null : (guard.id || null);
  }

  fecharMenus(): void {
    this.menuAbertoId = null;
  }

  closeModal(): void {
    this.showModal = false;
  }

  resetForm(): void {
    this.vigilanteEditandoId = null;
    this.nomeCompleto = '';
    this.cpf = '';
    this.email = '';
    this.telefone = '';
    this.dataNascimento = '';
    this.fotoPerfil = '';
    this.matricula = '';
    this.arena = '';
    this.ativo = true;
    this.errorMessage = '';
    this.successMessage = '';
  }

  private formatCpf(cpf: string): string {
    if (!cpf) return '';
    const digits = cpf.replace(/\D/g, '');
    if (digits.length === 11) {
      return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9)}`;
    }
    return cpf;
  }

  private formatTelefone(tel: string): string {
    if (!tel) return '';
    const digits = String(tel).replace(/\D/g, '');
    if (digits.length === 11) {
      return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7)}`;
    } else if (digits.length === 10) {
      return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}-${digits.slice(6)}`;
    }
    return tel;
  }

  getFoto(guard: any): string {
    if (!guard) return '';
    return guard.fotoPerfil || guard.FotoPerfil || guard.fotoperfil || guard.foto || '';
  }

  private formatDateForInput(dateVal: any): string {
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

  // Simple masks helper functions
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

  salvarVigilante(): void {
    if (!this.nomeCompleto || !this.cpf || !this.email || !this.telefone || !this.dataNascimento) {
      this.errorMessage = 'Por favor, preencha todos os campos obrigatórios.';
      return;
    }

    const token = this.authService.getToken();
    if (!token) {
      this.errorMessage = 'Sua sessão expirou. Por favor, faça login novamente.';
      return;
    }

    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    // Sanitize CPF and telefone (remove non-digit characters)
    const sanitizedCpf = this.cpf.replace(/\D/g, '');
    const sanitizedTelefone = this.telefone.replace(/\D/g, '');
    // Ensure ISO date format (yyyy-MM-dd -> ISO)
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

    this.isLoading = true;
    this.errorMessage = '';

    const isEdit = !!this.vigilanteEditandoId;
    const request$ = isEdit
      ? this.http.put<any>(`${this.API_URL}/${this.vigilanteEditandoId}`, body, { headers })
      : this.http.post<any>(this.API_URL, body, { headers });

    request$.subscribe({
      next: (res) => {
        this.isLoading = false;
        if (res && (res.ok || res.sucesso || !res.erros || res.erros.length === 0)) {
          this.successMessage = isEdit
            ? 'Vigilante atualizado com sucesso!'
            : 'Vigilante cadastrado com sucesso!';
          setTimeout(() => {
            this.closeModal();
            this.carregarVigilantes();
          }, 1200);
        } else if (res && res.erros && res.erros.length > 0) {
          this.errorMessage = res.erros.join(', ');
        } else {
          this.errorMessage = `Erro ao ${isEdit ? 'atualizar' : 'cadastrar'} vigilante.`;
        }
      },
      error: (err) => {
        this.isLoading = false;
        console.error(`Erro ao ${isEdit ? 'atualizar' : 'cadastrar'} vigilante:`, err);
        if (err.error && err.error.erros && err.error.erros.length > 0) {
          this.errorMessage = err.error.erros.join(', ');
        } else {
          this.errorMessage = `Erro ao ${isEdit ? 'atualizar' : 'cadastrar'} vigilante. Verifique os dados informados.`;
        }
      }
    });
  }

  registerGuardIncident(): void {
    const desc = prompt('Descreva a ocorrência do vigilante:');
    if (desc) {
      alert('Ocorrência de vigilância registrada com sucesso!');
    }
  }


}
