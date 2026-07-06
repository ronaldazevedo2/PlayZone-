import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, tap, catchError, throwError } from 'rxjs';

export interface LoginRequest {
  email: string;
  senha: string;
}

export interface LoginResponse {
  token: string;
  expiracao: string;
  nome?: string;
  email?: string;
  role?: string;
}

export interface UserSession {
  token: string;
  expiracao: string;
  nome: string;
  email: string;
  role: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly API_URL = 'https://localhost:7200/api';
  private readonly SESSION_KEY = 'currentUser';

  constructor(private http: HttpClient, private router: Router) { }

  login(email: string, senha: string): Observable<LoginResponse> {
    const body: LoginRequest = { email, senha };
    return this.http.post<LoginResponse>(`${this.API_URL}/Autenticacao/login`, body).pipe(
      tap((response: any) => {
        // The API returns { ok: true, mensagem: "...", dados: { accessToken: "...", ... } }
        const apiDados = response?.dados;
        const token = apiDados?.accessToken || response?.token || response?.accessToken;
        
        if (!token) {
          console.warn('AuthService: login response missing token', response);
          return;
        }
        
        const decoded = this.decodeToken(token);
        const session: UserSession = {
          token: token,
          expiracao: apiDados?.expiraEm || response?.expiracao || (decoded?.['exp'] as number)?.toString() || '',
          nome: apiDados?.nomeCompleto || response?.nome || (decoded?.['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] as string) || 'Admin',
          email: apiDados?.email || response?.email || (decoded?.['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] as string) || email,
          role: apiDados?.perfil || response?.role || (decoded?.['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] as string) || 'Admin'
        };
        
        console.log('AuthService: saving session', session);
        localStorage.setItem(this.SESSION_KEY, JSON.stringify(session));
        localStorage.setItem('jwtToken', token);
      }),
      catchError((error) => {
        console.error('Login error:', error);
        return throwError(() => error);
      })
    );
  }

  logout(): void {
    localStorage.removeItem(this.SESSION_KEY);
    this.router.navigate(['/login']);
  }

  isLoggedIn(): boolean {
    const session = this.getSession();
    if (!session) return false;

    // Check if token is expired
    const decoded = this.decodeToken(session.token);
    const exp = decoded?.['exp'] as number | undefined;
    if (exp) {
      const now = Math.floor(Date.now() / 1000);
      if (exp < now) {
        this.logout();
        return false;
      }
    }
    return true;
  }

  getSession(): UserSession | null {
    const raw = localStorage.getItem(this.SESSION_KEY);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as UserSession;
    } catch {
      return null;
    }
  }

  getToken(): string | null {
    // Try to retrieve token from stored session first
    const sessionToken = this.getSession()?.token ?? null;
    if (sessionToken) {
      console.log('AuthService: getToken -> (from session)', sessionToken);
      return sessionToken;
    }
    // Fallback: read raw token stored separately
    const rawToken = localStorage.getItem('jwtToken');
    console.log('AuthService: getToken -> (from raw)', rawToken);
    return rawToken ?? null;
  }

  private decodeToken(token: string): Record<string, unknown> | null {
    try {
      const payload = token.split('.')[1];
      const decoded = atob(payload.replace(/-/g, '+').replace(/_/g, '/'));
      return JSON.parse(decoded);
    } catch {
      return null;
    }
  }
}
