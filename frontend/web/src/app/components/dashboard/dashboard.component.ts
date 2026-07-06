import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SecretariaService, SecretariaListaDto } from '../../services/secretaria.service';

interface Booking {
  time: string;
  court: string;
  client: string;
  type: string;
  typeClass: string;
}

interface Message {
  sender: string;
  avatar: string;
  content: string;
  time: string;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css'
})
export class DashboardComponent implements OnInit {
  // Stats
  reservasHojeCount = 24;
  quadrasOcupadasCount = 5;
  quadrasTotalCount = 8;
  mensagensPendentesCount = 7;
  avaliacaoMedia = 4.8;

  // Bookings list
  bookings: Booking[] = [
    { time: '18:00', court: 'Society 1', client: 'João Silva', type: 'Futebol Society', typeClass: 'badge-society' },
    { time: '19:00', court: 'Society 2', client: 'Lucas Santos', type: 'Futebol Society', typeClass: 'badge-society' },
    { time: '20:00', court: 'Beach Tennis', client: 'Maria Souza', type: 'Beach Tennis', typeClass: 'badge-tennis' },
    { time: '21:00', court: 'Futsal 1', client: 'Carlos Oliveira', type: 'Futsal', typeClass: 'badge-futsal' },
    { time: '22:00', court: 'Vôlei de Areia', client: 'Ana Beatriz', type: 'Vôlei', typeClass: 'badge-volei' }
  ];

  // Messages list
  messages: Message[] = [
    { sender: 'João Silva', avatar: 'JS', content: 'Posso levar mais um jogador?', time: 'Há 2 min' },
    { sender: 'Carlos Oliveira', avatar: 'CO', content: 'Como funciona o cancelamento?', time: 'Há 10 min' }
  ];

  secretarias: SecretariaListaDto[] = [];
  carregando = false;
  erro = '';

  constructor(
    private secretariaService: SecretariaService
  ) { }

  ngOnInit(): void {
    this.carregarSecretarias();
  }

  carregarSecretarias(): void {
    this.carregando = true;

    this.secretariaService.listar(1, 50).subscribe({
      next: (res) => {
        this.secretarias = res.dados.itens ?? [];
        this.carregando = false;
      },
      error: (err) => {
        console.error(err);
        this.erro = 'Erro ao carregar secretarias.';
        this.carregando = false;
      }
    });
  }
  triggerAction(actionName: string): void {
    alert(`Ação executada: ${actionName} (MOCK)`);
  }
}
