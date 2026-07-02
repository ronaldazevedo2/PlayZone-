using MediatR;

namespace BaseApi.Application.Notificacoes.Commands.AtualizarNotificacao;

public record AtualizarNotificacaoCommand(
    Guid Id,

) : IRequest<Unit>;