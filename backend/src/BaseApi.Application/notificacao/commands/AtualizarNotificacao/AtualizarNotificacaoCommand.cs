using MediatR;

namespace BaseApi.Application.Notificacoes.Commands.AtualizarNotificacao;

public record AtualizarNotificacaoCommand(Guid Id, string Titulo, AtualizarNotificacaoRequest Request) : IRequest<Unit>
{
    public AtualizarNotificacaoRequest Request { get; init; } = Request ?? throw new ArgumentNullException(nameof(Request));
}

public class AtualizarNotificacaoRequest
{
}
