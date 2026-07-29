using BaseApi.Application.DataHorarioReserva.Queries.ListarDataHorarioReserva;
using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Queries.ListarHorariosDisponiveis;

public record ListarHorariosDaQuadraQuery(Guid QuadraId)
    : IRequest<IEnumerable<DataHorarioReservaListaDto>>;