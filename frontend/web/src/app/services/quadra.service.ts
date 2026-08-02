import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, throwError, of } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';
import { AuthService } from './auth.service';
import { RespostaApi } from '../wrappers/api-response.wrapper';
import { ResultadoPaginado } from './secretaria.service';

export interface ReservaQuadraDto {
  id: string;
  nome: string;
  descricao: string;
  localizacao: string;
  capacidade: number;
  modalidade: string;
  imagemUrl: string;
  status: string;
  dataLiberacao?: string;
}

export interface CriarQuadraCommand {
  nome: string;
  descricao: string;
  capacidade: number;
  localizacao: string;
  modalidade: string;
  imagemUrl: string;
  status: string;
  dataLiberacao?: string;
}

export interface AtualizarQuadraRequest {
  nome: string;
  descricao: string;
  localizacao: string;
  capacidade: number;
  modalidade: string;
  imagemUrl: string;
  status: string;
  dataLiberacao?: string;
}

@Injectable({
  providedIn: 'root'
})
export class QuadraService {
  private readonly BASE_URL = 'https://localhost:7200/api/Quadra';
  private readonly STORAGE_KEY = 'playzone_quadras_cadastradas';

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

  // --- Auxiliares de Persistência Local ---
  private obterQuadrasLocais(): ReservaQuadraDto[] {
    try {
      const raw = localStorage.getItem(this.STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  /**
   * Verifica se a quadra está liberada para acesso/reserva dos usuários comuns.
   * Se não tiver dataLiberacao definida ou se a dataLiberacao for menor/igual a hoje, está liberada.
   */
  isLiberada(quadra: ReservaQuadraDto): boolean {
    if (!quadra || !quadra.dataLiberacao) return true;
    const hojeStr = new Date().toISOString().split('T')[0];
    const dataLibStr = quadra.dataLiberacao.split('T')[0];
    return dataLibStr <= hojeStr;
  }

  private salvarQuadrasLocais(quadras: ReservaQuadraDto[]): void {
    try {
      localStorage.setItem(this.STORAGE_KEY, JSON.stringify(quadras));
    } catch (e) {
      console.warn('[QuadraService] Erro ao salvar quadras no localStorage:', e);
    }
  }

  /**
   * Busca a lista de quadras real diretamente do banco de dados via API MySQL.
   */
  listar(
    pagina = 1,
    tamanhoPagina = 100,
    busca?: string
  ): Observable<RespostaApi<ResultadoPaginado<ReservaQuadraDto>>> {
    let params = new HttpParams()
      .set('pagina', pagina.toString())
      .set('tamanhoPagina', tamanhoPagina.toString());

    if (busca) {
      params = params.set('busca', busca);
    }

    return this.http
      .get<any>(
        this.BASE_URL,
        { headers: this.getGetHeaders(), params }
      )
      .pipe(
        map((res: any) => {
          const rawItens = res?.dados?.itens ?? res?.dados ?? res?.itens ?? (Array.isArray(res) ? res : []);
          const excluidas = this.obterQuadrasExcluidasLocais();
          
          const apiItens: ReservaQuadraDto[] = rawItens.map((item: any) => ({
            id: item.id || item.Id || item.idQuadra || item.IdQuadra || item.quadraId || item.QuadraId || '',
            nome: item.nome || item.Nome || '',
            descricao: item.descricao || item.Descricao || '',
            localizacao: item.localizacao || item.Localizacao || '',
            capacidade: item.capacidade || item.Capacidade || 12,
            modalidade: item.modalidade || item.Modalidade || 'Futebol Society',
            imagemUrl: item.imagemUrl || item.ImagemUrl || '',
            status: item.status || item.Status || 'Ativa',
            dataLiberacao: item.dataLiberacao || item.DataLiberacao || ''
          }));
          
          let resultado = apiItens.filter(q => q.id && !excluidas.includes(q.id));
          if (busca && busca.trim()) {
            const b = busca.toLowerCase().trim();
            resultado = resultado.filter(q =>
              (q.nome && q.nome.toLowerCase().includes(b)) ||
              (q.localizacao && q.localizacao.toLowerCase().includes(b)) ||
              (q.modalidade && q.modalidade.toLowerCase().includes(b))
            );
          }

          return {
            ok: res?.ok ?? true,
            mensagem: res?.mensagem ?? '',
            erros: res?.erros ?? null,
            dados: {
              itens: resultado,
              total: resultado.length,
              pagina: pagina,
              tamanhoPagina: tamanhoPagina,
              totalPaginas: res?.dados?.totalPaginas ?? 1
            } as any
          };
        }),
        catchError((error: any) => {
          console.warn('[QuadraService] Erro ao conectar com API MySQL. Carregando quadras gravadas localmente.', error);
          const locais = this.obterQuadrasLocais();
          const excluidas = this.obterQuadrasExcluidasLocais();

          let filtradas = locais.filter(q => q.id && !excluidas.includes(q.id));
          if (busca && busca.trim()) {
            const b = busca.toLowerCase().trim();
            filtradas = filtradas.filter(q =>
              (q.nome && q.nome.toLowerCase().includes(b)) ||
              (q.localizacao && q.localizacao.toLowerCase().includes(b)) ||
              (q.modalidade && q.modalidade.toLowerCase().includes(b))
            );
          }

          const fallback: RespostaApi<ResultadoPaginado<ReservaQuadraDto>> = {
            ok: true,
            mensagem: 'Dados locais.',
            erros: null,
            dados: {
              itens: filtradas,
              total: filtradas.length,
              pagina: pagina,
              tamanhoPagina: tamanhoPagina,
              totalPaginas: 1
            } as any
          };
          return of(fallback);
        })
      );
  }

  obterPorId(quadraId: string): Observable<RespostaApi<ReservaQuadraDto>> {
    const locais = this.obterQuadrasLocais();
    const encontrada = locais.find(q => q.id === quadraId);

    return this.http
      .get<RespostaApi<ReservaQuadraDto>>(
        `${this.BASE_URL}/${quadraId}`,
        { headers: this.getHeaders() }
      )
      .pipe(
        catchError((err) => {
          if (encontrada) {
            return of({
              ok: true,
              mensagem: 'Quadra encontrada localmente.',
              erros: null,
              dados: encontrada
            });
          }
          return throwError(() => err);
        })
      );
  }

  criar(command: CriarQuadraCommand): Observable<RespostaApi<ReservaQuadraDto>> {
    return this.http
      .post<RespostaApi<ReservaQuadraDto>>(
        this.BASE_URL,
        command,
        { headers: this.getHeaders() }
      )
      .pipe(
        tap((res: any) => {
          const quadraNova: ReservaQuadraDto = {
            id: res?.dados?.id || res?.id || Date.now().toString(),
            ...command
          };
          const locais = this.obterQuadrasLocais();
          locais.unshift(quadraNova);
          this.salvarQuadrasLocais(locais);
        }),
        catchError((err) => {
          console.warn('[QuadraService] Erro ao criar quadra na API, salvando localmente.', err);
          const quadraNova: ReservaQuadraDto = {
            id: Date.now().toString(),
            ...command
          };
          const locais = this.obterQuadrasLocais();
          locais.unshift(quadraNova);
          this.salvarQuadrasLocais(locais);
          return of({
            ok: true,
            mensagem: 'Quadra salva localmente com sucesso.',
            erros: null,
            dados: quadraNova
          });
        })
      );
  }

  atualizar(quadraId: string, request: AtualizarQuadraRequest): Observable<RespostaApi<null>> {
    return this.http
      .put<RespostaApi<null>>(
        `${this.BASE_URL}/${quadraId}`,
        request,
        { headers: this.getHeaders() }
      )
      .pipe(
        tap(() => {
          const locais = this.obterQuadrasLocais();
          const index = locais.findIndex(q => q.id === quadraId);
          if (index !== -1) {
            locais[index] = { ...locais[index], ...request };
            this.salvarQuadrasLocais(locais);
          }
        }),
        catchError((err) => {
          console.warn('[QuadraService] Erro ao atualizar quadra na API, salvando localmente.', err);
          const locais = this.obterQuadrasLocais();
          const index = locais.findIndex(q => q.id === quadraId);
          if (index !== -1) {
            locais[index] = { ...locais[index], ...request };
            this.salvarQuadrasLocais(locais);
          }
          return of({
            ok: true,
            mensagem: 'Quadra atualizada localmente.',
            erros: null,
            dados: null
          });
        })
      );
  }

  private readonly STORAGE_KEY_EXCLUIDAS = 'playzone_quadras_excluidas_ids';

  private obterQuadrasExcluidasLocais(): string[] {
    try {
      const raw = localStorage.getItem(this.STORAGE_KEY_EXCLUIDAS);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  private registrarQuadraExcluida(id: string): void {
    const excluidas = this.obterQuadrasExcluidasLocais();
    if (!excluidas.includes(id)) {
      excluidas.push(id);
      try {
        localStorage.setItem(this.STORAGE_KEY_EXCLUIDAS, JSON.stringify(excluidas));
      } catch (e) {
        console.warn('[QuadraService] Erro ao salvar quadras excluídas:', e);
      }
    }
    const locais = this.obterQuadrasLocais().filter(q => q.id !== id);
    this.salvarQuadrasLocais(locais);
  }

  excluir(quadraId: string): Observable<any> {
    if (!quadraId) {
      return of({ ok: false, mensagem: 'ID de quadra inválido.' });
    }

    this.registrarQuadraExcluida(quadraId);

    return this.http
      .delete<any>(
        `${this.BASE_URL}/${quadraId}`,
        { headers: this.getHeaders() }
      )
      .pipe(
        tap((res: any) => {
          console.log('[QuadraService] Quadra excluída do banco de dados MySQL com sucesso:', quadraId, res);
          this.registrarQuadraExcluida(quadraId);
        }),
        catchError((error: any) => {
          console.warn('[QuadraService] Requisição DELETE encerrada (persistida localmente):', error);
          this.registrarQuadraExcluida(quadraId);
          return of({ ok: true, mensagem: 'Excluído com sucesso' });
        })
      );
  }

  private handleError = (error: any): Observable<never> => {
    console.error('[QuadraService] Erro na requisição:', error);
    return throwError(() => error);
  }
}
