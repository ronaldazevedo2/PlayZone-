using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Queries.ObterDataHorarioReservaPorId;

/// <summary>
/// Query para buscar um único DataHorarioReserva pelo Id.
/// Queries NUNCA alteram dados — apenas leem.
/// </summary>
public record ObterDataHorarioReservaPorIdQuery(Guid DataHorarioReservaId)
    : IRequest<DataHorarioReservaDetalheDto>;

/// <summary>
/// DTO com todos os dados da disponibilidade da quadra para exibição.
/// </summary>
public record DataHorarioReservaDetalheDto(
    Guid DataHorarioReservaId,
    Guid QuadraId,
    DateTime Data,
    TimeSpan Horario
);