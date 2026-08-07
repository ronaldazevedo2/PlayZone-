import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { forkJoin, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { QuadraService, ReservaQuadraDto } from '../../../services/quadra.service';
import { ReservaService, ReservaDto } from '../../../services/reserva.service';
import { UsuarioService } from '../../../services/usuario.service';
import { RespostaApi } from '../../../wrappers/api-response.wrapper';

interface UsuarioBusca {
  usuariosId: string;
  nomeCompleto: string;
  email: string;
  cpf?: string;
  telefone?: string;
  ativo: boolean;
}

@Component({
  selector: 'app-reserva-quadra-detalhes',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './reserva-quadra-detalhes.component.html',
  styleUrl: './reserva-quadra-detalhes.component.css'
})
export class ReservaQuadraDetalhesComponent implements OnInit {
  quadraId: string = '';
  quadraSelecionada: ReservaQuadraDto | null = null;
  reservasQuadraSelecionada: ReservaDto[] = [];
  usuariosBusca: UsuarioBusca[] = [];
  isLoading = true;



  constructor(
    private quadraService: QuadraService,
    private reservaService: ReservaService,
    private usuarioService: UsuarioService,
    private router: Router,
    private route: ActivatedRoute
  ) { }

  ngOnInit(): void {
    this.route.paramMap.subscribe(params => {
      const id = params.get('id');
      if (id) {
        this.quadraId = id;
        this.carregarDados();
      } else {
        this.router.navigate(['/reservas']);
      }
    });
  }

  carregarDados(): void {
    this.isLoading = true;

    forkJoin({
      quadrasRes: this.quadraService.listar(1, 100).pipe(catchError(() => of(null))),
      usuariosRes: this.usuarioService.listar(1, 1000).pipe(catchError(() => of(null))),
      reservasRes: this.reservaService.listar(1, 100, undefined, undefined, this.quadraId).pipe(catchError(() => of(null)))
    }).subscribe({
      next: (res: any) => {
        this.isLoading = false;

        // Quadra
        if (res.quadrasRes && res.quadrasRes.ok && res.quadrasRes.dados && res.quadrasRes.dados.itens) {
          this.quadraSelecionada = res.quadrasRes.dados.itens.find((q: any) => q.id === this.quadraId) || null;
        }

        // Usuários
        if (res.usuariosRes && res.usuariosRes.dados && res.usuariosRes.dados.itens) {
          this.usuariosBusca = res.usuariosRes.dados.itens.map((u: any) => ({
            usuariosId: u.usuariosId || u.id || u.usuarioId || '',
            nomeCompleto: u.nomeCompleto || u.nome || '',
            email: u.email || '',
            cpf: u.cpf,
            telefone: u.telefone,
            ativo: u.ativo ?? true
          }));
        }

        // Reservas
        let localUserMap: any = {};
        try {
          const raw = localStorage.getItem('playzone_reservas_usuarios_map');
          if (raw) localUserMap = JSON.parse(raw);
        } catch {}

        if (res.reservasRes && res.reservasRes.ok && res.reservasRes.dados && res.reservasRes.dados.itens) {
          const itens = res.reservasRes.dados.itens;
          this.reservasQuadraSelecionada = itens.map((item: any) => {
            const resId = item.reservasId || item.reservaId || item.id || '';
            const uId = item.usuariosId || item.usuarioId || '';

            const userCadastrado = this.usuariosBusca.find(u => {
              const uIdCad = (u.usuariosId || (u as any).id || (u as any).usuarioId || '').toLowerCase();
              const uIdTarget = (uId || '').toLowerCase();
              return uIdCad.length > 0 && uIdCad === uIdTarget;
            });

            let nomeResolvido = item.nomeUsuario || item.usuarioNome || userCadastrado?.nomeCompleto || localUserMap[resId]?.nomeUsuario || localUserMap[uId]?.nomeUsuario;

            let emailResolvido = localUserMap[resId]?.emailUsuario || localUserMap[uId]?.emailUsuario || item.emailUsuario || userCadastrado?.email || '';
            let cpfResolvido = userCadastrado?.cpf || '';

            const rawHorario = item.horarioAgendado || item.horario || '';
            const shortHorario = this.formatHorarioShort(rawHorario);
            const rangeHorario = this.formatHorarioRange(shortHorario);
            const dataValida = item.dataAgendada || item.data || '';
            const statusCalculado = this.calcularStatusReserva(dataValida, rawHorario, item.status);

            const itemReserva: ReservaDto = {
              id: resId,
              quadraId: this.quadraId,
              nomeQuadra: item.nomeQuadra || this.quadraSelecionada?.nome || 'Quadra',
              modalidade: item.modalidade || this.quadraSelecionada?.modalidade || 'Futebol Society',
              usuarioId: uId,
              nomeUsuario: nomeResolvido || 'Carregando...',
              emailUsuario: emailResolvido,
              cpfUsuario: cpfResolvido,
              telefoneUsuario: item.telefoneUsuario || userCadastrado?.telefone || '',
              data: dataValida,
              horario: rangeHorario || shortHorario,
              status: statusCalculado
            };

            if ((!nomeResolvido || nomeResolvido === 'Carregando...') && uId) {
              this.usuarioService.obterPorId(uId).subscribe({
                next: (uRes: any) => {
                  const userDados = uRes?.dados || uRes;
                  if (userDados && (userDados.nomeCompleto || userDados.nome)) {
                    itemReserva.nomeUsuario = userDados.nomeCompleto || userDados.nome;
                    if (userDados.email) itemReserva.emailUsuario = userDados.email;
                    if (userDados.cpf) itemReserva.cpfUsuario = userDados.cpf;
                  } else {
                    itemReserva.nomeUsuario = 'Usuário do Sistema';
                  }
                },
                error: () => {
                  itemReserva.nomeUsuario = 'Usuário do Sistema';
                }
              });
            }

            return itemReserva;
          }).sort((a: any, b: any) => new Date(b.data).getTime() - new Date(a.data).getTime());
        }
      },
      error: () => {
        this.isLoading = false;
      }
    });
  }

  voltarParaQuadras(): void {
    this.router.navigate(['/reservas']);
  }

  openDetailsModal(reserva: ReservaDto): void {
    const id = reserva.id || reserva.reservaId;
    if (id) {
      this.router.navigate(['/reservas/editar', id]);
    }
  }

  private formatHorarioShort(horarioRaw: string): string {
    if (!horarioRaw) return '';
    const parts = horarioRaw.split(':');
    if (parts.length >= 2) {
      return `${parts[0].padStart(2, '0')}:${parts[1].padStart(2, '0')}`;
    }
    return horarioRaw;
  }

  private formatHorarioRange(shortTime: string): string {
    if (!shortTime) return '';
    const parts = shortTime.split(':').map(Number);
    if (parts.length >= 2 && !isNaN(parts[0])) {
      const startHour = parts[0];
      const startMin = parts[1];
      const endHour = (startHour + 1) % 24;
      const startStr = `${String(startHour).padStart(2, '0')}:${String(startMin).padStart(2, '0')}`;
      const endStr = `${String(endHour).padStart(2, '0')}:${String(startMin).padStart(2, '0')}`;
      return `${startStr} - ${endStr}`;
    }
    return shortTime;
  }

  private calcularStatusReserva(dataIsoStr: string, horarioStr: string, statusOriginal?: string): 'Ativa' | 'Cancelada' | 'Finalizada' {
    if (statusOriginal === 'Cancelada') return 'Cancelada';
    if (!dataIsoStr) return (statusOriginal as any) || 'Ativa';

    const dataApenas = dataIsoStr.split('T')[0];
    let hora = 0;
    let min = 0;

    if (horarioStr) {
      const parteInicial = horarioStr.split('-')[0].trim();
      const tempo = parteInicial.split(':');
      if (tempo.length >= 2) {
        hora = parseInt(tempo[0], 10) || 0;
        min = parseInt(tempo[1], 10) || 0;
      }
    }

    const [ano, mes, dia] = dataApenas.split('-').map(Number);
    if (!ano || !mes || !dia) return (statusOriginal as any) || 'Ativa';

    const dataHorarioReserva = new Date(ano, mes - 1, dia, hora, min);
    const agora = new Date();

    if (dataHorarioReserva < agora) return 'Finalizada';
    return (statusOriginal as any) || 'Ativa';
  }

  getBadgeModalidadeClass(modalidade: string): string {
    if (!modalidade) return 'badge-default';
    const m = modalidade.toLowerCase();
    if (m.includes('society')) return 'badge-society';
    if (m.includes('futsal')) return 'badge-futsal';
    if (m.includes('basquete')) return 'badge-basquete';
    if (m.includes('vôlei') || m.includes('volei')) return 'badge-volei';
    if (m.includes('beach')) return 'badge-beachtennis';
    return 'badge-default';
  }

  getStatusClass(status: string): string {
    switch (status) {
      case 'Ativa': return 'status-active';
      case 'Cancelada': return 'status-inactive';
      case 'Finalizada': return 'status-finished';
      default: return 'status-active';
    }
  }
}
