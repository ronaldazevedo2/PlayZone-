using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.ExcluirVigilante;

public class ExcluirVigilanteHandler(IVigilanteRepositorio repositorio)
    : IRequestHandler<ExcluirVigilanteCommand, Unit>
{
    public async Task<Unit> Handle(ExcluirVigilanteCommand command, CancellationToken ct)
    {
        var vigilante = await repositorio.ObterPorIdAsync(command.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Vigilante com Id '{command.Id}' não encontrado.");

        repositorio.Remover(vigilante);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}