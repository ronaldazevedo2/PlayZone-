using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;

public class DadosSecretariaMap : IEntityTypeConfiguration<DadosSecretaria>
{
    public void Configure(EntityTypeBuilder<DadosSecretaria> builder)
    {
        builder.ToTable("DadosSecretaria");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Nome)
               .IsRequired()
               .HasMaxLength(100);

        builder.Property(x => x.Email)
               .IsRequired()
               .HasMaxLength(150);

        builder.Property(x => x.Contato)
               .HasMaxLength(20);

        builder.Property(x => x.Cep)
               .HasMaxLength(10);

        builder.Property(x => x.Endereço)
               .HasMaxLength(200);

        builder.Property(x => x.Numero)
               .HasMaxLength(10);

        builder.Property(x => x.Bairro)
               .HasMaxLength(100);

        builder.Property(x => x.Cidade)
               .HasMaxLength(100);
    }
}