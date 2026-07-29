using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BaseApi.Infrastructure.Dados.Configuracoes;

public class DataHorarioReservaConfiguracao : IEntityTypeConfiguration<DataHorarioReserva>
{
    public void Configure(EntityTypeBuilder<DataHorarioReserva> builder)
    {
        // Nome da tabela
        builder.ToTable("data_horario_reservas");

        // Chave primária
        builder.HasKey(d => d.DataHorarioReservaId);

        // Quadra
        builder.Property(d => d.QuadraId)
            .IsRequired();

        // Relacionamento com Quadra
        builder.HasOne<Quadra>()
            .WithMany()
            .HasForeignKey(d => d.QuadraId)
            .OnDelete(DeleteBehavior.Cascade);

        // Data
        builder.Property(d => d.Data)
            .IsRequired()
            .HasColumnType("date");

        // Horário
        builder.Property(d => d.Horario)
            .IsRequired()
            .HasColumnType("time");

        // Impede horários duplicados para a mesma quadra na mesma data
        builder.HasIndex(d => new { d.QuadraId, d.Data, d.Horario })
            .IsUnique();
    }
}