import { Component, OnInit } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-admin-layout',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './admin-layout.component.html',
  styleUrl: './admin-layout.component.css'
})
export class AdminLayoutComponent implements OnInit {
  adminName = 'Admin';
  adminRole = 'Administrador';
  currentDate = '';
  mensagensPendentesCount = 7;

  constructor(private router: Router, private authService: AuthService) {}

  ngOnInit(): void {
    const session = this.authService.getSession();
    if (!session) {
      this.router.navigate(['/login']);
      return;
    }

    this.adminName = session.nome || 'Admin';
    this.adminRole = session.role === 'Admin' ? 'Administrador' : session.role;

    const options: Intl.DateTimeFormatOptions = {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    };
    const today = new Date();
    const rawDate = today.toLocaleDateString('pt-BR', options);
    this.currentDate = rawDate.charAt(0).toUpperCase() + rawDate.slice(1);
  }

  logout(): void {
    this.authService.logout();
  }

  triggerAction(actionName: string): void {
    alert(`Ação executada: ${actionName} (MOCK)`);
  }
}
