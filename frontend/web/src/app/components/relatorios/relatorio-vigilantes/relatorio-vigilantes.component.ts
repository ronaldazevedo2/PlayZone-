import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from '../../../services/auth.service';
import { QuadraService } from '../../../services/quadra.service';
import { ExportService } from '../../../services/export.service';
import { Vigilante } from '../../vigilante/vigilante.component';

export interface ColunaVisivelVigilante {
  key: keyof Vigilante | 'statusFormatado' | 'dataFormatada';
  label: string;
  ativo: boolean;
}

@Component({
  selector: 'app-relatorio-vigilantes',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './relatorio-vigilantes.component.html',
  styleUrl: './relatorio-vigilantes.component.css'
})
export class RelatorioVigilantesComponent implements OnInit {
  carregando = false;
  erro = '';

  // --- Filtros ERP para Vigilantes ---
  filtroStatus: 'Todos' | 'Ativos' | 'Inativos' = 'Todos';
  filtroArena = 'Todas';
  termoBusca = '';

  ordenarPor: 'nomeCompleto' | 'matricula' | 'arena' | 'dataNascimento' | 'ativo' = 'nomeCompleto';
  ordem: 'asc' | 'desc' = 'asc';

  opcoesArenas: string[] = ['Todas'];

  // --- Seleção de Colunas / Informações a Mostrar ---
  colunas: ColunaVisivelVigilante[] = [
    { key: 'nomeCompleto', label: 'Nome Completo', ativo: true },
    { key: 'matricula', label: 'Matrícula', ativo: true },
    { key: 'cpf', label: 'CPF', ativo: true },
    { key: 'email', label: 'E-mail', ativo: true },
    { key: 'telefone', label: 'Telefone', ativo: true },
    { key: 'arena', label: 'Arena / Quadra', ativo: true },
    { key: 'statusFormatado', label: 'Status', ativo: true },
    { key: 'dataFormatada', label: 'Data de Nascimento', ativo: false }
  ];

  // --- Resultados e Modal ---
  vigilantesOriginais: Vigilante[] = [];
  vigilantesFiltrados: Vigilante[] = [];
  exibirModalPreview = false;
  dataGeracaoStr = '';

  private readonly API_URL = 'https://localhost:7200/api/Vigilantes';

  constructor(
    private http: HttpClient,
    private authService: AuthService,
    private quadraService: QuadraService,
    private exportService: ExportService
  ) {}

  ngOnInit(): void {
    this.carregarArenas();
    this.carregarDadosBase();
  }

  private getHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    const headersConfig: any = { 'Accept': 'application/json' };
    if (token) {
      headersConfig['Authorization'] = `Bearer ${token}`;
    }
    return new HttpHeaders(headersConfig);
  }

  carregarArenas(): void {
    this.quadraService.listar(1, 100).subscribe({
      next: (res) => {
        const itens = res.dados?.itens ?? [];
        const nomesQuadras = itens.map(q => q.nome).filter(Boolean);
        this.opcoesArenas = ['Todas', ...Array.from(new Set(nomesQuadras))];
      },
      error: () => {
        this.opcoesArenas = ['Todas'];
      }
    });
  }

  carregarDadosBase(): void {
    this.carregando = true;
    this.erro = '';

    this.http.get<any>(`${this.API_URL}?pagina=1&tamanhoPagina=200`, { headers: this.getHeaders() }).subscribe({
      next: (res) => {
        this.carregando = false;
        const dados = res?.dados?.itens ?? res?.dados ?? (Array.isArray(res) ? res : []);
        if (Array.isArray(dados) && dados.length > 0) {
          this.vigilantesOriginais = dados;
        } else {
          this.carregarVigilantesLocais();
        }
      },
      error: (err) => {
        console.warn('[RelatorioVigilantes] Erro na API, buscando dados locais:', err);
        this.carregarVigilantesLocais();
      }
    });
  }

  private carregarVigilantesLocais(): void {
    this.carregando = false;
    try {
      const raw = localStorage.getItem('playzone_vigilantes_cadastrados');
      this.vigilantesOriginais = raw ? JSON.parse(raw) : [];
    } catch {
      this.vigilantesOriginais = [];
    }
  }

  limparFiltros(): void {
    this.filtroStatus = 'Todos';
    this.filtroArena = 'Todas';
    this.termoBusca = '';
    this.ordenarPor = 'nomeCompleto';
    this.ordem = 'asc';

    this.colunas.forEach(c => {
      if (c.key === 'dataFormatada') {
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
    let resultado = [...this.vigilantesOriginais];

    // 1. Filtro por Busca / Termo
    if (this.termoBusca && this.termoBusca.trim() !== '') {
      const termo = this.termoBusca.toLowerCase().trim();
      resultado = resultado.filter(v =>
        (v.nomeCompleto && v.nomeCompleto.toLowerCase().includes(termo)) ||
        (v.matricula && v.matricula.toLowerCase().includes(termo)) ||
        (v.email && v.email.toLowerCase().includes(termo)) ||
        (v.cpf && v.cpf.toLowerCase().includes(termo)) ||
        (v.telefone && v.telefone.toLowerCase().includes(termo)) ||
        (v.arena && v.arena.toLowerCase().includes(termo))
      );
    }

    // 2. Filtro por Status
    if (this.filtroStatus === 'Ativos') {
      resultado = resultado.filter(v => v.ativo === true);
    } else if (this.filtroStatus === 'Inativos') {
      resultado = resultado.filter(v => v.ativo === false);
    }

    // 3. Filtro por Arena
    if (this.filtroArena !== 'Todas') {
      resultado = resultado.filter(v => v.arena && v.arena.toLowerCase() === this.filtroArena.toLowerCase());
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

    this.vigilantesFiltrados = resultado;
  }

  getColunasAtivas(): ColunaVisivelVigilante[] {
    return this.colunas.filter(c => c.ativo);
  }

  getValorCampo(v: Vigilante, key: string): string {
    if (key === 'statusFormatado') {
      return v.ativo ? 'Ativo' : 'Inativo';
    }
    if (key === 'dataFormatada') {
      if (v.dataNascimento) {
        try {
          const d = new Date(v.dataNascimento);
          return !isNaN(d.getTime()) ? d.toLocaleDateString('pt-BR') : v.dataNascimento;
        } catch {
          return v.dataNascimento;
        }
      }
      return '-';
    }
    const val = (v as any)[key];
    return val !== undefined && val !== null && val !== '' ? String(val) : '-';
  }

  // --- Exportações ---
  imprimir(): void {
    this.exportService.imprimirElemento('relatorio-vigilantes-preview-printable');
  }

  exportarPdf(): void {
    this.exportService.exportarVigilantesPdf(this.vigilantesFiltrados, this.filtroStatus, this.termoBusca);
  }
}
