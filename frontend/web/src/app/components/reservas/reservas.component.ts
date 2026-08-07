import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { forkJoin, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { QuadraService, ReservaQuadraDto } from '../../services/quadra.service';
import { ReservaService, ReservaDto } from '../../services/reserva.service';
import { RespostaApi } from '../../wrappers/api-response.wrapper';
import { ResultadoPaginado } from '../../services/secretaria.service';

@Component({
  selector: 'app-reservas',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './reservas.component.html',
  styleUrl: './reservas.component.css'
})
export class ReservasComponent implements OnInit {
  quadras: ReservaQuadraDto[] = [];
  quadrasFiltradas: ReservaQuadraDto[] = [];
  todasReservas: ReservaDto[] = [];

  isLoading = false;

  // Filtros da listagem de quadras
  termoBuscaQuadra = '';
  filtroModalidade = 'Todas';
  opcoesModalidades: string[] = ['Todas', 'Futebol Society', 'Futsal', 'Basquete', 'Vôlei', 'Beach Tennis'];

  constructor(
    private quadraService: QuadraService,
    private reservaService: ReservaService,
    private router: Router
  ) { }

  ngOnInit(): void {
    this.carregarDados();
  }

  // ────────────────────────────────────────
  //   DADOS INICIAIS (Quadras + Indicadores)
  // ────────────────────────────────────────
  carregarDados(): void {
    this.isLoading = true;

    forkJoin({
      quadrasRes: this.quadraService.listar(1, 100).pipe(catchError(() => of(null))),
      reservasRes: this.reservaService.listar(1, 500).pipe(catchError(() => of(null)))
    }).subscribe({
      next: (res: any) => {
        this.isLoading = false;

        // Quadras
        if (res.quadrasRes && res.quadrasRes.ok && res.quadrasRes.dados && res.quadrasRes.dados.itens && res.quadrasRes.dados.itens.length > 0) {
          this.quadras = res.quadrasRes.dados.itens;
        } else {
          this.quadras = [];
        }

        // Reservas para os cards de estatísticas (Hoje, Semana, Mês)
        if (res.reservasRes && res.reservasRes.ok && res.reservasRes.dados && res.reservasRes.dados.itens) {
          const itens = res.reservasRes.dados.itens;
          this.todasReservas = itens.map((item: any) => ({
            id: item.reservasId || item.reservaId || item.id || '',
            quadraId: item.quadraId || item.QuadraId || '',
            nomeQuadra: item.nomeQuadra || 'Quadra',
            modalidade: item.modalidade || '',
            usuarioId: item.usuarioId || item.usuariosId || '',
            nomeUsuario: item.nomeUsuario || '',
            data: item.dataAgendada || item.data || '',
            horario: item.horarioAgendado || item.horario || '',
            status: item.status || 'Ativa'
          }));
        }

        this.aplicarFiltros();
      },
      error: () => {
        this.isLoading = false;
        this.quadras = [];
        this.aplicarFiltros();
      }
    });
  }

  // ────────────────────────────────────────
  //   MÉTRICAS DAS QUADRAS
  // ────────────────────────────────────────
  getReservasHojeCount(): number {
    const hojeStr = new Date().toISOString().split('T')[0];
    return this.todasReservas.filter(r => r.data && r.data.split('T')[0] === hojeStr).length;
  }

  getReservasSemanaCount(): number {
    const hoje = new Date();
    const limite = new Date();
    limite.setDate(hoje.getDate() - 7);
    return this.todasReservas.filter(r => {
      if (!r.data) return false;
      const dt = new Date(r.data);
      return dt >= limite && dt <= hoje;
    }).length;
  }

  getReservasMesCount(): number {
    const hoje = new Date();
    return this.todasReservas.filter(r => {
      if (!r.data) return false;
      const dt = new Date(r.data);
      return dt.getMonth() === hoje.getMonth() && dt.getFullYear() === hoje.getFullYear();
    }).length;
  }

  // ────────────────────────────────────────
  //   FILTROS DE QUADRAS
  // ────────────────────────────────────────
  aplicarFiltros(): void {
    let r = [...this.quadras];
    if (this.termoBuscaQuadra.trim()) {
      const t = this.termoBuscaQuadra.toLowerCase().trim();
      r = r.filter(q => q.nome.toLowerCase().includes(t));
    }
    if (this.filtroModalidade !== 'Todas') {
      r = r.filter(q => q.modalidade.toLowerCase() === this.filtroModalidade.toLowerCase());
    }
    this.quadrasFiltradas = r;
  }

  // Navega para a rota dedicada de visualização de reservas por quadra
  verReservasDaQuadra(quadra: ReservaQuadraDto): void {
    this.router.navigate(['/reservas/quadra', quadra.id]);
  }
}
