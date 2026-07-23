import { Injectable } from '@angular/core';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import { Usuario } from '../components/usuarios/usuarios.component';

@Injectable({
  providedIn: 'root'
})
export class ExportService {

  /**
   * Exporta a lista de usuários exibida em tela para PDF formatado como relatório institucional.
   */
  exportarUsuariosPdf(usuarios: Usuario[], filtroStatus: string, termoBusca: string): void {
    const doc = new jsPDF({
      orientation: 'portrait',
      unit: 'mm',
      format: 'a4'
    });

    const pageWidth = doc.internal.pageSize.getWidth();
    const now = new Date();
    const dataHoraStr = now.toLocaleDateString('pt-BR') + ' ' + now.toLocaleTimeString('pt-BR');

    // Faixa Superior / Header institucional
    doc.setFillColor(40, 167, 69); // Verde PlayZone (#28a745)
    doc.rect(0, 0, pageWidth, 14, 'F');

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(14);
    doc.setTextColor(255, 255, 255);
    doc.text('PLAYZONE', 14, 9);

    doc.setFontSize(9);
    doc.setFont('helvetica', 'normal');
    doc.text('Sistema de Gestão Esportiva', pageWidth - 14, 9, { align: 'right' });

    // Título do Documento
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(18);
    doc.setTextColor(30, 41, 59); // #1e293b
    doc.text('Relatório de Usuários', 14, 24);

    // Metadados do Relatório
    doc.setFontSize(9);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(100, 116, 139); // #64748b

    let metaY = 30;
    doc.text(`Data e Hora de Geração: ${dataHoraStr}`, 14, metaY);
    doc.text(`Filtro de Status: ${filtroStatus}`, 14, metaY + 5);
    if (termoBusca && termoBusca.trim() !== '') {
      doc.text(`Termo de Busca: "${termoBusca.trim()}"`, 14, metaY + 10);
      metaY += 5;
    }
    doc.text(`Quantidade Total de Registros: ${usuarios.length}`, 14, metaY + 10);

    // Estrutura das Colunas e Linhas da Tabela
    const tableColumns = [
      { header: 'Nome', dataKey: 'nome' },
      { header: 'E-mail', dataKey: 'email' },
      { header: 'Telefone', dataKey: 'telefone' },
      { header: 'CPF', dataKey: 'cpf' },
      { header: 'Status', dataKey: 'status' },
      { header: 'Data de Cadastro', dataKey: 'dataCriacao' }
    ];

    const tableRows = usuarios.map(u => {
      let dataCad = '-';
      if (u.dataCriacao) {
        try {
          const d = new Date(u.dataCriacao);
          dataCad = !isNaN(d.getTime()) ? d.toLocaleDateString('pt-BR') : u.dataCriacao;
        } catch {
          dataCad = u.dataCriacao;
        }
      }

      return {
        nome: u.nomeCompleto || '-',
        email: u.email || '-',
        telefone: u.telefone || '-',
        cpf: u.cpf || '-',
        status: u.ativo ? 'Ativo' : 'Inativo',
        dataCriacao: dataCad
      };
    });

    // Geração da Tabela com AutoTable
    autoTable(doc, {
      columns: tableColumns,
      body: tableRows,
      startY: metaY + 16,
      theme: 'grid',
      headStyles: {
        fillColor: [30, 41, 59], // #1e293b
        textColor: [255, 255, 255],
        fontSize: 9,
        fontStyle: 'bold',
        halign: 'left'
      },
      bodyStyles: {
        fontSize: 8.5,
        textColor: [51, 65, 85]
      },
      alternateRowStyles: {
        fillColor: [248, 250, 252]
      },
      columnStyles: {
        0: { cellWidth: 42 }, // Nome
        1: { cellWidth: 46 }, // Email
        2: { cellWidth: 28 }, // Telefone
        3: { cellWidth: 28 }, // CPF
        4: { cellWidth: 18, halign: 'center' }, // Status
        5: { cellWidth: 24, halign: 'center' }  // Data
      },
      didDrawPage: (data) => {
        // Rodapé em cada página
        const pageHeight = doc.internal.pageSize.getHeight();
        doc.setFontSize(8);
        doc.setFont('helvetica', 'normal');
        doc.setTextColor(148, 163, 184); // #94a3b8

        doc.setDrawColor(226, 232, 240);
        doc.line(14, pageHeight - 12, pageWidth - 14, pageHeight - 12);

        doc.text('Documento gerado automaticamente pelo sistema PlayZone.', 14, pageHeight - 6);
        const pageNumber = (doc as any).internal.getNumberOfPages();
        doc.text(`Página ${data.pageNumber} de ${pageNumber}`, pageWidth - 14, pageHeight - 6, { align: 'right' });
      }
    });

    // Download Automático
    const timestamp = now.toISOString().replace(/[-:T.]/g, '').slice(0, 14);
    doc.save(`relatorio_usuarios_${timestamp}.pdf`);
  }
}
