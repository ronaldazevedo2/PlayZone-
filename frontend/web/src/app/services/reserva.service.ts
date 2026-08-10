import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { AuthService } from './auth.service';
import { RespostaApi } from '../wrappers/api-response.wrapper';
import { ResultadoPaginado } from './secretaria.service';

export interface ReservaDto {
  id?: string;
  reservaId?: string;
  quadraId?: string;
  nomeQuadra: string;
  modalidade: string;
  usuarioId?: string;
  nomeUsuario: string;
  emailUsuario?: string;
  cpfUsuario?: string;
  telefoneUsuario?: string;
  data: string;
  horario: string;
  status: 'Ativa' | 'Cancelada' | 'Finalizada';
  dataCriacao?: string;
  observacoes?: string;
}

export interface CriarReservaCommand {
  quadraId: string;
  usuarioId: string;
  dataAgendada: string; // ISO date string
  horarioAgendado: string;
}

@Injectable({
  providedIn: 'root'
})
export class ReservaService {
  private readonly BASE_URL = 'https://localhost:7200/api/Reservas';

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    if (!token) {
      throw new Error('Usuário não autenticado.');
    }
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });
  }

  listar(
    pagina = 1,
    tamanhoPagina = 10,
    busca?: string,
    modalidade?: string,
    quadraId?: string
  ): Observable<RespostaApi<ResultadoPaginado<ReservaDto>>> {
    let params = new HttpParams()
      .set('pagina', pagina.toString())
      .set('tamanhoPagina', tamanhoPagina.toString());

    if (busca) {
      params = params.set('busca', busca);
    }
    if (modalidade && modalidade !== 'Todas') {
      params = params.set('modalidade', modalidade);
    }
    if (quadraId) {
      params = params.set('quadraId', quadraId);
    }

    return this.http
      .get<RespostaApi<ResultadoPaginado<ReservaDto>>>(
        this.BASE_URL,
        { headers: this.getHeaders(), params }
      )
      .pipe(catchError(this.handleError));
  }

  obterPorId(reservaId: string): Observable<RespostaApi<ReservaDto>> {
    return this.http
      .get<RespostaApi<ReservaDto>>(
        `${this.BASE_URL}/${reservaId}`,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  criar(command: CriarReservaCommand): Observable<RespostaApi<ReservaDto>> {
    return this.http
      .post<RespostaApi<ReservaDto>>(
        this.BASE_URL,
        command,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  atualizar(reservaId: string, command: any): Observable<RespostaApi<ReservaDto>> {
    return this.http
      .put<RespostaApi<ReservaDto>>(
        `${this.BASE_URL}/${reservaId}`,
        command,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  private handleError = (error: any): Observable<never> => {
    console.error('[ReservaService] Erro na requisição:', error);
    return throwError(() => error);
  };
}
