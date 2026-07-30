import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
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

  listar(
    pagina = 1,
    tamanhoPagina = 10,
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
        { headers: this.getHeaders(), params }
      )
      .pipe(catchError(this.handleError));
  }

  private handleError = (error: any): Observable<never> => {
    console.error('[UsuarioService] Erro na requisição:', error);
    return throwError(() => error);
  };
}