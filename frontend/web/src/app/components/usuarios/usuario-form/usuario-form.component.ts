import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from '../../../services/auth.service';

export interface Usuario {
  id?: string;
  nomeCompleto: string;
  email: string;
  cpf?: string;
  telefone?: string;
  ativo: boolean;
  perfilId?: number;
  fotoPerfil?: string;
  dataCriacao?: string;
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
  selector: 'app-usuario-form',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './usuario-form.component.html',
  styleUrl: './usuario-form.component.css'
})
export class UsuarioFormComponent implements OnInit {
  usuarioEditandoId: string | null = null;
  salvando = false;
  carregando = false;
  errorMessages: string[] = [];
  successMessage = '';

  nomeCompleto = '';
  email = '';
  cpf = '';
  telefone = '';
  senha = '';
  ativo = true;

  private readonly API_URL = 'https://localhost:7200/api/Usuarios';

  constructor(
    private http: HttpClient,
    private authService: AuthService,
    private router: Router,
    private route: ActivatedRoute
  ) { }

  ngOnInit(): void {
    const idParam = this.route.snapshot.paramMap.get('id');
    if (idParam) {
      this.usuarioEditandoId = idParam;
      this.carregarUsuario(idParam);
    }
  }

  carregarUsuario(id: string): void {
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

    // Try GET /api/Usuarios/{id} first
    this.http.get<any>(`${this.API_URL}/${id}`, { headers }).subscribe({
      next: (res) => {
        this.carregando = false;
        const u = res?.dados || res;
        if (u && (u.nomeCompleto || u.email)) {
          this.nomeCompleto = u.nomeCompleto || u.nome || '';
          this.email = u.email || '';
          this.cpf = this.formatarCpf(u.cpf || '');
          this.telefone = this.formatarTelefone(u.telefone || '');
          this.ativo = u.ativo !== false;
        } else {
          this.carregarUsuarioPelaLista(id, headers);
        }
      },
      error: () => {
        this.carregarUsuarioPelaLista(id, headers);
      }
    });
  }

  private carregarUsuarioPelaLista(id: string, headers: HttpHeaders): void {
    this.http.get<ApiResponse<PaginatedResult<any>>>(this.API_URL, { headers }).subscribe({
      next: (res) => {
        this.carregando = false;
        if (res && res.ok && res.dados && res.dados.itens) {
          const user = res.dados.itens.find((u: any) =>
            u.usuariosId === id || u.id === id || u.usuarioId === id
          );
          if (user) {
            this.nomeCompleto = user.nomeCompleto || user.nome || '';
            this.email = user.email || '';
            this.cpf = this.formatarCpf(user.cpf || '');
            this.telefone = this.formatarTelefone(user.telefone || '');
            this.ativo = user.ativo !== false;
          } else {
            this.errorMessages = ['Usuário não encontrado.'];
          }
        } else {
          this.errorMessages = ['Usuário não encontrado.'];
        }
      },
      error: (err) => {
        this.carregando = false;
        console.error('Erro ao buscar usuário:', err);
        this.errorMessages = ['Erro ao carregar os dados do usuário.'];
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

  salvarUsuario(): void {
    if (!this.nomeCompleto || !this.email || !this.cpf || !this.telefone) {
      this.errorMessages = ['Por favor, preencha todos os campos obrigatórios.'];
      return;
    }

    if (!this.usuarioEditandoId && !this.senha) {
      this.errorMessages = ['A senha é obrigatória para novos usuários.'];
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

    const cpfLimpo = this.cpf.replace(/\D/g, '');
    const telefoneLimpo = this.telefone.replace(/\D/g, '');

    this.salvando = true;
    this.errorMessages = [];
    this.successMessage = '';

    if (this.usuarioEditandoId) {
      const body = {
        nomeCompleto: this.nomeCompleto,
        email: this.email,
        cpf: cpfLimpo,
        telefone: telefoneLimpo,
        perfilId: 3,
        ativo: this.ativo
      };

      this.http.put<any>(`${this.API_URL}/${this.usuarioEditandoId}`, body, { headers }).subscribe({
        next: (res) => {
          this.salvando = false;
          if (res && res.ok) {
            this.successMessage = 'Usuário atualizado com sucesso!';
            setTimeout(() => {
              this.router.navigate(['/usuarios']);
            }, 1200);
          } else if (res && res.erros && res.erros.length > 0) {
            this.errorMessages = res.erros;
          }
        },
        error: (err) => {
          this.salvando = false;
          console.error('Erro ao atualizar usuário:', err);
          if (err.error && err.error.erros && err.error.erros.length > 0) {
            this.errorMessages = err.error.erros;
          } else {
            this.errorMessages = ['Erro ao atualizar usuário. Verifique os dados informados.'];
          }
        }
      });
    } else {
      const body = {
        nomeCompleto: this.nomeCompleto,
        email: this.email,
        cpf: cpfLimpo,
        telefone: telefoneLimpo,
        senha: this.senha,
        perfilId: 3
      };

      this.http.post<any>(this.API_URL, body, { headers }).subscribe({
        next: (res) => {
          this.salvando = false;
          if (res && res.ok) {
            this.successMessage = 'Usuário cadastrado com sucesso!';
            setTimeout(() => {
              this.router.navigate(['/usuarios']);
            }, 1200);
          } else if (res && res.erros && res.erros.length > 0) {
            this.errorMessages = res.erros;
          }
        },
        error: (err) => {
          this.salvando = false;
          console.error('Erro ao cadastrar usuário:', err);
          if (err.error && err.error.erros && err.error.erros.length > 0) {
            this.errorMessages = err.error.erros;
          } else {
            this.errorMessages = ['Erro ao cadastrar usuário. Verifique os dados informados.'];
          }
        }
      });
    }
  }

  cancelar(): void {
    this.router.navigate(['/usuarios']);
  }
}
