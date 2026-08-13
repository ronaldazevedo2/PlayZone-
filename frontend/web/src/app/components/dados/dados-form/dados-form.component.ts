import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { SecretariaService } from '../../../services/secretaria.service';

@Component({
  selector: 'app-dados-form',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './dados-form.component.html',
  styleUrl: './dados-form.component.css'
})
export class DadosFormComponent implements OnInit {
  secretariaId = '';
  salvando = false;
  carregando = false;
  errorMessages: string[] = [];
  successMessage = '';

  dadosNome = '';
  dadosEmail = '';
  dadosContato = '';
  dadosCep = '';
  dadosEndereco = '';
  dadosNumero = '';
  dadosBairro = '';
  dadosCidade = '';

  isAdmin = false;

  constructor(
    private secretariaService: SecretariaService,
    private authService: AuthService,
    private router: Router,
    private route: ActivatedRoute
  ) { }

  ngOnInit(): void {
    this.determineRoles();
    const idParam = this.route.snapshot.paramMap.get('id');
    if (idParam) {
      this.secretariaId = idParam;
      this.carregarDadosSecretaria(idParam);
    } else {
      this.carregarDadosGerais();
    }
  }

  private decodeToken(token: string): Record<string, unknown> | null {
    try {
      const payload = token.split('.')[1];
      const decoded = atob(payload.replace(/-/g, '+').replace(/_/g, '/'));
      return JSON.parse(decoded);
    } catch {
      return null;
    }
  }

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

  carregarDadosGerais(): void {
    this.carregando = true;
    this.secretariaService.listar(1, 1).subscribe({
      next: (res) => {
        this.carregando = false;
        if (res.ok && res.dados && res.dados.itens && res.dados.itens.length > 0) {
          const sec = res.dados.itens[0];
          this.secretariaId = sec.secretariaId;
          this.preencherCampos(sec);
        }
      },
      error: (err) => {
        this.carregando = false;
        console.error('Erro ao carregar dados:', err);
      }
    });
  }

  carregarDadosSecretaria(id: string): void {
    this.carregando = true;
    this.secretariaService.listar(1, 10).subscribe({
      next: (res) => {
        this.carregando = false;
        if (res.ok && res.dados && res.dados.itens) {
          const sec = res.dados.itens.find(s => s.secretariaId === id) || res.dados.itens[0];
          if (sec) {
            this.secretariaId = sec.secretariaId;
            this.preencherCampos(sec);
          }
        }
      },
      error: (err) => {
        this.carregando = false;
        console.error('Erro ao carregar dados:', err);
      }
    });
  }

  private preencherCampos(sec: any): void {
    this.dadosNome = sec.nome ?? '';
    this.dadosEmail = sec.email ?? '';
    this.dadosContato = sec.contato ?? '';
    this.dadosCep = sec.cep ?? '';
    this.dadosEndereco = sec.endereco || sec['endereço'] || '';
    this.dadosNumero = sec.numero ?? '';
    this.dadosBairro = sec.bairro ?? '';
    this.dadosCidade = sec.cidade ?? '';
  }

  salvar(): void {
    if (!this.secretariaId) {
      this.errorMessages = ['ID do registro de dados não encontrado.'];
      return;
    }

    this.salvando = true;
    this.errorMessages = [];
    this.successMessage = '';

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
        this.salvando = false;
        if (res.ok) {
          this.successMessage = 'Dados atualizados com sucesso!';
          setTimeout(() => {
            this.router.navigate(['/dados']);
          }, 1200);
        } else if (res.erros && res.erros.length > 0) {
          this.errorMessages = res.erros;
        } else {
          this.errorMessages = ['Erro ao atualizar os dados.'];
        }
      },
      error: (err) => {
        this.salvando = false;
        console.error('Erro ao atualizar dados da secretaria:', err);
        const errorMsg = err?.error?.erros?.[0] || err?.error?.mensagem || 'Erro ao atualizar os dados.';
        this.errorMessages = [errorMsg];
      }
    });
  }

  cancelar(): void {
    this.router.navigate(['/dados']);
  }
}
