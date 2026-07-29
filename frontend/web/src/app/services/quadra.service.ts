import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, throwError, of } from 'rxjs';
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
      .pipe(catchError((error: any) => {
        console.error('[QuadraService] Erro na exclusão:', error);
        return throwError(() => error);
      }));
  }

  /**
   * Salva a disponibilidade de datas e horários para a quadra especificada.
   * Salva no localStorage como fallback e tenta sincronizar com a API via POST/PUT.
   */
  salvarDisponibilidade(quadraId: string, disponibilidade: { data: string; horarios: string[] }[]): Observable<RespostaApi<any>> {
    try {
      localStorage.setItem(`playzone_disponibilidade_${quadraId}`, JSON.stringify(disponibilidade));
    } catch (e) {
      console.warn('[QuadraService] Erro ao salvar no localStorage:', e);
    }

    const url = `${this.BASE_URL}/${quadraId}/disponibilidade`;
    return this.http.post<RespostaApi<any>>(url, disponibilidade, { headers: this.getHeaders() }).pipe(
      catchError((error: any) => {
        console.warn('[QuadraService] Falha ao enviar disponibilidade para a API, salva localmente.', error);
        const resposta: RespostaApi<any> = {
          ok: true,
          mensagem: 'Disponibilidade salva localmente.',
          erros: null,
          dados: disponibilidade
        };
        return of(resposta);
      })
    );
  }

  /**
   * Obtém a disponibilidade de datas e horários para a quadra especificada.
   * Expect API endpoint: GET /api/Quadra/{quadraId}/disponibilidade
   * Returns array of { data: string (ISO), horarios: string[] }
   */
  obterDisponibilidade(quadraId: string): Observable<RespostaApi<any>> {
    // 1. Verifica se existe no localStorage
    try {
      const local = localStorage.getItem(`playzone_disponibilidade_${quadraId}`);
      if (local) {
        const dados = JSON.parse(local);
        return of({
          ok: true,
          mensagem: '',
          erros: null,
          dados
        });
      }
    } catch (e) {
      console.warn('[QuadraService] Erro ao ler do localStorage:', e);
    }

    // 2. Se não estiver no localStorage, tenta buscar da API
    const url = `${this.BASE_URL}/${quadraId}/disponibilidade`;
    return this.http.get<RespostaApi<any>>(url, { headers: this.getHeaders() }).pipe(
      catchError((error: any) => {
        console.warn('[QuadraService] Falha ao obter disponibilidade da API, gerando padrão.', error);
        // Gera mock padrão com os horários pré-definidos para o mês atual
        const hoje = new Date();
        const ano = hoje.getFullYear();
        const mes = hoje.getMonth();
        const totalDias = new Date(ano, mes + 1, 0).getDate();

        const mockDados: { data: string; horarios: string[] }[] = [];
        const slotsPadrao = ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00'];

        for (let dia = 1; dia <= totalDias; dia++) {
          const dataISO = `${ano}-${String(mes + 1).padStart(2, '0')}-${String(dia).padStart(2, '0')}`;
          mockDados.push({
            data: dataISO,
            horarios: [...slotsPadrao]
          });
        }

        const mock: RespostaApi<any> = {
          ok: true,
          mensagem: '',
          erros: null,
          dados: mockDados
        };
        return of(mock);
      })
    );
  }

  private handleError = (error: any): Observable<never> => {
    console.error('[QuadraService] Erro na requisição:', error);
    return throwError(() => error);
  }
}

