import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from '../../services/auth.service';

interface SecretariaResponse {
  ok: boolean;
  mensagem: string;
  dados: {
    secretariaId: string;
    nome: string;
    email: string;
    contato: string;
    cep: string;
    endereco: string;
    numero: string;
    bairro: string;
    cidade: string;
  };
  erros: string[];
}

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

  private readonly API_URL = 'https://localhost:7218/api/Secretaria';

  constructor(private http: HttpClient, private authService: AuthService) { }

  ngOnInit(): void {
    this.carregarDados();
  }

  carregarDados(): void {
    const token = this.authService.getToken();
    if (!token) return;

    const headers = new HttpHeaders({
      'accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });

    this.http.get<SecretariaResponse>(this.API_URL, { headers }).subscribe({
      next: (res) => {
        if (res.ok && res.dados) {
          this.dadosNome = res.dados.nome;
          this.dadosEmail = res.dados.email;
          this.dadosContato = res.dados.contato;
          this.dadosCep = res.dados.cep;
          this.dadosEndereco = res.dados.endereco;
          this.dadosNumero = res.dados.numero;
          this.dadosBairro = res.dados.bairro;
          this.dadosCidade = res.dados.cidade;
        } else if (res.erros && res.erros.length > 0) {
          console.error('Erros retornados da API:', res.erros);
        }
      },
      error: (err) => {
        console.error('Erro ao buscar dados da secretaria:', err);
      }
    });
  }

  salvarDados(): void {
    alert('Dados salvos com sucesso!');
  }
}
