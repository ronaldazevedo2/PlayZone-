using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Commands.CriarDataHorarioReserva;

public record CriarDataHorarioReservaCommand(
    Guid QuadraId,
    DateTime Data,
    TimeSpan Horario
) : IRequest<CriarDataHorarioReservaResposta>;

/// <summary>
/// DTO retornado após criação bem-sucedida
/// </summary>
public record CriarDataHorarioReservaResposta(
    Guid DataHorarioReservaId,
    Guid QuadraId,
    DateTime Data,
    TimeSpan Horario
);