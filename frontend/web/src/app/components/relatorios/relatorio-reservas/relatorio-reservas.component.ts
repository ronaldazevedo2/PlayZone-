import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { ReservaService, ReservaDto } from '../../../services/reserva.service';
import { QuadraService } from '../../../services/quadra.service';
import { ExportService } from '../../../services/export.service';

export interface ColunaVisivelReserva {
  key: keyof ReservaDto | 'dataFormatada';
  label: string;
  ativo: boolean;
}

@Component({
  selector: 'app-relatorio-reservas',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './relatorio-reservas.component.html',
  styleUrl: './relatorio-reservas.component.css'
})
export class RelatorioReservasComponent implements OnInit {
  carregando = false;
  erro = '';

  // --- Filtros ERP para Reservas ---
  dataInicial = '';
  dataFinal = '';
  filtroStatus: 'Todos' | 'Ativa' | 'Cancelada' | 'Finalizada' = 'Todos';
  filtroModalidade = 'Todas';
  termoBusca = '';

  ordenarPor: 'nomeQuadra' | 'nomeUsuario' | 'modalidade' | 'data' | 'status' = 'data';
  ordem: 'asc' | 'desc' = 'asc';

  opcoesModalidades: string[] = ['Todas', 'Futebol', 'Futsal', 'Basquete', 'Vôlei', 'Tênis', 'Beach Tennis', 'Society'];

  // --- Seleção de Colunas / Informações a Mostrar ---
  colunas: ColunaVisivelReserva[] = [
    { key: 'nomeQuadra', label: 'Quadra', ativo: true },
    { key: 'nomeUsuario', label: 'Usuário', ativo: true },
    { key: 'modalidade', label: 'Modalidade', ativo: true },
    { key: 'dataFormatada', label: 'Data', ativo: true },
    { key: 'horario', label: 'Horário', ativo: true },
    { key: 'status', label: 'Status', ativo: true },
    { key: 'observacoes', label: 'Observações', ativo: false }
  ];

  // --- Resultados e Modal ---
  reservasOriginais: ReservaDto[] = [];
  reservasFiltradas: ReservaDto[] = [];
  exibirModalPreview = false;
  dataGeracaoStr = '';

  constructor(
    private reservaService: ReservaService,
    private quadraService: QuadraService,
    private exportService: ExportService
  ) {}

  ngOnInit(): void {
    const hoje = new Date();
    const trintaDiasAtras = new Date();
    trintaDiasAtras.setDate(hoje.getDate() - 30);

    this.dataFinal = this.formatarDataParaInput(hoje);
    this.dataInicial = this.formatarDataParaInput(trintaDiasAtras);

    this.carregarDadosBase();
  }

  private formatarDataParaInput(d: Date): string {
    const ano = d.getFullYear();
    const mes = String(d.getMonth() + 1).padStart(2, '0');
    const dia = String(d.getDate()).padStart(2, '0');
    return `${ano}-${mes}-${dia}`;
  }

  carregarDadosBase(): void {
    this.carregando = true;
    this.erro = '';

    this.reservaService.listar(1, 200).subscribe({
      next: (res: any) => {
        this.carregando = false;
        const dados = res?.dados?.itens ?? res?.dados ?? res ?? [];
        if (Array.isArray(dados) && dados.length > 0) {
          this.reservasOriginais = dados;
        } else {
          this.carregarReservasLocais();
        }
      },
      error: (err) => {
        console.warn('[RelatorioReservas] Erro na API, carregando reservas locais:', err);
        this.carregarReservasLocais();
      }
    });
  }

  private carregarReservasLocais(): void {
    this.carregando = false;
    try {
      const raw = localStorage.getItem('playzone_reservas_cadastradas');
      this.reservasOriginais = raw ? JSON.parse(raw) : [];
    } catch {
      this.reservasOriginais = [];
    }
  }

  limparFiltros(): void {
    const hoje = new Date();
    const trintaDiasAtras = new Date();
    trintaDiasAtras.setDate(hoje.getDate() - 30);

    this.dataFinal = this.formatarDataParaInput(hoje);
    this.dataInicial = this.formatarDataParaInput(trintaDiasAtras);
    this.filtroStatus = 'Todos';
    this.filtroModalidade = 'Todas';
    this.termoBusca = '';
    this.ordenarPor = 'data';
    this.ordem = 'asc';

    this.colunas.forEach(c => {
      if (c.key === 'observacoes') {
        c.ativo = false;
      } else {
        c.ativo = true;
      }
    });
  }

  gerarEVisualizarRelatorio(): void {
    this.aplicarFiltros();
    const now = new Date();
    this.dataGeracaoStr = now.toLocaleDateString('pt-BR') + ' às ' + now.toLocaleTimeString('pt-BR');
    this.exibirModalPreview = true;
  }

  fecharModalPreview(): void {
    this.exibirModalPreview = false;
  }

  private aplicarFiltros(): void {
    let resultado = [...this.reservasOriginais];

    // 1. Filtro por Busca / Termo
    if (this.termoBusca && this.termoBusca.trim() !== '') {
      const termo = this.termoBusca.toLowerCase().trim();
      resultado = resultado.filter(r =>
        (r.nomeQuadra && r.nomeQuadra.toLowerCase().includes(termo)) ||
        (r.nomeUsuario && r.nomeUsuario.toLowerCase().includes(termo)) ||
        (r.modalidade && r.modalidade.toLowerCase().includes(termo)) ||
        (r.horario && r.horario.toLowerCase().includes(termo)) ||
        (r.observacoes && r.observacoes.toLowerCase().includes(termo))
      );
    }

    // 2. Filtro por Status
    if (this.filtroStatus !== 'Todos') {
      resultado = resultado.filter(r =>
        r.status && r.status.toLowerCase() === this.filtroStatus.toLowerCase()
      );
    }

    // 3. Filtro por Modalidade
    if (this.filtroModalidade !== 'Todas') {
      resultado = resultado.filter(r =>
        r.modalidade && r.modalidade.toLowerCase() === this.filtroModalidade.toLowerCase()
      );
    }

    // 4. Filtro por Período de Data
    if (this.dataInicial) {
      resultado = resultado.filter(r => {
        if (!r.data) return true;
        return r.data >= this.dataInicial;
      });
    }

    if (this.dataFinal) {
      resultado = resultado.filter(r => {
        if (!r.data) return true;
        return r.data <= this.dataFinal;
      });
    }

    // 5. Ordenação
    resultado.sort((a, b) => {
      let valA: any = (a as any)[this.ordenarPor] ?? '';
      let valB: any = (b as any)[this.ordenarPor] ?? '';

      if (typeof valA === 'string') valA = valA.toLowerCase();
      if (typeof valB === 'string') valB = valB.toLowerCase();

      if (valA < valB) return this.ordem === 'asc' ? -1 : 1;
      if (valA > valB) return this.ordem === 'asc' ? 1 : -1;
      return 0;
    });

    this.reservasFiltradas = resultado;
  }

  getColunasAtivas(): ColunaVisivelReserva[] {
    return this.colunas.filter(c => c.ativo);
  }

  getValorCampo(reserva: ReservaDto, key: string): string {
    if (key === 'dataFormatada') {
      if (reserva.data) {
        try {
          const d = new Date(reserva.data);
          return !isNaN(d.getTime()) ? d.toLocaleDateString('pt-BR') : reserva.data;
        } catch {
          return reserva.data;
        }
      }
      return '-';
    }
    const val = (reserva as any)[key];
    return val !== undefined && val !== null && val !== '' ? String(val) : '-';
  }

  // --- Exportações ---
  imprimir(): void {
    this.exportService.imprimirElemento('relatorio-reservas-preview-printable');
  }

  exportarPdf(): void {
    this.exportService.exportarReservasPdf(this.reservasFiltradas, this.filtroStatus, this.termoBusca);
  }
}
