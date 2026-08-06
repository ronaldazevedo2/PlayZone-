import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { QuadraService, CriarQuadraCommand } from '../../../services/quadra.service';
import { DataHorarioReservaService, DataHorarioReservaDto, CriarDataHorarioReservaCommand } from '../../../services/data-horario-reserva.service';
import { forkJoin, of } from 'rxjs';
import { catchError } from 'rxjs/operators';


@Component({
  selector: 'app-quadra-form',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './quadra-form.component.html',
  styleUrl: './quadra-form.component.css'
})
export class QuadraFormComponent implements OnInit {
  quadraEditandoId: string | null = null;
  salvando = false;
  carregando = false;
  erro = '';
  successMessage = '';

  // Track schedules already saved in the API for the selected date
  horariosSalvosApi: Set<string> = new Set();
  // Track all saved schedule keys ("data|horario") from the API to avoid duplicates
  horariosSalvosGlobal: Map<string, Set<string>> = new Map();

  // Estado do Formulário
  novaQuadra: CriarQuadraCommand = {
    nome: '',
    descricao: '',
    capacidade: 12,
    localizacao: '',
    modalidade: 'Futebol Society',
    imagemUrl: '',
    status: 'Ativa',
    dataLiberacao: ''
  };

  opcoesModalidades = [
    'Futebol Society',
    'Beach Tennis',
    'Futsal',
    'Vôlei de Areia'
  ];

  // --- Estrutura e Estado da Disponibilidade Semanal Por Dia da Semana ---
  nomesMeses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

  mesAlvo = '';
  opcoesMesesAlvo: Array<{ valor: string; rotulo: string }> = [];

  diasSemana = [
    { id: 1, nome: 'Segunda-feira', sigla: 'SEG', rotuloCurto: 'Segunda' },
    { id: 2, nome: 'Terça-feira', sigla: 'TER', rotuloCurto: 'Terça' },
    { id: 3, nome: 'Quarta-feira', sigla: 'QUA', rotuloCurto: 'Quarta' },
    { id: 4, nome: 'Quinta-feira', sigla: 'QUI', rotuloCurto: 'Quinta' },
    { id: 5, nome: 'Sexta-feira', sigla: 'SEX', rotuloCurto: 'Sexta' },
    { id: 6, nome: 'Sábado', sigla: 'SÁB', rotuloCurto: 'Sábado' },
    { id: 0, nome: 'Domingo', sigla: 'DOM', rotuloCurto: 'Domingo' }
  ];

  diaSemanaAtivo = 1; // Padrão: Segunda-feira

  slotsHorariosDisponiveis = [
    '08:00', '09:00', '10:00', '11:00', '12:00', '13:00',
    '14:00', '15:00', '16:00', '17:00', '18:00', '19:00',
    '20:00', '21:00', '22:00'
  ];

  // Configuração por dia da semana (0 = Dom, 1 = Seg, 2 = Ter, ..., 6 = Sáb)
  horariosPorDiaSemana: { [diaSemanaId: number]: string[] } = {};

  constructor(
    private quadraService: QuadraService,
    private dataHorarioService: DataHorarioReservaService,
    private router: Router,
    private route: ActivatedRoute
  ) { }

  ngOnInit(): void {
    this.gerarOpcoesMesesAlvo();
    this.inicializarHorariosPadraoDiasSemana();

    const idParam = this.route.snapshot.paramMap.get('id');
    if (idParam) {
      this.quadraEditandoId = idParam;
      this.carregarQuadraParaEdicao(idParam);
    } else {
      this.inicializarNovaQuadra();
    }
  }

  gerarOpcoesMesesAlvo(): void {
    const agora = new Date();
    const anoAtual = agora.getFullYear();
    const mesAtual = agora.getMonth(); // 0-11
    this.opcoesMesesAlvo = [];

    for (let i = 0; i < 6; i++) {
      const d = new Date(anoAtual, mesAtual + i, 1);
      const val = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
      const rotulo = `${this.nomesMeses[d.getMonth()]} / ${d.getFullYear()}`;
      this.opcoesMesesAlvo.push({ valor: val, rotulo });
    }

    if (!this.mesAlvo) {
      this.mesAlvo = this.opcoesMesesAlvo[0].valor;
    }
  }

  inicializarHorariosPadraoDiasSemana(): void {
    this.horariosPorDiaSemana = {
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
      6: [],
      0: []
    };
  }

  inicializarNovaQuadra(): void {
    this.novaQuadra = {
      nome: '',
      descricao: '',
      capacidade: 12,
      localizacao: '',
      modalidade: 'Futebol Society',
      imagemUrl: '',
      status: 'Ativa',
      dataLiberacao: ''
    };

    this.gerarOpcoesMesesAlvo();
    this.inicializarHorariosPadraoDiasSemana();
  }

  carregarQuadraParaEdicao(id: string): void {
    this.carregando = true;
    this.quadraService.obterPorId(id).subscribe({
      next: (res: any) => {
        const q = res?.dados || res;
        if (q) {
          this.novaQuadra = {
            nome: q.nome || '',
            descricao: q.descricao || '',
            capacidade: q.capacidade || 12,
            localizacao: q.localizacao || '',
            modalidade: q.modalidade || 'Futebol Society',
            imagemUrl: q.imagemUrl || '',
            status: q.status || 'Ativa',
            dataLiberacao: q.dataLiberacao ? q.dataLiberacao.split('T')[0] : ''
          };
        }
        this.carregando = false;
      },
      error: (err) => {
        console.error('Erro ao buscar dados da quadra:', err);
        this.erro = 'Não foi possível carregar os dados da quadra.';
        this.carregando = false;
      }
    });

    this.gerarOpcoesMesesAlvo();
    this.carregarHorariosDoApi(id);
  }

  private carregarHorariosDoApi(quadraId: string): void {
    this.dataHorarioService.listar(quadraId).subscribe({
      next: (res: any) => {
        this.horariosSalvosGlobal.clear();
        const dados = res?.dados?.itens ?? res?.dados ?? (Array.isArray(res) ? res : []);
        const local = this.obterHorariosLocaisPorQuadra(quadraId);
        const todosDados = [...dados, ...local];
        this.processarEPopularHorarios(quadraId, todosDados);
      },
      error: (err) => {
        console.warn('Erro ao listar horários da API, buscando do localStorage:', err);
        const local = this.obterHorariosLocaisPorQuadra(quadraId);
        this.processarEPopularHorarios(quadraId, local);
      }
    });
  }

  private processarEPopularHorarios(quadraId: string, lista: DataHorarioReservaDto[]): void {
    const diasSemanaMap: { [diaSemanaId: number]: Set<string> } = {
      0: new Set(), 1: new Set(), 2: new Set(), 3: new Set(), 4: new Set(), 5: new Set(), 6: new Set()
    };

    if (Array.isArray(lista) && lista.length > 0) {
      lista.forEach((item: DataHorarioReservaDto) => {
        const dataISO = this.apiDataParaISO(item.data);
        const horarioShort = this.apiHorarioParaShort(item.horario);

        if (dataISO && horarioShort) {
          if (!this.horariosSalvosGlobal.has(dataISO)) {
            this.horariosSalvosGlobal.set(dataISO, new Set());
          }
          this.horariosSalvosGlobal.get(dataISO)!.add(horarioShort);

          const parts = dataISO.split('-');
          if (parts.length === 3) {
            const ano = parseInt(parts[0], 10);
            const mes = parseInt(parts[1], 10);
            const dia = parseInt(parts[2], 10);
            if (!isNaN(ano) && !isNaN(mes) && !isNaN(dia)) {
              const dateObj = new Date(ano, mes - 1, dia);
              const diaSemanaId = dateObj.getDay();
              diasSemanaMap[diaSemanaId].add(horarioShort);
            }
          }
        }
      });
    }

    // Se estiver editando uma quadra, seleciona APENAS os horários que foram cadastrados para aquela quadra
    if (this.quadraEditandoId) {
      for (let d = 0; d <= 6; d++) {
        this.horariosPorDiaSemana[d] = Array.from(diasSemanaMap[d]).sort((a, b) => a.localeCompare(b));
      }
    }
  }

  private obterHorariosLocaisPorQuadra(quadraId: string): DataHorarioReservaDto[] {
    try {
      const raw = localStorage.getItem(`playzone_data_horarios_quadra_${quadraId}`);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  private salvarHorarioLocal(quadraId: string, item: DataHorarioReservaDto): void {
    try {
      const existentes = this.obterHorariosLocaisPorQuadra(quadraId);
      const dataISO = this.apiDataParaISO(item.data);
      const horShort = this.apiHorarioParaShort(item.horario);

      const jaExiste = existentes.some(e => 
        this.apiDataParaISO(e.data) === dataISO && 
        this.apiHorarioParaShort(e.horario) === horShort
      );

      if (!jaExiste) {
        existentes.push(item);
        localStorage.setItem(`playzone_data_horarios_quadra_${quadraId}`, JSON.stringify(existentes));
      }
    } catch (e) {
      console.warn('Erro ao salvar no localStorage:', e);
    }
  }

  private apiDataParaISO(dataApi: string): string {
    if (!dataApi) return '';
    return dataApi.split('T')[0];
  }

  private apiHorarioParaShort(horarioApi: string): string {
    if (!horarioApi) return '';
    const parts = horarioApi.split(':');
    if (parts.length >= 2) {
      return `${parts[0].padStart(2, '0')}:${parts[1].padStart(2, '0')}`;
    }
    return horarioApi;
  }

  // --- Lógica do Configurador por Dia da Semana ---
  selecionarDiaSemana(diaId: number): void {
    this.diaSemanaAtivo = diaId;
  }

  getNomeDiaAtivo(): string {
    const d = this.diasSemana.find(item => item.id === this.diaSemanaAtivo);
    return d ? d.nome : '';
  }

  alternarHorarioSlotDia(slot: string): void {
    if (!this.horariosPorDiaSemana[this.diaSemanaAtivo]) {
      this.horariosPorDiaSemana[this.diaSemanaAtivo] = [];
    }
    const lista = this.horariosPorDiaSemana[this.diaSemanaAtivo];
    const idx = lista.indexOf(slot);
    if (idx > -1) {
      lista.splice(idx, 1);
    } else {
      lista.push(slot);
      lista.sort((a, b) => a.localeCompare(b));
    }
  }

  horarioSlotSelecionadoNoDiaAtivo(slot: string): boolean {
    return this.horariosPorDiaSemana[this.diaSemanaAtivo]?.includes(slot) ?? false;
  }

  getQuantidadeHorariosDia(diaId: number): number {
    return this.horariosPorDiaSemana[diaId]?.length ?? 0;
  }

  selecionarTodosHorariosDiaAtivo(): void {
    this.horariosPorDiaSemana[this.diaSemanaAtivo] = [...this.slotsHorariosDisponiveis];
  }

  limparHorariosDiaAtivo(): void {
    this.horariosPorDiaSemana[this.diaSemanaAtivo] = [];
  }

  copiarParaDiasUteis(): void {
    const origem = [...(this.horariosPorDiaSemana[this.diaSemanaAtivo] ?? [])];
    const diasUteis = [1, 2, 3, 4, 5]; // Seg a Sex
    diasUteis.forEach(id => {
      this.horariosPorDiaSemana[id] = [...origem];
    });
  }

  copiarParaTodosDiasSemana(): void {
    const origem = [...(this.horariosPorDiaSemana[this.diaSemanaAtivo] ?? [])];
    [0, 1, 2, 3, 4, 5, 6].forEach(id => {
      this.horariosPorDiaSemana[id] = [...origem];
    });
  }

  getTotalHorariosMesCalculado(): number {
    if (!this.mesAlvo) return 0;
    const [anoStr, mesStr] = this.mesAlvo.split('-');
    const ano = parseInt(anoStr, 10);
    const mes = parseInt(mesStr, 10);
    if (isNaN(ano) || isNaN(mes)) return 0;

    const totalDias = new Date(ano, mes, 0).getDate();
    let total = 0;

    for (let d = 1; d <= totalDias; d++) {
      const dataObj = new Date(ano, mes - 1, d);
      const diaSemanaId = dataObj.getDay();
      total += (this.horariosPorDiaSemana[diaSemanaId]?.length ?? 0);
    }
    return total;
  }

  abaAtivaForm: 'geral' | 'horarios' = 'geral';

  selecionarAbaForm(aba: 'geral' | 'horarios'): void {
    this.abaAtivaForm = aba;
  }

  // --- Salvamento e Cancelamento com Roteamento ---
  salvarQuadra(): void {
    if (this.abaAtivaForm === 'geral') {
      this.salvarInformacoesGerais();
    } else {
      this.salvarApenasHorarios();
    }
  }

  salvarInformacoesGerais(): void {
    if (this.novaQuadra.nome) {
      this.novaQuadra.nome = this.novaQuadra.nome.toUpperCase();
    }

    if (!this.novaQuadra.nome || !this.novaQuadra.localizacao || !this.novaQuadra.capacidade) {
      this.erro = 'Por favor, preencha todos os campos obrigatórios (*).';
      return;
    }

    if (!this.novaQuadra.imagemUrl) {
      if (this.novaQuadra.modalidade.includes('Beach')) {
        this.novaQuadra.imagemUrl = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="300" height="200" viewBox="0 0 300 200"><rect width="300" height="200" fill="%23d97706"/><rect x="20" y="20" width="260" height="160" fill="%23f59e0b" stroke="%23ffffff" stroke-width="3" rx="8"/><line x1="150" y1="20" x2="150" y2="180" stroke="%23ffffff" stroke-width="3"/><text x="150" y="105" fill="%23ffffff" font-family="sans-serif" font-size="14" font-weight="bold" text-anchor="middle">BEACH TENNIS</text></svg>`;
      } else if (this.novaQuadra.modalidade.includes('Futsal')) {
        this.novaQuadra.imagemUrl = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="300" height="200" viewBox="0 0 300 200"><rect width="300" height="200" fill="%230284c7"/><rect x="20" y="20" width="260" height="160" fill="%230369a1" stroke="%23ffffff" stroke-width="3" rx="8"/><line x1="150" y1="20" x2="150" y2="180" stroke="%23ffffff" stroke-width="3"/><circle cx="150" cy="100" r="30" fill="none" stroke="%23ffffff" stroke-width="3"/><text x="150" y="105" fill="%23ffffff" font-family="sans-serif" font-size="14" font-weight="bold" text-anchor="middle">FUTSAL</text></svg>`;
      } else if (this.novaQuadra.modalidade.includes('Vôlei') || this.novaQuadra.modalidade.includes('Volei')) {
        this.novaQuadra.imagemUrl = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="300" height="200" viewBox="0 0 300 200"><rect width="300" height="200" fill="%23ea580c"/><rect x="20" y="20" width="260" height="160" fill="%23f97316" stroke="%23ffffff" stroke-width="3" rx="8"/><line x1="150" y1="20" x2="150" y2="180" stroke="%23ffffff" stroke-width="3"/><text x="150" y="105" fill="%23ffffff" font-family="sans-serif" font-size="14" font-weight="bold" text-anchor="middle">VÔLEI</text></svg>`;
      } else {
        this.novaQuadra.imagemUrl = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="300" height="200" viewBox="0 0 300 200"><rect width="300" height="200" fill="%2315803d"/><rect x="20" y="20" width="260" height="160" fill="%2316a34a" stroke="%23ffffff" stroke-width="3" rx="8"/><line x1="150" y1="20" x2="150" y2="180" stroke="%23ffffff" stroke-width="3"/><circle cx="150" cy="100" r="35" fill="none" stroke="%23ffffff" stroke-width="3"/><text x="150" y="105" fill="%23ffffff" font-family="sans-serif" font-size="14" font-weight="bold" text-anchor="middle">SOCIETY</text></svg>`;
      }
    }

    if (!this.novaQuadra.descricao) {
      this.novaQuadra.descricao = `Quadra de ${this.novaQuadra.modalidade} para ${this.novaQuadra.capacidade} jogadores.`;
    }

    this.salvando = true;
    this.erro = '';
    this.successMessage = '';

    const commandToSave = {
      ...this.novaQuadra,
      capacidade: Number(this.novaQuadra.capacidade)
    } as any;

    if (this.quadraEditandoId) {
      this.quadraService.atualizar(this.quadraEditandoId, commandToSave).subscribe({
        next: () => {
          this.salvando = false;
          this.successMessage = 'Informações gerais da quadra salvas com sucesso!';
          setTimeout(() => this.router.navigate(['/quadras']), 1500);
        },
        error: (err) => {
          this.tratarErroSalvar(err);
        }
      });
    } else {
      this.quadraService.criar(commandToSave).subscribe({
        next: (res: any) => {
          const newId = res?.dados?.id || res?.id;
          this.salvando = false;
          if (newId) {
            this.quadraEditandoId = newId;
            this.successMessage = 'Quadra criada com sucesso! Agora você pode cadastrar os horários.';
            this.abaAtivaForm = 'horarios';
          } else {
            this.successMessage = 'Quadra criada com sucesso!';
            setTimeout(() => this.router.navigate(['/quadras']), 1500);
          }
        },
        error: (err) => {
          this.tratarErroSalvar(err);
        }
      });
    }
  }

  salvarApenasHorarios(): void {
    this.erro = '';
    this.successMessage = '';

    if (this.quadraEditandoId) {
      this.salvando = true;
      this.salvarHorariosNaApi(this.quadraEditandoId);
    } else {
      this.salvarInformacoesGerais();
    }
  }

  /**
   * Iterates over all selected time slots for each date and sends a POST request
   * for each one to the DataHorarioReserva API. Skips duplicates that are already saved.
   */
  private salvarHorariosNaApi(quadraId: string): void {
    const comandos: CriarDataHorarioReservaCommand[] = [];

    if (!this.mesAlvo && this.opcoesMesesAlvo.length > 0) {
      this.mesAlvo = this.opcoesMesesAlvo[0].valor;
    }

    if (this.mesAlvo) {
      const [anoStr, mesStr] = this.mesAlvo.split('-');
      const ano = parseInt(anoStr, 10);
      const mes = parseInt(mesStr, 10); // 1-12
      const totalDias = new Date(ano, mes, 0).getDate();

      for (let dia = 1; dia <= totalDias; dia++) {
        const dateObj = new Date(ano, mes - 1, dia);
        const diaSemanaId = dateObj.getDay(); // 0=Dom, 1=Seg...
        const diaPad = String(dia).padStart(2, '0');
        const mesPad = String(mes).padStart(2, '0');
        const dataISO = `${ano}-${mesPad}-${diaPad}`;

        const horarios = this.horariosPorDiaSemana[diaSemanaId] || [];
        if (horarios.length === 0) continue;

        const jaSalvos = this.horariosSalvosGlobal.get(dataISO) ?? new Set<string>();

        for (const horario of horarios) {
          const horShort = this.apiHorarioParaShort(horario);
          if (jaSalvos.has(horShort)) {
            // Se já tem cadastrado no banco de dados para essa data e horário da quadra, não duplica
            continue;
          }

          const horarioFormatted = horShort.length === 5 ? `${horShort}:00` : horShort;
          const command: CriarDataHorarioReservaCommand = {
            quadraId: quadraId,
            data: `${dataISO}T00:00:00`,
            horario: horarioFormatted
          };
          comandos.push(command);
        }
      }
    }

    if (comandos.length === 0) {
      this.salvando = false;
      this.successMessage = 'Quadra e horários salvos com sucesso!';
      setTimeout(() => this.router.navigate(['/quadras']), 1500);
      return;
    }

    // Envia todas as requisições POST para a API
    const requests = comandos.map(cmd =>
      this.dataHorarioService.criar(cmd).pipe(
        catchError(err => of({ ok: false, error: err }))
      )
    );

    forkJoin(requests).subscribe({
      next: (results) => {
        const sucessos = results.filter((r: any) => r?.ok !== false && !r?.error).length;

        comandos.forEach(cmd => {
          this.salvarHorarioLocal(quadraId, {
            quadraId: cmd.quadraId,
            data: cmd.data,
            horario: cmd.horario
          });
        });

        this.salvando = false;

        if (sucessos > 0) {
          this.successMessage = `Quadra salva! ${sucessos} novo(s) horário(s) cadastrado(s) com sucesso.`;
        } else {
          this.successMessage = 'Quadra salva com sucesso!';
        }

        this.carregarHorariosDoApi(quadraId);

        setTimeout(() => this.router.navigate(['/quadras']), 1500);
      },
      error: (err) => {
        console.error('Erro ao salvar horários na API:', err);
        this.salvando = false;
        this.successMessage = 'Quadra salva com sucesso!';
        setTimeout(() => this.router.navigate(['/quadras']), 1500);
      }
    });
  }

  private tratarErroSalvar(err: any): void {
    console.error('Erro ao salvar quadra:', err);
    let mensagemErro = 'Ocorreu um erro ao salvar a quadra na API.';
    if (err.error) {
      if (err.error.erros && err.error.erros.length > 0) {
        mensagemErro = err.error.erros.join(', ');
      } else if (err.error.mensagem) {
        mensagemErro = err.error.mensagem;
      } else if (err.error.errors) {
        const msgs = Object.values(err.error.errors).flat();
        mensagemErro = msgs.join(', ');
      } else if (typeof err.error === 'string') {
        mensagemErro = err.error;
      }
    }
    this.erro = mensagemErro;
    this.salvando = false;
  }

  cancelarCadastro(): void {
    this.router.navigate(['/quadras']);
  }

  onFileSelected(event: any): void {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e: any) => {
        this.novaQuadra.imagemUrl = e.target.result;
      };
      reader.readAsDataURL(file);
    }
  }
}
