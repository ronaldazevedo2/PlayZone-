using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BaseApi.Infrastructure.Dados.Configuracoes;

public class PerfilConfiguracao : IEntityTypeConfiguration<Perfil>
{
    public void Configure(EntityTypeBuilder<Perfil> builder)
    {
        builder.ToTable("perfis");
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Nome).IsRequired().HasMaxLength(50);
        builder.Property(p => p.Descricao).HasMaxLength(200);
        builder.HasIndex(p => p.Nome).IsUnique();
    }
}
