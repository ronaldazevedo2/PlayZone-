import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { catchError, of } from 'rxjs';
import { SecretariaService, SecretariaListaDto } from '../../services/secretaria.service';
import { ReservaService, ReservaDto } from '../../services/reserva.service';
import { QuadraService } from '../../services/quadra.service';

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
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css'
})
export class DashboardComponent implements OnInit {
  // Stats
  reservasHojeCount = 0;
  quadrasOcupadasCount = 0;
  quadrasTotalCount = 0;
  mensagensPendentesCount = 0;
  avaliacaoMedia = 4.8;

  // Bookings list real
  bookings: Booking[] = [];
  carregandoReservas = false;

  // Messages list
  messages: Message[] = [];

  secretarias: SecretariaListaDto[] = [];
  carregando = false;
  erro = '';

  constructor(
    private secretariaService: SecretariaService,
    private reservaService: ReservaService,
    private quadraService: QuadraService,
    private router: Router
  ) { }

  ngOnInit(): void {
    this.carregarSecretarias();
    this.carregarReservasReais();
    this.carregarQuadrasStats();
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

  carregarQuadrasStats(): void {
    this.quadraService.listar(1, 100).pipe(catchError(() => of(null))).subscribe(res => {
      if (res && res.ok && res.dados && res.dados.itens) {
        const itens = res.dados.itens;
        this.quadrasTotalCount = itens.length;
        this.quadrasOcupadasCount = itens.filter((q: any) => q.status === 'Ativa').length;
      }
    });
  }

  carregarReservasReais(): void {
    this.carregandoReservas = true;

    this.reservaService.listar(1, 100).pipe(
      catchError(() => of(null))
    ).subscribe({
      next: (res: any) => {
        this.carregandoReservas = false;
        if (res && res.ok && res.dados && res.dados.itens) {
          const itens: any[] = res.dados.itens;
          const hojeStr = new Date().toISOString().split('T')[0];

          this.reservasHojeCount = itens.filter((r: any) => {
            const dataRes = r.dataAgendada || r.data || '';
            return dataRes.split('T')[0] === hojeStr;
          }).length;

          this.bookings = itens.slice(0, 5).map((item: any) => {
            const horario = item.horarioAgendado || item.horario || '18:00';
            const modalidade = item.modalidade || 'Futebol Society';
            return {
              time: horario,
              court: item.nomeQuadra || item.quadraNome || 'Quadra',
              client: item.nomeUsuario || item.usuarioNome || 'Cliente',
              type: modalidade,
              typeClass: this.getTypeClass(modalidade)
            };
          });
        } else {
          this.bookings = [];
        }
      },
      error: () => {
        this.carregandoReservas = false;
        this.bookings = [];
      }
    });
  }

  private getTypeClass(modalidade: string): string {
    const mod = (modalidade || '').toLowerCase();
    if (mod.includes('beach') || mod.includes('tennis')) return 'badge-tennis';
    if (mod.includes('futsal')) return 'badge-futsal';
    if (mod.includes('vôlei') || mod.includes('volei')) return 'badge-volei';
    return 'badge-society';
  }

  navTo(path: string): void {
    this.router.navigate([path]);
  }

  triggerAction(actionName: string): void {
    if (actionName === 'Nova Quadra') {
      this.router.navigate(['/quadras/nova']);
    } else if (actionName === 'Nova Reserva') {
      this.router.navigate(['/reservas/nova']);
    } else if (actionName === 'Novo Usuário') {
      this.router.navigate(['/usuarios/novo']);
    } else if (actionName === 'Novo Vigilante') {
      this.router.navigate(['/vigilante/novo']);
    } else if (actionName === 'Ver todas as reservas') {
      this.router.navigate(['/reservas']);
    } else {
      alert(`Ação executada: ${actionName}`);
    }
  }
}
