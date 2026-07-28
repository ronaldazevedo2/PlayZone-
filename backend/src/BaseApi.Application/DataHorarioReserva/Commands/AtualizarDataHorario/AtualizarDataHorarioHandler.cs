using BaseApi.Application.DataHorarioReserva.Commands.AtualizarDataHorarioReserva;
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Commands.AtualizarDataHorarioReserva;

public class AtualizarDataHorarioReservaHandler(IDataHorarioReservaRepositorio repositorio)
    : IRequestHandler<AtualizarDataHorarioReservaCommand, Unit>
{
    public async Task<Unit> Handle(AtualizarDataHorarioReservaCommand command, CancellationToken ct)
    {
        var dataHorarioReserva = await repositorio.ObterPorIdAsync(command.DataHorarioReservaId)
            ?? throw new ExcecaoNaoEncontrado(
                $"Data/Horário com Id '{command.DataHorarioReservaId}' não encontrado.");

        // Atualiza os campos
        dataHorarioReserva.QuadraId = command.QuadraId;
        dataHorarioReserva.Data = command.Data;
        dataHorarioReserva.Horario = command.Horario;

        await repositorio.AtualizarAsync(dataHorarioReserva);

        return Unit.Value;
    }
}