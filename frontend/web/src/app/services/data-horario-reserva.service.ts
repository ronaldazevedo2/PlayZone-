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
  reservado?: boolean; // true if already booked by a user
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

  /**
   * Creates a single DataHorarioReserva entry.
   * POST /api/DataHorarioReserva
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
   * Lists all DataHorarioReserva entries, optionally filtered by quadraId and/or data.
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
   * Lists all DataHorarioReserva entries for a specific quadra.
   * Useful for loading all existing schedules when editing.
   */
  listarPorQuadra(quadraId: string): Observable<RespostaApi<DataHorarioReservaDto[]>> {
    return this.http
      .get<RespostaApi<DataHorarioReservaDto[]>>(
        `${this.BASE_URL}/quadra/${quadraId}`,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  /**
   * Lists DataHorarioReserva entries for a specific quadra and date.
   * Used on the reservas screen to show which slots are available vs booked.
   */
  listarPorQuadraEData(quadraId: string, data: string): Observable<RespostaApi<DataHorarioReservaDto[]>> {
    return this.listar(quadraId, data);
  }

  private handleError = (error: any): Observable<never> => {
    console.error('[DataHorarioReservaService] Erro na requisição:', error);
    return throwError(() => error);
  };
}
