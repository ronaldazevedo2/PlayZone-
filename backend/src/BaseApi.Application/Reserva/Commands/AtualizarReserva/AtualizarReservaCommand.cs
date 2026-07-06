using BaseApi.Application.Reserva.Commands.AtualizarReserva;
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Telefones.Commands.AtualizarTelefone;

public class AtualizarReservaHandler(IReservaRepositorio repositorio)
    : IRequestHandler<AtualizarReservaCommand, Unit>
{
    public async Task<Unit> Handle(AtualizarReservaCommand command, CancellationToken ct)
    {
        var reserva = await repositorio.ObterPorIdAsync(command.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Telefone com Id '{command.Id}' não encontrado.");

        // Atualiza apenas os campos permitidos
        reserva.QuadraId = command.QuadraId;
        reserva.DataAgendada = command.DataAgendada;
        reserva.HorarioAgendado = command.HorarioAgendado;
        

        repositorio.Atualizar(reserva);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}