using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;

public class NotificacaoConfiguracao : IEntityTypeConfiguration<Notificacao>
{
    public void Configure(EntityTypeBuilder<Notificacao> builder)
    {
        // Nome da tabela
        builder.ToTable("notificacoes");

        // Chave Primária
        builder.HasKey(n => n.Id);

        // Título da Notificação
        builder.Property(n => n.Titulo)
            .IsRequired()
            .HasMaxLength(150);

        // Mensagem principal
        builder.Property(n => n.Mensagem)
            .IsRequired()
            .HasMaxLength(500);

        // Data e Hora do envio
        builder.Property(n => n.DataEnvio)
            .IsRequired();

        // Status de Leitura (padrão como não lida/false)
        builder.Property(n => n.Lida)
            .HasDefaultValue(false);

        // ID do usuário destinatário
        builder.Property(n => n.UsuarioId)
            .IsRequired();
    }
}