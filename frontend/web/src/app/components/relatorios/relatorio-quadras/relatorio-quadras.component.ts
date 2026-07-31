import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { QuadraService, ReservaQuadraDto } from '../../../services/quadra.service';
import { ExportService } from '../../../services/export.service';

export interface ColunaVisivelQuadra {
  key: keyof ReservaQuadraDto | 'capacidadeFormatada';
  label: string;
  ativo: boolean;
}

@Component({
  selector: 'app-relatorio-quadras',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './relatorio-quadras.component.html',
  styleUrl: './relatorio-quadras.component.css'
})
export class RelatorioQuadrasComponent implements OnInit {
  carregando = false;
  erro = '';

  // --- Filtros ERP para Quadras ---
  filtroStatus: 'Todos' | 'Ativa' | 'Manutenção' | 'Indisponível' = 'Todos';
  filtroModalidade = 'Todas';
  termoBusca = '';

  ordenarPor: 'nome' | 'modalidade' | 'capacidade' | 'status' = 'nome';
  ordem: 'asc' | 'desc' = 'asc';

  opcoesModalidades: string[] = ['Todas', 'Futebol', 'Futsal', 'Basquete', 'Vôlei', 'Tênis', 'Beach Tennis', 'Soc society'];

  // --- Seleção de Colunas / Informações a Mostrar ---
  colunas: ColunaVisivelQuadra[] = [
    { key: 'nome', label: 'Nome da Quadra', ativo: true },
    { key: 'modalidade', label: 'Modalidade', ativo: true },
    { key: 'localizacao', label: 'Localização', ativo: true },
    { key: 'capacidadeFormatada', label: 'Capacidade', ativo: true },
    { key: 'status', label: 'Status', ativo: true },
    { key: 'descricao', label: 'Descrição', ativo: false }
  ];

  // --- Resultados e Modal ---
  quadrasOriginais: ReservaQuadraDto[] = [];
  quadrasFiltradas: ReservaQuadraDto[] = [];
  exibirModalPreview = false;
  dataGeracaoStr = '';

  constructor(
    private quadraService: QuadraService,
    private exportService: ExportService
  ) {}

  ngOnInit(): void {
    this.carregarDadosBase();
  }

  carregarDadosBase(): void {
    this.carregando = true;
    this.erro = '';

    this.quadraService.listar(1, 100).subscribe({
      next: (res: any) => {
        this.carregando = false;
        const dados = res?.dados?.itens ?? res?.dados ?? res ?? [];
        if (Array.isArray(dados)) {
          this.quadrasOriginais = dados;
        } else {
          this.quadrasOriginais = [];
        }
      },
      error: (err) => {
        this.carregando = false;
        console.error('Erro ao carregar quadras para relatório:', err);
        this.erro = 'Não foi possível carregar os dados de quadras da API.';
      }
    });
  }

  limparFiltros(): void {
    this.filtroStatus = 'Todos';
    this.filtroModalidade = 'Todas';
    this.termoBusca = '';
    this.ordenarPor = 'nome';
    this.ordem = 'asc';

    this.colunas.forEach(c => {
      if (c.key === 'descricao') {
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
    let resultado = [...this.quadrasOriginais];

    // 1. Filtro por Busca / Termo
    if (this.termoBusca && this.termoBusca.trim() !== '') {
      const termo = this.termoBusca.toLowerCase().trim();
      resultado = resultado.filter(q =>
        (q.nome && q.nome.toLowerCase().includes(termo)) ||
        (q.modalidade && q.modalidade.toLowerCase().includes(termo)) ||
        (q.localizacao && q.localizacao.toLowerCase().includes(termo)) ||
        (q.descricao && q.descricao.toLowerCase().includes(termo))
      );
    }

    // 2. Filtro por Status
    if (this.filtroStatus !== 'Todos') {
      resultado = resultado.filter(q =>
        q.status && q.status.toLowerCase() === this.filtroStatus.toLowerCase()
      );
    }

    // 3. Filtro por Modalidade
    if (this.filtroModalidade !== 'Todas') {
      resultado = resultado.filter(q =>
        q.modalidade && q.modalidade.toLowerCase() === this.filtroModalidade.toLowerCase()
      );
    }

    // 4. Ordenação
    resultado.sort((a, b) => {
      let valA: any = (a as any)[this.ordenarPor] ?? '';
      let valB: any = (b as any)[this.ordenarPor] ?? '';

      if (typeof valA === 'string') valA = valA.toLowerCase();
      if (typeof valB === 'string') valB = valB.toLowerCase();

      if (valA < valB) return this.ordem === 'asc' ? -1 : 1;
      if (valA > valB) return this.ordem === 'asc' ? 1 : -1;
      return 0;
    });

    this.quadrasFiltradas = resultado;
  }

  getColunasAtivas(): ColunaVisivelQuadra[] {
    return this.colunas.filter(c => c.ativo);
  }

  getValorCampo(quadra: ReservaQuadraDto, key: string): string {
    if (key === 'capacidadeFormatada') {
      return quadra.capacidade ? `${quadra.capacidade} pessoas` : '-';
    }
    const val = (quadra as any)[key];
    return val !== undefined && val !== null && val !== '' ? String(val) : '-';
  }

  // --- Exportações ---
  imprimir(): void {
    this.exportService.imprimirElemento('relatorio-quadras-preview-printable');
  }

  exportarPdf(): void {
    this.exportService.exportarQuadrasPdf(this.quadrasFiltradas, this.filtroStatus, this.termoBusca);
  }

  exportarWord(): void {
    const colunasAtivas = this.getColunasAtivas().map(c => ({ key: c.key, label: c.label }));
    const dadosMapeados = this.quadrasFiltradas.map(q => {
      const row: any = {};
      colunasAtivas.forEach(c => {
        row[c.key] = this.getValorCampo(q, c.key);
      });
      return row;
    });
    this.exportService.exportarUsuariosWord(dadosMapeados, colunasAtivas, 'relatorio_quadras');
  }
}
