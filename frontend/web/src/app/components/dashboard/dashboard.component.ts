import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';

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

interface Guard {
  name: string;
  shift: string;
  status: 'Ativo' | 'Inativo' | 'De Folga';
  lastCheckin: string;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css'
})
export class DashboardComponent implements OnInit {
  currentTab = 'dashboard';
  adminName = 'Admin';
  adminRole = 'Administrador';
  currentDate = '';
  searchQuery = '';

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

  // Guards list (Vigilante tab)
  guards: Guard[] = [
    { name: 'Marcos Souza', shift: 'Noturno A (18:00 - 06:00)', status: 'Ativo', lastCheckin: '15 min atrás - Quadra Society 1' },
    { name: 'Thiago Alves', shift: 'Noturno B (18:00 - 06:00)', status: 'Ativo', lastCheckin: '5 min atrás - Vestiário Masculino' },
    { name: 'Ronaldo Azevedo', shift: 'Noturno A (18:00 - 06:00)', status: 'Ativo', lastCheckin: '22 min atrás - Portaria Principal' },
    { name: 'Roberto Lima', shift: 'Diurno B (06:00 - 18:00)', status: 'De Folga', lastCheckin: 'Ontem - Portaria Principal' }
  ];

  constructor(private router: Router, private authService: AuthService) {}

  ngOnInit(): void {
    // Session check (guard already protects the route)
    const session = this.authService.getSession();
    if (!session) {
      this.router.navigate(['/login']);
      return;
    }

    // Populate admin info from JWT session
    this.adminName = session.nome || 'Admin';
    this.adminRole = session.role === 'Admin' ? 'Administrador' : session.role;

    // Set dynamic date in Portuguese
    const options: Intl.DateTimeFormatOptions = {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    };
    const today = new Date();
    const rawDate = today.toLocaleDateString('pt-BR', options);
    this.currentDate = rawDate.charAt(0).toUpperCase() + rawDate.slice(1);
  }

  switchTab(tab: string): void {
    this.currentTab = tab;
  }

  logout(): void {
    this.authService.logout();
  }

  triggerAction(actionName: string): void {
    alert(`Ação executada: ${actionName} (MOCK)`);
  }

  registerGuardIncident(): void {
    const desc = prompt('Descreva a ocorrência do vigilante:');
    if (desc) {
      alert('Ocorrência de vigilância registrada com sucesso!');
    }
  }

  addNewGuard(): void {
    const name = prompt('Digite o nome do novo vigilante:');
    if (name) {
      const shift = prompt('Digite o turno (Ex: Noturno A):') || 'Geral';
      this.guards.unshift({
        name,
        shift,
        status: 'Ativo',
        lastCheckin: 'Recém cadastrado - Aguardando check-in'
      });
      alert(`Vigilante ${name} adicionado com sucesso!`);
    }
  }
}
