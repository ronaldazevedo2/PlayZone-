import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent implements OnInit {
  email = '';
  password = '';
  showPassword = false;
  errorMessage = '';
  isLoading = false;
  rememberMe = false;

  private readonly REMEMBERED_EMAIL_KEY = 'rememberedEmail';

  constructor(private router: Router, private authService: AuthService) {}

  ngOnInit(): void {
    // Redireciona automaticamente se já estiver logado
    if (this.authService.isLoggedIn()) {
      this.router.navigate(['/dashboard']);
      return;
    }

    // Carrega o e-mail salvo se existir
    const savedEmail = localStorage.getItem(this.REMEMBERED_EMAIL_KEY);
    if (savedEmail) {
      this.email = savedEmail;
      this.rememberMe = true;
    }
  }

  togglePasswordVisibility(): void {
    this.showPassword = !this.showPassword;
  }

  onSubmit(): void {
    if (!this.email || !this.password) {
      this.errorMessage = 'Por favor, preencha todos os campos.';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    this.authService.login(this.email, this.password).subscribe({
      next: () => {
        // Trata o "Lembrar de mim"
        if (this.rememberMe) {
          localStorage.setItem(this.REMEMBERED_EMAIL_KEY, this.email);
        } else {
          localStorage.removeItem(this.REMEMBERED_EMAIL_KEY);
        }
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.isLoading = false;
        if (err.status === 401 || err.status === 403) {
          this.errorMessage = 'E-mail ou senha incorretos.';
        } else if (err.status === 0) {
          this.errorMessage = 'Não foi possível conectar ao servidor. Verifique se a API está em execução.';
        } else {
          this.errorMessage = err.error?.message || err.error?.titulo || 'Ocorreu um erro ao fazer login. Tente novamente.';
        }
      }
    });
  }
}
