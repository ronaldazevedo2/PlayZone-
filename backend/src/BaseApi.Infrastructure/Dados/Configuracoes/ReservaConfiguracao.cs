using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BaseApi.Infrastructure.Configuracoes;

public class ReservaConfiguracao : IEntityTypeConfiguration<Reserva>
{
    public void Configure(EntityTypeBuilder<Reserva> builder)
    {
        // Nome da tabela no banco
        builder.ToTable("reservas");

        // Chave primária
        builder.HasKey(r => r.Id);

        builder.Property(r => r.QuadraId)
            .IsRequired();

        builder.Property(r => r.DataAgendada)
            .IsRequired()
            .HasColumnType("date");

        builder.Property(r => r.HorarioAgendado)
            .IsRequired()
            .HasColumnType("time");

        // Relacionamento: uma Reserva pertence a uma Quadra
        builder.HasOne<Quadra>()
            .WithMany()
            .HasForeignKey(r => r.QuadraId)
            .OnDelete(DeleteBehavior.Restrict);

        // Impede duas reservas no mesmo horário na mesma quadra
        builder.HasIndex(r => new { r.QuadraId, r.DataAgendada, r.HorarioAgendado })
            .IsUnique();
    }
}