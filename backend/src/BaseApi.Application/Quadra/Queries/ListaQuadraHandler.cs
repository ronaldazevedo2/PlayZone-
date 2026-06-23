using BaseApi.Application.Comum.Modelos;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ListarTelefones;

public class ListaQuadraHandler(IReservaRepositorio repositorio)
    : IRequestHandler<ListarQuadraQuery, ResultadoPaginado<ReservaQuadraDto>>
{
    public async Task<ResultadoPaginado<ReservaQuadraDto>> Handle(ListarQuadraQuery query, CancellationToken ct)
    {
        // Adjusting the method call to match the signature of ListarAsync
        var (itens, total) = await repositorio.ListarAsync(
            query.Pagina,
            query.TamanhoPagina,
            null, // Assuming 'quadraId' is not provided in the query
            null, // Assuming 'dataInicio' is not provided in the query
            null, // Assuming 'dataFim' is not provided in the query
            ct
        );

        return new ResultadoPaginado<ReservaQuadraDto>
        {
            Itens = itens.Adapt<IEnumerable<ReservaQuadraDto>>(),
            Total = total,
            Pagina = query.Pagina,
            TamanhoPagina = query.TamanhoPagina
        };
    }
}
