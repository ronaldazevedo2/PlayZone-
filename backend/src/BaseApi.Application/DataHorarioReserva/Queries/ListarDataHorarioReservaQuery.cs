using BaseApi.Application.Comum.Modelos;
using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Queries.ListarDataHorarioReserva;

public record ListarDataHorarioReservaQuery(
    int Pagina = 1,
    int TamanhoPagina = 10
) : IRequest<ResultadoPaginado<DataHorarioReservaListaDto>>;

public record DataHorarioReservaListaDto(
    Guid DataHorarioReservaId,
    Guid QuadraId,
    DateTime Data,
    TimeSpan Horario
);