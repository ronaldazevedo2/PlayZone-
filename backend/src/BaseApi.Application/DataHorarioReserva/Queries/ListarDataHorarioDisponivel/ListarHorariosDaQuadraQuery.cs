using BaseApi.Application.DataHorarioReserva.Queries.ListarDataHorarioReserva;
using MediatR;

public record ListarHorariosDaQuadraQuery(Guid QuadraId)
    : IRequest<IEnumerable<DataHorarioReservaListaDto>>;