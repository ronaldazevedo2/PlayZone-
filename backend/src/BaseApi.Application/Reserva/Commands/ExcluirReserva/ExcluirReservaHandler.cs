using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Telefones.Commands.ExcluirTelefone;

public class ExcluirReservaHandler(IReservaRepositorio repositorio)
    : IRequestHandler<ExcluirReservaCommand, Unit>
{
    public async Task<Unit> Handle(ExcluirReservaCommand command, CancellationToken ct)
    {
        var reserva = await repositorio.ObterPorIdAsync(command.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Reserva com Id '{command.Id}' não encontrado.");

        repositorio.Remover(reserva);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}