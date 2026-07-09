using BaseApi.Application.Comum.Modelos;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ListarTelefones;

public class ListarReservaHandler(IReservaRepositorio repositorio)
    : IRequestHandler<ListarReservaQuery, ResultadoPaginado<ReservaListaDto>>
{
    public async Task<ResultadoPaginado<ReservaListaDto>> Handle(ListarReservaQuery query, CancellationToken ct)
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

        return new ResultadoPaginado<ReservaListaDto>
        {
            Itens = itens.Adapt<IEnumerable<ReservaListaDto>>(),
            Total = total,
            Pagina = query.Pagina,
            TamanhoPagina = query.TamanhoPagina
        };
    }
}
