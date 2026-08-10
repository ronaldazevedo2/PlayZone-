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
      
      // Vigilante
      { path: 'vigilante', component: VigilanteComponent },
      { path: 'vigilante/novo', loadComponent: () => import('./components/vigilante/vigilante-form/vigilante-form.component').then(m => m.VigilanteFormComponent) },
      { path: 'vigilante/editar/:id', loadComponent: () => import('./components/vigilante/vigilante-form/vigilante-form.component').then(m => m.VigilanteFormComponent) },

      // Usuários
      { path: 'usuarios', loadComponent: () => import('./components/usuarios/usuarios.component').then(m => m.UsuariosComponent) },
      { path: 'usuarios/novo', loadComponent: () => import('./components/usuarios/usuario-form/usuario-form.component').then(m => m.UsuarioFormComponent) },
      { path: 'usuarios/editar/:id', loadComponent: () => import('./components/usuarios/usuario-form/usuario-form.component').then(m => m.UsuarioFormComponent) },

      // Dados (Secretaria / Perfil)
      { path: 'dados', component: DadosComponent },
      { path: 'dados/editar/:id', loadComponent: () => import('./components/dados/dados-form/dados-form.component').then(m => m.DadosFormComponent) },

      // Quadras
      { path: 'quadras', component: QuadrasComponent },
      { path: 'quadras/nova', loadComponent: () => import('./components/quadras/quadra-form/quadra-form.component').then(m => m.QuadraFormComponent) },
      { path: 'quadras/editar/:id', loadComponent: () => import('./components/quadras/quadra-form/quadra-form.component').then(m => m.QuadraFormComponent) },

      // Reservas
      { path: 'reservas', loadComponent: () => import('./components/reservas/reservas.component').then(m => m.ReservasComponent) },
      { path: 'reservas/quadra/:id', loadComponent: () => import('./components/reservas/reserva-quadra-detalhes/reserva-quadra-detalhes.component').then(m => m.ReservaQuadraDetalhesComponent) },
      { path: 'reservas/nova', loadComponent: () => import('./components/reservas/reserva-form/reserva-form.component').then(m => m.ReservaFormComponent) },
      { path: 'reservas/editar/:id', loadComponent: () => import('./components/reservas/reserva-form/reserva-form.component').then(m => m.ReservaFormComponent) },

      // Relatórios
      { path: 'relatorios', redirectTo: 'relatorios/usuarios', pathMatch: 'full' },
      { path: 'relatorios/usuarios', loadComponent: () => import('./components/relatorios/relatorio-usuarios/relatorio-usuarios.component').then(m => m.RelatorioUsuariosComponent) },
      { path: 'relatorios/quadras', loadComponent: () => import('./components/relatorios/relatorio-quadras/relatorio-quadras.component').then(m => m.RelatorioQuadrasComponent) },
      { path: 'relatorios/reservas', loadComponent: () => import('./components/relatorios/relatorio-reservas/relatorio-reservas.component').then(m => m.RelatorioReservasComponent) },
      { path: 'relatorios/vigilantes', loadComponent: () => import('./components/relatorios/relatorio-vigilantes/relatorio-vigilantes.component').then(m => m.RelatorioVigilantesComponent) },

      { path: '', redirectTo: 'dashboard', pathMatch: 'full' }
    ]
  },
  { path: '**', redirectTo: 'login' }
];
