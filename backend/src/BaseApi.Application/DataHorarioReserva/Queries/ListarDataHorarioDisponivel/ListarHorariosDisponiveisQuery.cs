using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Queries.ListarHorariosDisponiveis;

public record ListarHorariosDisponiveisQuery(
    Guid QuadraId,
    DateTime Data
) : IRequest<IEnumerable<HorarioDisponivelDto>>;

public record HorarioDisponivelDto(
    TimeSpan Horario,
    bool Disponivel
);