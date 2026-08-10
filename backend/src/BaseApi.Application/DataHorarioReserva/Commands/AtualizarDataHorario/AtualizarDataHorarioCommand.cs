using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Commands.AtualizarDataHorarioReserva;

public record AtualizarDataHorarioReservaCommand(
    Guid DataHorarioReservaId,
    Guid QuadraId,
    DateTime Data,
    TimeSpan Horario
) : IRequest<Unit>;

public record AtualizarDataHorarioReservaResposta(
    Guid DataHorarioReservaId,
    Guid QuadraId,
    DateTime Data,
    TimeSpan Horario
);