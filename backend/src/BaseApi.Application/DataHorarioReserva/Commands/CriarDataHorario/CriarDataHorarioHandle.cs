using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Commands.CriarDataHorarioReserva;

public class CriarDataHorarioReservaHandler(
    IDataHorarioReservaRepositorio repositorio)
    : IRequestHandler<CriarDataHorarioReservaCommand, CriarDataHorarioReservaResposta>
{
    public async Task<CriarDataHorarioReservaResposta> Handle(CriarDataHorarioReservaCommand command, CancellationToken ct)
    {
        var dataHorarioReserva = new BaseApi.Domain.Entidades.DataHorarioReserva
        {
            DataHorarioReservaId = Guid.NewGuid(),
            QuadraId = command.QuadraId,
            Data = command.Data,
            Horario = command.Horario
        };

        await repositorio.AdicionarAsync(dataHorarioReserva);

        return new CriarDataHorarioReservaResposta(
            dataHorarioReserva.DataHorarioReservaId,
            dataHorarioReserva.QuadraId,
            dataHorarioReserva.Data,
            dataHorarioReserva.Horario
        );
    }
}