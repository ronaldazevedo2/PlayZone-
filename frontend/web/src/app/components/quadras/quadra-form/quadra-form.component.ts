import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { QuadraService, CriarQuadraCommand } from '../../../services/quadra.service';

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

  // Estado do Formulário
  novaQuadra: CriarQuadraCommand = {
    nome: '',
    descricao: '',
    capacidade: 12,
    localizacao: '',
    modalidade: 'Futebol Society',
    imagemUrl: '',
    status: 'Ativa'
  };

  opcoesModalidades = [
    'Futebol Society',
    'Beach Tennis',
    'Futsal',
    'Vôlei de Areia'
  ];

  // --- Estrutura e Estado da Disponibilidade Mensal Por Data ---
  nomesMeses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
  cabecalhoDiasSemana = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];
  nomesDiasExtenso = ['Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];

  dataCalendarioAtual = new Date();
  dataSelecionadaISO = '';

  slotsHorariosDisponiveis = [
    '08:00', '09:00', '10:00', '11:00', '12:00', '13:00',
    '14:00', '15:00', '16:00', '17:00', '18:00', '19:00',
    '20:00', '21:00', '22:00'
  ];

  disponibilidadePorData: { [dataISO: string]: string[] } = {};

  diasDoCalendario: Array<{
    dataISO: string;
    numeroDia: number;
    mesAtual: boolean;
    temHorarios: boolean;
    selecionado: boolean;
  }> = [];

  constructor(
    private quadraService: QuadraService,
    private router: Router,
    private route: ActivatedRoute
  ) { }

  ngOnInit(): void {
    const idParam = this.route.snapshot.paramMap.get('id');
    if (idParam) {
      this.quadraEditandoId = idParam;
      this.carregarQuadraParaEdicao(idParam);
    } else {
      this.inicializarNovaQuadra();
    }
  }

  inicializarNovaQuadra(): void {
    this.novaQuadra = {
      nome: '',
      descricao: '',
      capacidade: 12,
      localizacao: '',
      modalidade: 'Futebol Society',
      imagemUrl: '',
      status: 'Ativa'
    };

    this.dataCalendarioAtual = new Date();
    const ano = this.dataCalendarioAtual.getFullYear();
    const mes = this.dataCalendarioAtual.getMonth();
    const dia = this.dataCalendarioAtual.getDate();
    this.dataSelecionadaISO = `${ano}-${String(mes + 1).padStart(2, '0')}-${String(dia).padStart(2, '0')}`;

    this.disponibilidadePorData = {};
    const totalDias = new Date(ano, mes + 1, 0).getDate();
    for (let d = 1; d <= totalDias; d++) {
      const iso = `${ano}-${String(mes + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      this.disponibilidadePorData[iso] = [...this.slotsHorariosDisponiveis];
    }

    this.gerarCalendario();
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
            status: q.status || 'Ativa'
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

    this.dataCalendarioAtual = new Date();
    const ano = this.dataCalendarioAtual.getFullYear();
    const mes = this.dataCalendarioAtual.getMonth();
    const dia = this.dataCalendarioAtual.getDate();
    this.dataSelecionadaISO = `${ano}-${String(mes + 1).padStart(2, '0')}-${String(dia).padStart(2, '0')}`;
    this.disponibilidadePorData = {};

    this.quadraService.obterDisponibilidade(id).subscribe({
      next: (res: any) => {
        if (res && res.ok && res.dados && Array.isArray(res.dados)) {
          res.dados.forEach((item: any) => {
            if (item.data && Array.isArray(item.horarios)) {
              this.disponibilidadePorData[item.data] = [...item.horarios];
            }
          });
        }
        this.gerarCalendario();
      },
      error: () => {
        this.gerarCalendario();
      }
    });
  }

  // --- Lógica do Calendário ---
  gerarCalendario(): void {
    const ano = this.dataCalendarioAtual.getFullYear();
    const mes = this.dataCalendarioAtual.getMonth();

    const primeiroDiaMes = new Date(ano, mes, 1);
    const diaSemanaInicio = primeiroDiaMes.getDay();
    const ultimoDiaMes = new Date(ano, mes + 1, 0).getDate();

    const dias: Array<{
      dataISO: string;
      numeroDia: number;
      mesAtual: boolean;
      temHorarios: boolean;
      selecionado: boolean;
    }> = [];

    const mesAnt = mes === 0 ? 11 : mes - 1;
    const anoAnt = mes === 0 ? ano - 1 : ano;
    const ultimoDiaMesAnt = new Date(ano, mes, 0).getDate();

    for (let i = diaSemanaInicio - 1; i >= 0; i--) {
      const diaNum = ultimoDiaMesAnt - i;
      const dataISO = `${anoAnt}-${String(mesAnt + 1).padStart(2, '0')}-${String(diaNum).padStart(2, '0')}`;
      const temHorarios = (this.disponibilidadePorData[dataISO]?.length ?? 0) > 0;
      dias.push({
        dataISO,
        numeroDia: diaNum,
        mesAtual: false,
        temHorarios,
        selecionado: dataISO === this.dataSelecionadaISO
      });
    }

    for (let diaNum = 1; diaNum <= ultimoDiaMes; diaNum++) {
      const dataISO = `${ano}-${String(mes + 1).padStart(2, '0')}-${String(diaNum).padStart(2, '0')}`;
      const temHorarios = (this.disponibilidadePorData[dataISO]?.length ?? 0) > 0;
      dias.push({
        dataISO,
        numeroDia: diaNum,
        mesAtual: true,
        temHorarios,
        selecionado: dataISO === this.dataSelecionadaISO
      });
    }

    const totalCelulas = dias.length > 35 ? 42 : 35;
    const diasRestantes = totalCelulas - dias.length;
    const mesProx = mes === 11 ? 0 : mes + 1;
    const anoProx = mes === 11 ? ano + 1 : ano;

    for (let diaNum = 1; diaNum <= diasRestantes; diaNum++) {
      const dataISO = `${anoProx}-${String(mesProx + 1).padStart(2, '0')}-${String(diaNum).padStart(2, '0')}`;
      const temHorarios = (this.disponibilidadePorData[dataISO]?.length ?? 0) > 0;
      dias.push({
        dataISO,
        numeroDia: diaNum,
        mesAtual: false,
        temHorarios,
        selecionado: dataISO === this.dataSelecionadaISO
      });
    }

    this.diasDoCalendario = dias;
  }

  mesAnterior(): void {
    this.dataCalendarioAtual = new Date(
      this.dataCalendarioAtual.getFullYear(),
      this.dataCalendarioAtual.getMonth() - 1,
      1
    );
    this.gerarCalendario();
  }

  proximoMes(): void {
    this.dataCalendarioAtual = new Date(
      this.dataCalendarioAtual.getFullYear(),
      this.dataCalendarioAtual.getMonth() + 1,
      1
    );
    this.gerarCalendario();
  }

  selecionarData(dataISO: string): void {
    this.dataSelecionadaISO = dataISO;
    if (!this.disponibilidadePorData[dataISO]) {
      this.disponibilidadePorData[dataISO] = [];
    }
    this.gerarCalendario();
  }

  getTituloMesAno(): string {
    const mes = this.nomesMeses[this.dataCalendarioAtual.getMonth()];
    const ano = this.dataCalendarioAtual.getFullYear();
    return `${mes} de ${ano}`;
  }

  getTituloDataExtenso(): string {
    if (!this.dataSelecionadaISO) return 'Nenhuma data selecionada';
    const parts = this.dataSelecionadaISO.split('-').map(Number);
    if (parts.length !== 3) return this.dataSelecionadaISO;
    const d = new Date(parts[0], parts[1] - 1, parts[2]);
    const diaSemana = this.nomesDiasExtenso[d.getDay()];
    const diaPad = String(parts[2]).padStart(2, '0');
    const nomeMes = this.nomesMeses[parts[1] - 1];
    const ano = parts[0];
    return `${diaSemana}, ${diaPad} de ${nomeMes} de ${ano}`;
  }

  getTotalHorariosDataSelecionada(): number {
    if (!this.dataSelecionadaISO) return 0;
    return this.disponibilidadePorData[this.dataSelecionadaISO]?.length ?? 0;
  }

  alternarHorarioSlot(slot: string): void {
    if (!this.dataSelecionadaISO) return;
    if (!this.disponibilidadePorData[this.dataSelecionadaISO]) {
      this.disponibilidadePorData[this.dataSelecionadaISO] = [];
    }

    const lista = this.disponibilidadePorData[this.dataSelecionadaISO];
    const idx = lista.indexOf(slot);
    if (idx > -1) {
      lista.splice(idx, 1);
    } else {
      lista.push(slot);
      lista.sort((a, b) => a.localeCompare(b));
    }
    this.gerarCalendario();
  }

  horarioSlotSelecionado(slot: string): boolean {
    if (!this.dataSelecionadaISO) return false;
    return this.disponibilidadePorData[this.dataSelecionadaISO]?.includes(slot) ?? false;
  }

  selecionarTodosHorariosData(): void {
    if (!this.dataSelecionadaISO) return;
    this.disponibilidadePorData[this.dataSelecionadaISO] = [...this.slotsHorariosDisponiveis];
    this.gerarCalendario();
  }

  limparHorariosData(): void {
    if (!this.dataSelecionadaISO) return;
    this.disponibilidadePorData[this.dataSelecionadaISO] = [];
    this.gerarCalendario();
  }

  copiarParaTodosDiasDoMes(): void {
    if (!this.dataSelecionadaISO) return;
    const horariosOrigem = [...(this.disponibilidadePorData[this.dataSelecionadaISO] ?? [])];

    const ano = this.dataCalendarioAtual.getFullYear();
    const mes = this.dataCalendarioAtual.getMonth();
    const totalDias = new Date(ano, mes + 1, 0).getDate();

    for (let dia = 1; dia <= totalDias; dia++) {
      const iso = `${ano}-${String(mes + 1).padStart(2, '0')}-${String(dia).padStart(2, '0')}`;
      this.disponibilidadePorData[iso] = [...horariosOrigem];
    }

    this.gerarCalendario();
  }

  // --- Salvamento e Cancelamento com Roteamento ---
  salvarQuadra(): void {
    if (this.novaQuadra.nome) {
      this.novaQuadra.nome = this.novaQuadra.nome.toUpperCase();
    }

    if (!this.novaQuadra.nome || !this.novaQuadra.localizacao || !this.novaQuadra.capacidade) {
      this.erro = 'Por favor, preencha todos os campos obrigatórios (*).';
      return;
    }

    if (!this.novaQuadra.imagemUrl) {
      if (this.novaQuadra.modalidade.includes('Beach')) {
        this.novaQuadra.imagemUrl = 'https://images.unsplash.com/photo-1593787406536-3676a152d9cb?q=80&w=300';
      } else if (this.novaQuadra.modalidade.includes('Futsal')) {
        this.novaQuadra.imagemUrl = 'https://images.unsplash.com/photo-1518063319789-7217e6706b04?q=80&w=300';
      } else if (this.novaQuadra.modalidade.includes('Vôlei')) {
        this.novaQuadra.imagemUrl = 'https://images.unsplash.com/photo-1547941126-3d5322b218b6?q=80&w=300';
      } else {
        this.novaQuadra.imagemUrl = 'https://images.unsplash.com/photo-1545807191-178a3752c51e?q=80&w=300';
      }
    }

    if (!this.novaQuadra.descricao) {
      this.novaQuadra.descricao = `Quadra de ${this.novaQuadra.modalidade} para ${this.novaQuadra.capacidade} jogadores.`;
    }

    this.salvando = true;
    this.erro = '';

    const commandToSave = {
      ...this.novaQuadra,
      capacidade: Number(this.novaQuadra.capacidade)
    } as any;

    const salvarDisponibilidadeAux = (id: string) => {
      const listaArray = Object.keys(this.disponibilidadePorData).map(data => ({
        data,
        horarios: this.disponibilidadePorData[data]
      }));
      this.quadraService.salvarDisponibilidade(id, listaArray).subscribe();
    };

    if (this.quadraEditandoId) {
      this.quadraService.atualizar(this.quadraEditandoId, commandToSave).subscribe({
        next: () => {
          salvarDisponibilidadeAux(this.quadraEditandoId!);
          this.salvando = false;
          this.router.navigate(['/quadras']);
        },
        error: (err) => {
          this.tratarErroSalvar(err);
        }
      });
    } else {
      this.quadraService.criar(commandToSave).subscribe({
        next: (res: any) => {
          const newId = res?.dados?.id || res?.id || 'temp_' + Date.now();
          salvarDisponibilidadeAux(newId);
          this.salvando = false;
          this.router.navigate(['/quadras']);
        },
        error: (err) => {
          this.tratarErroSalvar(err);
        }
      });
    }
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
