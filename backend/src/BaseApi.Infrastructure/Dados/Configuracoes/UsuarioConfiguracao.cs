using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BaseApi.Infrastructure.Dados.Configuracoes;

public class UsuarioConfiguracao : IEntityTypeConfiguration<Usuario>
{
    public void Configure(EntityTypeBuilder<Usuario> builder)
    {
        builder.ToTable("usuarios");

        builder.HasKey(u => u.Id);

        builder.Property(u => u.NomeCompleto)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(u => u.Cpf)
     .IsRequired()
     .HasMaxLength(11);

        builder.Property(u => u.Telefone)
            .IsRequired()
            .HasMaxLength(20);

        builder.HasIndex(u => u.Cpf)
            .IsUnique();

        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(u => u.SenhaHash)
            .IsRequired();

        builder.Property(u => u.TokenRedefinicaoSenha)
            .HasMaxLength(100);

        // Índices únicos
        builder.HasIndex(u => u.Email)
            .IsUnique();

        builder.HasIndex(u => u.Cpf)
            .IsUnique();

        // Relacionamento N:1 com Perfil
        builder.HasOne(u => u.Perfil)
               .WithMany(p => p.Usuarios)
               .HasForeignKey(u => u.PerfilId)
               .OnDelete(DeleteBehavior.Restrict);
    }
}