using BaseApi.Application.Notificacoes.Queries.ObterNotificacaoPorId;
using MediatR;

namespace BaseApi.Application.Notificacoes.Queries.ListarNotificacao;

public record ListarNotificacaoQuery() : IRequest<List<NotificacaoDetalheDto>>;