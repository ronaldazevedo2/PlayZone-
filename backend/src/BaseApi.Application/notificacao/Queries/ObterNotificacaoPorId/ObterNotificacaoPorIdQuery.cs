using MediatR;

namespace BaseApi.Application.Notifiacoes.Queries.ObterNotificacaoPorId;

/// <summary>
/// Query para buscar um único Notificacao pelo Id.
/// Queries NUNCA alteram dados — apenas leem.
/// </summary>
public record ObterNotificacaoPorIdQuery(Guid Id) : IRequest<NotificacaoDetalheDto>;

/// <summary>DTO com todos os dados do Notificacao para exibição</summary>
public record NotificacaoDetalheDto(
    Guid Id,
   
    DateTime CriadoEm
);