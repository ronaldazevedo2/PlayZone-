import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { AuthService } from './auth.service';
import { RespostaApi } from '../wrappers/api-response.wrapper';
import { ResultadoPaginado } from './secretaria.service'; // reaproveita ResultadoPaginado

export interface ReservaQuadraDto {
  id: string;
  nome: string;
  descricao: string;
  localizacao: string;
  capacidade: number;
  modalidade: string;
  imagemUrl: string;
  status: string;
}

export interface CriarQuadraCommand {
  nome: string;
  descricao: string;
  capacidade: number;
  localizacao: string;
  modalidade: string;
  imagemUrl: string;
  status: string;
}

export interface AtualizarQuadraRequest {
  nome: string;
  descricao: string;
  localizacao: string;
  capacidade: number;
  modalidade: string;
  imagemUrl: string;
  status: string;
}

@Injectable({
  providedIn: 'root'
})
export class QuadraService {
  private readonly BASE_URL = 'https://localhost:7200/api/Quadra';

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

  private getDeleteHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    if (!token) {
      throw new Error('Usuário não autenticado.');
    }
    return new HttpHeaders({
      'Accept': 'application/json',
      'Authorization': `Bearer ${token}`
    });
  }

  listar(
    pagina = 1,
    tamanhoPagina = 10,
    busca?: string
  ): Observable<RespostaApi<ResultadoPaginado<ReservaQuadraDto>>> {
    let params = new HttpParams()
      .set('pagina', pagina.toString())
      .set('tamanhoPagina', tamanhoPagina.toString());

    if (busca) {
      params = params.set('busca', busca);
    }

    return this.http
      .get<RespostaApi<ResultadoPaginado<ReservaQuadraDto>>>(
        this.BASE_URL,
        { headers: this.getHeaders(), params }
      )
      .pipe(catchError(this.handleError));
  }

  obterPorId(quadraId: string): Observable<RespostaApi<ReservaQuadraDto>> {
    return this.http
      .get<RespostaApi<ReservaQuadraDto>>(
        `${this.BASE_URL}/${quadraId}`,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  criar(command: CriarQuadraCommand): Observable<RespostaApi<ReservaQuadraDto>> {
    return this.http
      .post<RespostaApi<ReservaQuadraDto>>(
        this.BASE_URL,
        command,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  atualizar(quadraId: string, request: AtualizarQuadraRequest): Observable<RespostaApi<null>> {
    return this.http
      .put<RespostaApi<null>>(
        `${this.BASE_URL}/${quadraId}`,
        request,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  excluir(quadraId: string): Observable<any> {
    return this.http
      .delete<any>(
        `${this.BASE_URL}/${quadraId}`,
        { headers: this.getDeleteHeaders() }
      )
      .pipe(catchError((error) => {
        console.error('[QuadraService] Erro na exclusão:', error);
        return throwError(() => error);
      }));
  }

  private handleError = (error: any): Observable<never> => {
    console.error('[QuadraService] Erro na requisição:', error);
    return throwError(() => error);
  }
}
