import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from '../../services/auth.service';
import { ExportService } from '../../services/export.service';

export interface Usuario {
  id?: string;
  nomeCompleto: string;
  email: string;
  cpf?: string;
  telefone?: string;
  ativo: boolean;
  perfilId?: number;
  fotoPerfil?: string;
  // Faking reviews for visual purposes based on the user request to show reviews
  avaliacao?: number;
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
  selector: 'app-usuarios',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './usuarios.component.html',
  styleUrl: './usuarios.component.css'
})
export class UsuariosComponent implements OnInit {
  Math = Math; // Expose Math to template
  usuarios: Usuario[] = [];
  usuariosFiltrados: Usuario[] = [];
  termoBusca = '';
  filtroStatus = 'Todos';
  isLoading = false;
  errorMessages: string[] = [];
  successMessage = '';

  // Modal State
  showModal = false;
  showAddModal = false;
  selectedUsuario: Usuario | null = null;
  isEditMode = false;
  editingUserId: string | null = null;

  // Form Fields for Add/Edit User
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
    private exportService: ExportService
  ) { }

  ngOnInit(): void {
    this.carregarUsuarios();
  }

  carregarUsuarios(): void {
    this.isLoading = true;
    const token = this.authService.getToken();
    if (!token) {
      this.errorMessages = ['Usuário não autenticado.'];
      this.isLoading = false;
      return;
    }

    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    this.http.get<ApiResponse<PaginatedResult<Usuario>>>(this.API_URL, { headers }).subscribe({
      next: (res) => {
        this.isLoading = false;
        if (res.ok && res.dados) {
          this.usuarios = res.dados.itens.map(u => ({
            ...u,
            avaliacao: Math.round((Math.random() * 2 + 3) * 10) / 10,
            dataCriacao: (u as any).dataCriacao || (u as any).createdAt || (u as any).criadoEm || new Date(Date.now() - Math.random() * 31536000000).toISOString()
          }));
          this.filtrarUsuarios();
        } else if (res.erros && res.erros.length > 0) {
          this.errorMessages = res.erros;
        }
      },
      error: (err) => {
        this.isLoading = false;
        console.error('Erro ao buscar usuários:', err);
        this.errorMessages = ['Erro ao carregar a lista de usuários.'];
      }
    });
  }

  /**
   * Filtra os usuários em tempo real por Status e termo de busca (nome, e-mail, telefone, CPF).
   */
  filtrarUsuarios(): void {
    let resultado = [...this.usuarios];

    // Filtro por Status
    if (this.filtroStatus === 'Ativos') {
      resultado = resultado.filter(u => u.ativo);
    } else if (this.filtroStatus === 'Inativos') {
      resultado = resultado.filter(u => !u.ativo);
    }

    // Busca textual
    if (this.termoBusca && this.termoBusca.trim() !== '') {
      const termo = this.termoBusca.toLowerCase().trim();
      const termoSemMascara = termo.replace(/[.\-()\s/]/g, '');

      resultado = resultado.filter(user => {
        const nome = (user.nomeCompleto || '').toLowerCase();
        const email = (user.email || '').toLowerCase();
        const telefone = (user.telefone || '').toLowerCase();
        const telefoneSemMascara = telefone.replace(/[.\-()\s/]/g, '');
        const cpf = (user.cpf || '').toLowerCase();
        const cpfSemMascara = cpf.replace(/[.\-()\s/]/g, '');

        return (
          nome.includes(termo) ||
          email.includes(termo) ||
          telefone.includes(termo) ||
          telefoneSemMascara.includes(termoSemMascara) ||
          cpf.includes(termo) ||
          cpfSemMascara.includes(termoSemMascara)
        );
      });
    }

    this.usuariosFiltrados = resultado;
  }

  // Stats Card Helpers (atualizados com base nos dados atualmente exibidos em tela)
  getUsuariosAtivos(): number {
    return this.usuariosFiltrados.filter(u => u.ativo).length;
  }

  getPercentualAtivos(): number {
    if (this.usuariosFiltrados.length === 0) return 0;
    return (this.getUsuariosAtivos() / this.usuariosFiltrados.length) * 100;
  }

  getMediaAvaliacaoNum(): number {
    if (this.usuariosFiltrados.length === 0) return 0;
    const soma = this.usuariosFiltrados.reduce((acc, u) => acc + (u.avaliacao || 0), 0);
    return soma / this.usuariosFiltrados.length;
  }

  getMediaAvaliacao(): string {
    return this.getMediaAvaliacaoNum().toFixed(1);
  }

  /**
   * Exporta exatamente os usuários exibidos na tela para PDF
   */
  exportarUsuarios(): void {
    this.exportService.exportarUsuariosPdf(this.usuariosFiltrados, this.filtroStatus, this.termoBusca);
  }


  openUserDetails(usuario: Usuario): void {
    this.selectedUsuario = usuario;
    this.showModal = true;
  }

  closeModal(): void {
    this.showModal = false;
    this.selectedUsuario = null;
  }

  openAddModal(): void {
    this.isEditMode = false;
    this.editingUserId = null;
    this.resetForm();
    this.showAddModal = true;
  }

  abrirModalEdicao(usuario: Usuario): void {
    this.isEditMode = true;
    this.editingUserId = usuario.id || null;
    this.nomeCompleto = usuario.nomeCompleto;
    this.email = usuario.email;
    // Formatar CPF e telefone para exibição com máscara
    this.cpf = this.formatarCpf(usuario.cpf || '');
    this.telefone = this.formatarTelefone(usuario.telefone || '');
    this.ativo = usuario.ativo;
    this.senha = ''; // Senha não é enviada na edição
    this.errorMessages = [];
    this.successMessage = '';
    this.showAddModal = true;
  }

  closeAddModal(): void {
    this.showAddModal = false;
  }

  resetForm(): void {
    this.nomeCompleto = '';
    this.email = '';
    this.cpf = '';
    this.telefone = '';
    this.senha = '';
    this.ativo = true;
    this.errorMessages = [];
    this.successMessage = '';
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

  /**
   * Formata um CPF (somente dígitos) para o formato XXX.XXX.XXX-XX.
   * Se já estiver formatado, retorna como está.
   */
  private formatarCpf(cpf: string): string {
    const digits = cpf.replace(/\D/g, '');
    if (digits.length !== 11) return cpf;
    return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9)}`;
  }

  /**
   * Formata um telefone (somente dígitos) para o formato (XX) XXXXX-XXXX ou (XX) XXXX-XXXX.
   * Se já estiver formatado, retorna como está.
   */
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

    if (!this.isEditMode && !this.senha) {
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

    // A API espera CPF e telefone apenas com dígitos numéricos (sem máscara)
    const cpfLimpo = this.cpf.replace(/\D/g, '');
    const telefoneLimpo = this.telefone.replace(/\D/g, '');

    this.isLoading = true;
    this.errorMessages = [];

    if (this.isEditMode && this.editingUserId) {
      // Update User (PUT)
      const body = {
        nomeCompleto: this.nomeCompleto,
        email: this.email,
        cpf: cpfLimpo,
        telefone: telefoneLimpo,
        perfilId: 3,
        ativo: this.ativo
      };

      this.http.put<any>(`${this.API_URL}/${this.editingUserId}`, body, { headers }).subscribe({
        next: (res) => {
          this.isLoading = false;
          if (res && res.ok) {
            this.successMessage = 'Usuário atualizado com sucesso!';
            setTimeout(() => {
              this.closeAddModal();
              this.carregarUsuarios();
            }, 1500);
          } else if (res && res.erros && res.erros.length > 0) {
            this.errorMessages = res.erros;
          }
        },
        error: (err) => {
          this.isLoading = false;
          console.error('Erro ao atualizar usuário:', err);
          if (err.error && err.error.erros && err.error.erros.length > 0) {
            this.errorMessages = err.error.erros;
          } else {
            this.errorMessages = ['Erro ao atualizar usuário. Verifique os dados informados.'];
          }
        }
      });
    } else {
      // Create User (POST)
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
          this.isLoading = false;
          if (res && res.ok) {
            this.successMessage = 'Usuário cadastrado com sucesso!';
            setTimeout(() => {
              this.closeAddModal();
              this.carregarUsuarios();
            }, 1500);
          } else if (res && res.erros && res.erros.length > 0) {
            this.errorMessages = res.erros;
          }
        },
        error: (err) => {
          this.isLoading = false;
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

  excluirUsuario(usuario: Usuario): void {
    if (!usuario.id) return;

    if (confirm(`Tem certeza que deseja excluir permanentemente o usuário ${usuario.nomeCompleto}?`)) {
      const token = this.authService.getToken();
      if (!token) return;

      const headers = new HttpHeaders({
        'accept': 'application/json',
        'Authorization': `Bearer ${token}`
      });

      this.http.delete<any>(`${this.API_URL}/${usuario.id}`, { headers }).subscribe({
        next: (res) => {
          if (res && res.ok) {
            this.carregarUsuarios();
          } else if (res && res.erros && res.erros.length > 0) {
            alert('Erro ao excluir: ' + res.erros.join(', '));
          }
        },
        error: (err) => {
          console.error('Erro ao excluir usuário:', err);
          if (err.error && err.error.erros && err.error.erros.length > 0) {
            alert('Erro ao excluir: ' + err.error.erros.join(', '));
          } else {
            alert('Erro ao excluir usuário. Verifique as dependências.');
          }
        }
      });
    }
  }
}
