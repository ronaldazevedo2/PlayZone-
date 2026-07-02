import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

interface Guard {
  name: string;
  shift: string;
  status: 'Ativo' | 'Inativo' | 'De Folga';
  lastCheckin: string;
}

@Component({
  selector: 'app-vigilante',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './vigilante.component.html',
  styleUrl: './vigilante.component.css'
})
export class VigilanteComponent {
  // Guards list (Vigilante tab)
  guards: Guard[] = [
    { name: 'Marcos Souza', shift: 'Noturno A (18:00 - 06:00)', status: 'Ativo', lastCheckin: '15 min atrás - Quadra Society 1' },
    { name: 'Thiago Alves', shift: 'Noturno B (18:00 - 06:00)', status: 'Ativo', lastCheckin: '5 min atrás - Vestiário Masculino' },
    { name: 'Ronaldo Azevedo', shift: 'Noturno A (18:00 - 06:00)', status: 'Ativo', lastCheckin: '22 min atrás - Portaria Principal' },
    { name: 'Roberto Lima', shift: 'Diurno B (06:00 - 18:00)', status: 'De Folga', lastCheckin: 'Ontem - Portaria Principal' }
  ];

  registerGuardIncident(): void {
    const desc = prompt('Descreva a ocorrência do vigilante:');
    if (desc) {
      alert('Ocorrência de vigilância registrada com sucesso!');
    }
  }

  addNewGuard(): void {
    const name = prompt('Digite o nome do novo vigilante:');
    if (name) {
      const shift = prompt('Digite o turno (Ex: Noturno A):') || 'Geral';
      this.guards.unshift({
        name,
        shift,
        status: 'Ativo',
        lastCheckin: 'Recém cadastrado - Aguardando check-in'
      });
      alert(`Vigilante ${name} adicionado com sucesso!`);
    }
  }
}
