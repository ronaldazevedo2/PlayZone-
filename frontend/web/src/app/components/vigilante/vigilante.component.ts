import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from '../../services/auth.service';

export interface Vigilante {
  id?: number;
  nomeCompleto: string;
  cpf: string;
  email: string;
  telefone: string;
  dataNascimento: string;
  fotoPerfil: string;
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

  // Modal State
  showModal = false;

  // Form Fields
  nomeCompleto = '';
  cpf = '';
  email = '';
  telefone = '';
  dataNascimento = '';
  fotoPerfil = '';

  private readonly API_URL = 'https://localhost:7218/api/Vigilantes';

  constructor(private http: HttpClient, private authService: AuthService) { }

  private formatDate(dateStr: string): string {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toISOString();
  }

  ngOnInit(): void {
    this.carregarVigilantes();
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
    this.showModal = true;
  }

  closeModal(): void {
    this.showModal = false;
  }

  resetForm(): void {
    this.nomeCompleto = '';
    this.cpf = '';
    this.email = '';
    this.telefone = '';
    this.dataNascimento = '';
    this.fotoPerfil = '';
    this.errorMessage = '';
    this.successMessage = '';
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

    const body = {
      nomeCompleto: this.nomeCompleto,
      cpf: sanitizedCpf,
      email: this.email,
      telefone: sanitizedTelefone,
      dataNascimento: isoDate,
      fotoPerfil: this.fotoPerfil
    };

    this.isLoading = true;
    this.errorMessage = '';

    console.log('Enviando vigilante:', body);
    this.http.post<any>(this.API_URL, body, { headers }).subscribe({
      next: (res) => {
        this.isLoading = false;
        if (res && res.ok) {
          this.successMessage = 'Vigilante cadastrado com sucesso!';
          setTimeout(() => {
            this.closeModal();
            this.carregarVigilantes();
          }, 1500);
        } else if (res && res.erros && res.erros.length > 0) {
          this.errorMessage = res.erros.join(', ');
        } else {
          this.errorMessage = 'Erro desconhecido ao cadastrar vigilante.';
        }
      },
      error: (err) => {
        this.isLoading = false;
        console.error('Erro ao cadastrar vigilante:', err);
        if (err.error && err.error.erros && err.error.erros.length > 0) {
          this.errorMessage = err.error.erros.join(', ');
        } else {
          this.errorMessage = 'Erro ao cadastrar vigilante. Verifique os dados informados.';
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
