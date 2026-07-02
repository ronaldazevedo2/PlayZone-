using MediatR;

namespace BaseApi.Application.Notificacoes.Commands.ExcluirNotificacao;

public record ExcluirNotificacaoCommand(Guid Id) : IRequest<Unit>;