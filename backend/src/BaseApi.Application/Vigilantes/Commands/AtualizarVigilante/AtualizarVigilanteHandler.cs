using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.AtualizarVigilante;

public class AtualizarVigilanteHandler(IVigilanteRepositorio repositorio)
    : IRequestHandler<AtualizarVigilanteCommand, Unit>
{
    public async Task<Unit> Handle(AtualizarVigilanteCommand command, CancellationToken ct)
    {
        var vigilante = await repositorio.ObterPorIdAsync(command.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Vigilante com Id '{command.Id}' não encontrado.");

        vigilante.NomeCompleto = command.NomeCompleto.Trim();
        vigilante.Cpf = command.Cpf.Trim();
        vigilante.Matricula = command.Matricula.Trim();
        vigilante.Arena = command.Arena.Trim();
        vigilante.Ativo = command.Ativo;
        vigilante.AtualizadoEm = DateTime.UtcNow;

        repositorio.Atualizar(vigilante);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}