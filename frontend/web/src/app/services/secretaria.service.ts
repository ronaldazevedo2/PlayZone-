import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { AuthService } from './auth.service';

// ─────────────────────────────────────────────
// Interfaces — espelham os schemas do Swagger
// ─────────────────────────────────────────────

import { RespostaApi } from '../wrappers/api-response.wrapper';

/** DTO de listagem paginada */
export interface SecretariaListaDto {
  secretariaId: string;
  nome: string | null;
  email: string | null;
  contato: string | null;
  cep: string | null;
  endereco: string | null;
  numero: string | null;
  bairro: string | null;
  cidade: string | null;
}

/** DTO de detalhe */
export interface SecretariaDetalheDto {
  secretariaId: string;
  nome: string | null;
  email: string | null;
  contato: string | null;
  cep: string | null;
  endereco: string | null;
  numero: string | null;
  bairro: string | null;
  cidade: string | null;
}

/** Resultado paginado genérico */
export interface ResultadoPaginado<T> {
  itens: T[] | null;
  total: number;
  pagina: number;
  tamanhoPagina: number;
  totalPaginas: number;
  temProximaPagina: boolean;
  temPaginaAnterior: boolean;
}

/** Body para criação — POST /api/Secretaria */
export interface CriarSecretariaCommand {
  secretariaId?: string;
  nome: string;
  email: string;
  contato: string;
  cep: string;
  endereco: string;
  numero: string;
  bairro: string;
  cidade: string;
}

/** Body para atualização — PUT /api/Secretaria/{id} */
export interface AtualizarSecretariaRequest {
  nome?: string | null;
  email?: string | null;
  contato?: string | null;
  cep?: string | null;
  endereco?: string | null;
  numero?: string | null;
  bairro?: string | null;
  cidade?: string | null;
}

/** Resposta de criação */
export interface CriarSecretariaResposta {
  secretariaId: string;
  nome: string | null;
  email: string | null;
  contato: string | null;
  cep: string | null;
  endereco: string | null;
  numero: string | null;
  bairro: string | null;
  cidade: string | null;
}

// ─────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────

@Injectable({
  providedIn: 'root'
})
export class SecretariaService {

  private readonly BASE_URL = 'https://localhost:7200/api/Secretaria';

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) { }

  // ── helpers ───────────────────────────────

  /** Constrói os headers com o token JWT */
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

  // ── CRUD ──────────────────────────────────

  /**
   * Lista secretarias com paginação e busca opcional.
   * GET /api/Secretaria?pagina=1&tamanhoPagina=10&busca=
   */
  listar(
    pagina = 1,
    tamanhoPagina = 10,
    busca?: string
  ): Observable<RespostaApi<ResultadoPaginado<SecretariaListaDto>>> {
    let params = new HttpParams()
      .set('pagina', pagina.toString())
      .set('tamanhoPagina', tamanhoPagina.toString());

    if (busca) {
      params = params.set('busca', busca);
    }

    return this.http
      .get<RespostaApi<ResultadoPaginado<SecretariaListaDto>>>(
        this.BASE_URL,
        { headers: this.getHeaders(), params }
      )
      .pipe(catchError(this.handleError));
  }

  /**
   * Busca detalhes de uma secretaria pelo ID.
   * GET /api/Secretaria/{secretariaId}
   */
  buscarPorId(
    secretariaId: string
  ): Observable<RespostaApi<SecretariaDetalheDto>> {
    return this.http
      .get<RespostaApi<SecretariaDetalheDto>>(
        `${this.BASE_URL}/${secretariaId}`,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  /**
   * Cria uma nova secretaria.
   * POST /api/Secretaria
   * Nota: a API usa o campo "endereço" (com cedilha) — mapeado aqui.
   */
  criar(
    command: CriarSecretariaCommand
  ): Observable<RespostaApi<CriarSecretariaResposta>> {
    const body: Record<string, unknown> = {
      secretariaId: command.secretariaId,
      nome: command.nome,
      email: command.email,
      contato: command.contato,
      cep: command.cep,
      'endereço': command.endereco,
      numero: command.numero,
      bairro: command.bairro,
      cidade: command.cidade,
    };

    return this.http
      .post<RespostaApi<CriarSecretariaResposta>>(
        this.BASE_URL,
        body,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  /**
   * Atualiza os dados de uma secretaria.
   * PUT /api/Secretaria/{secretariaId}
   */
  atualizar(
    secretariaId: string,
    request: AtualizarSecretariaRequest
  ): Observable<RespostaApi<null>> {
    // Map endereco to endereço to match backend payload expectations
    const body: Record<string, any> = {
      nome: request.nome,
      email: request.email,
      contato: request.contato,
      cep: request.cep,
      endereco: request.endereco,
      numero: request.numero,
      bairro: request.bairro,
      cidade: request.cidade
    };
    console.log(body);

    return this.http
      .put<RespostaApi<null>>(
        `${this.BASE_URL}/${secretariaId}`,
        body,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  /**
   * Remove uma secretaria permanentemente.
   * DELETE /api/Secretaria/{secretariaId}
   */
  deletar(secretariaId: string): Observable<RespostaApi<null>> {
    return this.http
      .delete<RespostaApi<null>>(
        `${this.BASE_URL}/${secretariaId}`,
        { headers: this.getHeaders() }
      )
      .pipe(catchError(this.handleError));
  }

  // ── Error handler ─────────────────────────

  private handleError(error: unknown): Observable<never> {
    console.error('[SecretariaService] Erro na requisição:', error);
    return throwError(() => error);
  }
}
