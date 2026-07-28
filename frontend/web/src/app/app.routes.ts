import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { AdminLayoutComponent } from './layout/admin-layout.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { VigilanteComponent } from './components/vigilante/vigilante.component';
import { DadosComponent } from './components/dados/dados.component';
import { QuadrasComponent } from './components/quadras/quadras.component';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
    path: '',
    component: AdminLayoutComponent,
    canActivate: [authGuard],
    children: [
      { path: 'dashboard', component: DashboardComponent },
      { path: 'vigilante', component: VigilanteComponent },
      { path: 'usuarios', loadComponent: () => import('./components/usuarios/usuarios.component').then(m => m.UsuariosComponent) },
      { path: 'dados', component: DadosComponent },
      { path: 'quadras', component: QuadrasComponent },
      { path: 'quadras/nova', loadComponent: () => import('./components/quadras/quadra-form/quadra-form.component').then(m => m.QuadraFormComponent) },
      { path: 'quadras/editar/:id', loadComponent: () => import('./components/quadras/quadra-form/quadra-form.component').then(m => m.QuadraFormComponent) },
      { path: 'reservas', loadComponent: () => import('./components/reservas/reservas.component').then(m => m.ReservasComponent) },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' }
    ]
  },
  { path: '**', redirectTo: 'login' }
];
