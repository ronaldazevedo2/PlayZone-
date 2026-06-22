using BaseApi.Domain.Excecoes;
using MediatR;

namespace BaseApi.Application.Secretaria.Commands.ExcluirSecretaria;

public class ExcluirSecretariaHandler(IDadosSecretariaRepositorio repositorio) : IRequestHandler<ExcluirSecretariaCommand, Unit>
{
    public async Task<Unit> Handle(ExcluirSecretariaCommand command, CancellationToken ct)
    {
        var secretaria = await repositorio.ObterPorIdAsync(command.SecretariaId, ct)
            ?? throw new ExcecaoNaoEncontrado($"Secretaria com Id '{command.SecretariaId}' não encontrado.");

        repositorio.Remover(secretaria);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}
