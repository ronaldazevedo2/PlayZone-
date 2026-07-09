using BaseApi.Domain.Excecoes;
using MediatR;

namespace BaseApi.Application.Secretaria.Commands.AtualizarSecretaria;

public class AtualizarSecretariaHandler(IDadosSecretariaRepositorio repositorio) : IRequestHandler<AtualizarSecretariaCommand, Unit>
{
    public async Task<Unit> Handle(AtualizarSecretariaCommand command, CancellationToken ct)
    {
        var secretaria = await repositorio.ObterPorIdAsync(command.SecretariaId, ct)
            ?? throw new ExcecaoNaoEncontrado($"Secretaria com Id '{command.SecretariaId}' não encontrado.");

        secretaria.SecretariaId = command.SecretariaId;
        secretaria.Nome = command.Nome;
        secretaria.Email = command.Email.ToLowerInvariant().Trim();
        secretaria.Contato = command.Contato;
        secretaria.Cep = command.Cep;
        secretaria.Endereço = command.Endereço;
        secretaria.Numero = command.Numero;
        secretaria.Bairro = command.Bairro;
        secretaria.Cidade = command.Cidade;

        repositorio.Atualizar(secretaria);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}
