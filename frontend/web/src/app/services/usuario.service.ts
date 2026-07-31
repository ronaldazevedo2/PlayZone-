import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { AuthService } from './auth.service';
import { RespostaApi } from '../wrappers/api-response.wrapper';
import { ResultadoPaginado } from './secretaria.service';

export interface UsuarioDto {
  usuariosId: string;
  nomeCompleto: string;
  email: string;
  cpf: string;
  telefone: string;
  nomePerfil: string;
  ativo: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class UsuarioService {
  private readonly BASE_URL = 'https://localhost:7200/api/Usuarios';

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

  private getGetHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    const headersConfig: any = {
      'Accept': 'application/json'
    };
    if (token) {
      headersConfig['Authorization'] = `Bearer ${token}`;
    }
    return new HttpHeaders(headersConfig);
  }

  /**
   * Busca a lista real de usuários cadastrados no banco de dados MySQL via API.
   */
  listar(
    pagina = 1,
    tamanhoPagina = 100,
    busca?: string
  ): Observable<RespostaApi<ResultadoPaginado<UsuarioDto>>> {
    let params = new HttpParams()
      .set('pagina', pagina.toString())
      .set('tamanhoPagina', tamanhoPagina.toString());

    if (busca) {
      params = params.set('busca', busca);
    }

    return this.http
      .get<RespostaApi<ResultadoPaginado<UsuarioDto>>>(
        this.BASE_URL,
        { headers: this.getGetHeaders(), params }
      )
      .pipe(
        map((res: any) => {
          // Extrai dados reais vindos da API/MySQL
          const itens = res?.dados?.itens ?? res?.dados ?? res?.itens ?? (Array.isArray(res) ? res : []);
          return {
            ok: res?.ok ?? true,
            mensagem: res?.mensagem ?? '',
            erros: res?.erros ?? null,
            dados: {
              itens: itens,
              total: res?.dados?.total ?? itens.length,
              pagina: pagina,
              tamanhoPagina: tamanhoPagina,
              totalPaginas: res?.dados?.totalPaginas ?? 1
            } as any
          };
        }),
        catchError(this.handleError)
      );
  }

  private handleError = (error: any): Observable<never> => {
    console.error('[UsuarioService] Erro ao buscar usuários no banco de dados:', error);
    return throwError(() => error);
  };
}