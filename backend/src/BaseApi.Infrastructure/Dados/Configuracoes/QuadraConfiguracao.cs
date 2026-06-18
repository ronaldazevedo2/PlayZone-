using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Infrastructure.Dados.Configuracoes
{
    public class QuadraConfiguracao : IEntityTypeConfiguration<Quadra>
    {
        public void Configure(EntityTypeBuilder<Quadra> builder)
        {
            // Nome da tabela no banco
            builder.ToTable("Quadras");

            // Chave primária
            builder.HasKey(q => q.Id);

            builder.Property(q => q.Nome)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(q => q.Descricao)
                .HasMaxLength(500);

            builder.Property(q => q.Capacidade)
                .IsRequired();

            builder.Property(q => q.Localizacao)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(q => q.Modalidade)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(q => q.ImagemUrl)
                .HasMaxLength(500);
        }

    }
}
