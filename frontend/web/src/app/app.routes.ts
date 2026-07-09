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
      { path: 'dados', component: DadosComponent },
      { path: 'quadras', component: QuadrasComponent },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' }
    ]
  },
  { path: '**', redirectTo: 'login' }
];
