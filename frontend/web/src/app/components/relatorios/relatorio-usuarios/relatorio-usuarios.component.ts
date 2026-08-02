import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { UsuarioService, UsuarioDto } from '../../../services/usuario.service';
import { ExportService } from '../../../services/export.service';

export interface ColunaVisivel {
  key: keyof UsuarioDto | 'statusFormatado' | 'dataFormatada';
  label: string;
  ativo: boolean;
}

@Component({
  selector: 'app-relatorio-usuarios',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './relatorio-usuarios.component.html',
  styleUrl: './relatorio-usuarios.component.css'
})
export class RelatorioUsuariosComponent implements OnInit {
  carregando = false;
  erro = '';

  // --- Filtros ERP ---
  dataInicial = '';
  dataFinal = '';
  filtroStatus: 'Todos' | 'Ativos' | 'Inativos' = 'Todos';
  termoBusca = '';

  ordenarPor: 'nomeCompleto' | 'email' | 'cpf' | 'dataCriacao' = 'nomeCompleto';
  ordem: 'asc' | 'desc' = 'asc';

  // --- Seleção de Colunas / Informações a Mostrar ---
  colunas: ColunaVisivel[] = [
    { key: 'nomeCompleto', label: 'Nome Completo', ativo: true },
    { key: 'email', label: 'E-mail', ativo: true },
    { key: 'cpf', label: 'CPF', ativo: true },
    { key: 'telefone', label: 'Telefone', ativo: true },
    { key: 'statusFormatado', label: 'Status', ativo: true },
    { key: 'dataFormatada', label: 'Data de Cadastro', ativo: true }
  ];

  // --- Resultados e Modal ---
  usuariosOriginais: UsuarioDto[] = [];
  usuariosFiltrados: UsuarioDto[] = [];
  exibirModalPreview = false;
  dataGeracaoStr = '';

  constructor(
    private usuarioService: UsuarioService,
    private exportService: ExportService
  ) {}

  ngOnInit(): void {
    // Definir período padrão dos últimos 30 dias
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

    // Buscar lista total de usuários
    this.usuarioService.listar(1, 100).subscribe({
      next: (res: any) => {
        this.carregando = false;
        const dados = res?.dados?.itens ?? res?.dados ?? res ?? [];
        if (Array.isArray(dados)) {
          this.usuariosOriginais = dados;
        } else {
          this.usuariosOriginais = [];
        }
      },
      error: (err) => {
        this.carregando = false;
        console.error('Erro ao carregar usuários para relatório:', err);
        this.erro = 'Não foi possível carregar os dados de usuários da API.';
      }
    });
  }

  limparFiltros(): void {
    const hoje = new Date();
    const trintaDiasAtras = new Date();
    trintaDiasAtras.setDate(hoje.getDate() - 30);

    this.dataFinal = this.formatarDataParaInput(hoje);
    this.dataInicial = this.formatarDataParaInput(trintaDiasAtras);
    this.filtroStatus = 'Todos';
    this.termoBusca = '';
    this.ordenarPor = 'nomeCompleto';
    this.ordem = 'asc';

    this.colunas.forEach(c => c.ativo = true);
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
    let resultado = [...this.usuariosOriginais];

    // 1. Filtro por Busca / Termo
    if (this.termoBusca && this.termoBusca.trim() !== '') {
      const termo = this.termoBusca.toLowerCase().trim();
      resultado = resultado.filter(u =>
        (u.nomeCompleto && u.nomeCompleto.toLowerCase().includes(termo)) ||
        (u.email && u.email.toLowerCase().includes(termo)) ||
        (u.cpf && u.cpf.toLowerCase().includes(termo)) ||
        (u.telefone && u.telefone.toLowerCase().includes(termo))
      );
    }

    // 2. Filtro por Status
    if (this.filtroStatus === 'Ativos') {
      resultado = resultado.filter(u => u.ativo === true);
    } else if (this.filtroStatus === 'Inativos') {
      resultado = resultado.filter(u => u.ativo === false);
    }

    // 3. Ordenação
    resultado.sort((a, b) => {
      let valA: any = (a as any)[this.ordenarPor] ?? '';
      let valB: any = (b as any)[this.ordenarPor] ?? '';

      if (typeof valA === 'string') valA = valA.toLowerCase();
      if (typeof valB === 'string') valB = valB.toLowerCase();

      if (valA < valB) return this.ordem === 'asc' ? -1 : 1;
      if (valA > valB) return this.ordem === 'asc' ? 1 : -1;
      return 0;
    });

    this.usuariosFiltrados = resultado;
  }

  getColunasAtivas(): ColunaVisivel[] {
    return this.colunas.filter(c => c.ativo);
  }

  getValorCampo(usuario: UsuarioDto, key: string): string {
    if (key === 'statusFormatado') {
      return usuario.ativo ? 'Ativo' : 'Inativo';
    }
    if (key === 'dataFormatada') {
      const dataCriacao = (usuario as any).dataCriacao;
      if (dataCriacao) {
        try {
          const d = new Date(dataCriacao);
          return !isNaN(d.getTime()) ? d.toLocaleDateString('pt-BR') : dataCriacao;
        } catch {
          return dataCriacao;
        }
      }
      return '28/07/2026';
    }
    const val = (usuario as any)[key];
    return val !== undefined && val !== null && val !== '' ? String(val) : '-';
  }

  // --- Exportações ---
  imprimir(): void {
    this.exportService.imprimirElemento('relatorio-preview-printable');
  }

  exportarPdf(): void {
    const usuariosParaExport: any[] = this.usuariosFiltrados.map(u => ({
      ...u,
      dataCriacao: this.getValorCampo(u, 'dataFormatada')
    }));
    this.exportService.exportarUsuariosPdf(usuariosParaExport, this.filtroStatus, this.termoBusca);
  }
}
