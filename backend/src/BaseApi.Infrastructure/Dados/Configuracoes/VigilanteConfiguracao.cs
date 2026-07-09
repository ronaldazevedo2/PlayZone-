using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BaseApi.Infrastructure.Dados.Configuracoes
{
    public class VigilanteConfiguracao : IEntityTypeConfiguration<Vigilantes>
    {
        public void Configure(EntityTypeBuilder<Vigilantes> builder)
        {
            // Nome da tabela
            builder.ToTable("vigilantes");

            // Chave primária
            builder.HasKey(v => v.Id);

            // Configuração das colunas
            builder.Property(v => v.NomeCompleto)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(v => v.Cpf)
                .IsRequired()
                .HasMaxLength(14);

            builder.Property(v => v.Email)
                .IsRequired()
                .HasMaxLength(150);

            builder.Property(v => v.Telefone)
                .IsRequired()
                .HasMaxLength(20);

            builder.Property(v => v.FotoPerfil)
                .HasMaxLength(500);

            builder.Property(v => v.Ativo)
                .IsRequired();

            builder.Property(v => v.DataNascimento)
                .IsRequired();

            // Índices
            builder.HasIndex(v => v.Cpf)
                .IsUnique();

            builder.HasIndex(v => v.Email)
                .IsUnique();
        }
    }
}
