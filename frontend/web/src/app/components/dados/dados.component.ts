import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { SecretariaService, SecretariaListaDto } from '../../services/secretaria.service';



@Component({
  selector: 'app-dados',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dados.component.html',
  styleUrl: './dados.component.css'
})
export class DadosComponent implements OnInit {
  dadosNome: string = '';
  dadosEmail: string = '';
  dadosContato: string = '';
  dadosCep: string = '';
  dadosEndereco: string = '';
  dadosNumero: string = '';
  dadosBairro: string = '';
  dadosCidade: string = '';

  // Flag indicating if the current user has admin role
  isAdmin: boolean = false;

  // Flag indicating if the edit mode is active
  isEditing: boolean = false;

  private secretariaId: string = '';
  constructor(private secretariaService: SecretariaService, private authService: AuthService) { }

  toggleEdit(): void {
    if (!this.isAdmin) return;
    this.isEditing = !this.isEditing;
  }

  /** Decode JWT token payload */
  private decodeToken(token: string): Record<string, unknown> | null {
    try {
      const payload = token.split('.')[1];
      const decoded = atob(payload.replace(/-/g, '+').replace(/_/g, '/'));
      return JSON.parse(decoded);
    } catch {
      return null;
    }
  }

  /** Determine if current user is admin */
  private determineRoles(): void {
    const token = this.authService.getToken();
    if (!token) {
      this.isAdmin = false;
      return;
    }
    const decoded = this.decodeToken(token);
    const role = decoded?.['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] as string | undefined;
    this.isAdmin = role?.toLowerCase() === 'admin';
  }

  ngOnInit(): void {
    this.determineRoles();
    this.carregarDados();
  }

  originalEmail: string = '';

  carregarDados(): void {
    const token = this.authService.getToken();
    if (!token) {
      console.warn('CarregarDados: usuário não autenticado.');
      return;
    }
    console.log('CarregarDados: chamando serviço listar');
    this.secretariaService.listar(1, 1).subscribe({
      next: (res) => {
        if (res.ok && res.dados && res.dados.itens && res.dados.itens.length > 0) {
          const sec = res.dados.itens[0];
          this.secretariaId = sec.secretariaId;
          this.dadosNome = sec.nome ?? '';
          this.dadosEmail = sec.email ?? '';
          this.originalEmail = sec.email ?? '';
          this.dadosContato = sec.contato ?? '';
          this.dadosCep = sec.cep ?? '';
          // The API might return address under the key "endereço" or "endereco"
          this.dadosEndereco = sec.endereco || (sec as any)['endereço'] || '';
          this.dadosNumero = sec.numero ?? '';
          this.dadosBairro = sec.bairro ?? '';
          this.dadosCidade = sec.cidade ?? '';
        } else {
          console.error('Nenhuma secretaria encontrada ou erro na resposta.', res);
        }
      },
      error: (err) => {
        console.error('Erro ao listar secretarias:', err);
      }
    });
  }

  salvarDados(): void {
    if (!this.isAdmin) {
      alert('Somente administradores podem editar os dados.');
      return;
    }
    if (!this.secretariaId) {
      alert('ID da secretaria não encontrado.');
      return;
    }
    const body: any = {
      nome: this.dadosNome,
      email: this.dadosEmail,
      contato: this.dadosContato,
      cep: this.dadosCep,
      endereco: this.dadosEndereco,
      numero: this.dadosNumero,
      bairro: this.dadosBairro,
      cidade: this.dadosCidade
    };


    this.secretariaService.atualizar(this.secretariaId, body).subscribe({
      next: (res) => {
        if (res.ok) {
          alert('Dados atualizados com sucesso!');
          this.originalEmail = this.dadosEmail;
          this.isEditing = false; // exit edit mode on success
        } else if (res.erros && res.erros.length > 0) {
          console.error('Erros ao atualizar:', res.erros);
          alert(`Falha ao atualizar os dados: ${res.erros.join(', ')}`);
        }
      },
      error: (err) => {
        console.error('Erro ao atualizar dados da secretaria:', err);
        const errorMsg = err?.error?.erros?.[0] || err?.error?.mensagem || 'Erro ao atualizar os dados.';
        alert(errorMsg);
      }
    });
  }
}
