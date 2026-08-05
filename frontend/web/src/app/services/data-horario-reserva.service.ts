import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { AuthService } from './auth.service';
import { RespostaApi } from '../wrappers/api-response.wrapper';

export interface DataHorarioReservaDto {
  id?: string;
  quadraId: string;
  data: string;       // "2026-07-28T00:00:00"
  horario: string;     // "08:00:00"
  reservado?: boolean; // true se já reservado por um usuário
}

export interface CriarDataHorarioReservaCommand {
  quadraId: string;
  data: string;    // "2026-07-28T00:00:00"
  horario: string;  // "08:00:00"
}

@Injectable({
  providedIn: 'root'
})
export class DataHorarioReservaService {
  private readonly BASE_URL = 'https://localhost:7200/api/DataHorarioReserva';

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) { }

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

  /**
   * Envia uma entrada de horário para uma quadra na rota da API:
   * POST /api/DataHorarioReserva/quadra/{quadraId}
   */
  criar(command: CriarDataHorarioReservaCommand): Observable<RespostaApi<DataHorarioReservaDto>> {
    return this.http
      .post<RespostaApi<DataHorarioReservaDto>>(
        this.BASE_URL,
        command,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  /**
   * Lista horários cadastrados, com filtro opcional por quadraId e/ou data.
   * GET /api/DataHorarioReserva?quadraId=xxx&data=yyyy-MM-dd
   */
  listar(quadraId?: string, data?: string): Observable<RespostaApi<DataHorarioReservaDto[]>> {
    let params = new HttpParams();
    if (quadraId) {
      params = params.set('quadraId', quadraId);
    }
    if (data) {
      params = params.set('data', data);
    }

    return this.http
      .get<RespostaApi<DataHorarioReservaDto[]>>(
        this.BASE_URL,
        { headers: this.getHeaders(), params }
      )
      .pipe(catchError(this.handleError));
  }

  /**
   * Lista todas as entradas de DataHorarioReserva para uma quadra específica.
   * GET /api/DataHorarioReserva?quadraId=xxx
   */
  listarPorQuadra(quadraId: string): Observable<RespostaApi<DataHorarioReservaDto[]>> {
    return this.listar(quadraId);
  }

  /**
   * Lista horários disponíveis cadastrados para a quadra e data.
   * GET /api/DataHorarioReserva/disponiveis?quadraId=xxx&data=yyyy-MM-dd
   */
  obterHorariosDisponiveis(quadraId: string, data: string): Observable<RespostaApi<{ horario: string; disponivel: boolean }[]>> {
    let params = new HttpParams()
      .set('quadraId', quadraId)
      .set('data', data);

    return this.http
      .get<RespostaApi<{ horario: string; disponivel: boolean }[]>>(
        `${this.BASE_URL}/disponiveis`,
        { headers: this.getHeaders(), params }
      )
      .pipe(catchError(this.handleError));
  }

  private handleError = (error: any): Observable<never> => {
    console.error('[DataHorarioReservaService] Erro na requisição:', error);
    return throwError(() => error);
  };
}
