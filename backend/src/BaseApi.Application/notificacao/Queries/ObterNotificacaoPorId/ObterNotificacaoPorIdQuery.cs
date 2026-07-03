using MediatR;

namespace BaseApi.Application.Notificacoes.Queries.ObterNotificacaoPorId; 
public record ObterNotificacaoPorIdQuery(Guid Id) : IRequest<NotificacaoDetalheDto>;

public record NotificacaoDetalheDto(Guid Id, DateTime CriadoEm)
{
    public NotificacaoDetalheDto(DateTime criadoEm) : this(Guid.Empty, criadoEm) { }
}
