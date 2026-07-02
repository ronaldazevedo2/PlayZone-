using BaseApi.Application.Notificacoes.Commands.ExcluirNotificacao;
using BaseApi.Domain.Entidades;
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Notificacoes.Commands.ExcluirNotificacao;

public class ExcluirNotificacaoHandler(INotificacaoRepositorio repositorio)
    : IRequestHandler<ExcluirNotificacaoCommand, Unit>
{
    public async Task<Unit> Handle(ExcluirNotificacaoCommand command, CancellationToken ct)
    {
        var Notificacao = await repositorio.ObterPorIdAsync(command.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Notificacao com Id '{command.Id}' não encontrado.");

        repositorio.Remover(Notificacao);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}