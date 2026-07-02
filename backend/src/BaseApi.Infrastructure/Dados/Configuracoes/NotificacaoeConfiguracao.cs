using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BaseApi.Infrastructure.Dados.Configuracoes;

/// <summary>
/// Define como a entidade Telefone é mapeada no banco de dados.
/// Aqui você define o nome da tabela, tamanhos, índices, etc.
/// </summary>
public class NotificacaoConfiguracao : IEntityTypeConfiguration<Notificacao>
{
    public void Configure(EntityTypeBuilder<Notificacao> builder)
    {
        // Nome da tabela no banco
        builder.ToTable("Notificacoes");

        // Chave primária
        builder.HasKey(t => t.Id);

       
}