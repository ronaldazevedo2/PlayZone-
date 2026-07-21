using BaseApi.Application.Comum.Modelos;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ListarTelefones;

public class ListaQuadraHandler(IQuadraRepositorio repositorio)
    : IRequestHandler<ListarQuadraQuery, ResultadoPaginado<ReservaQuadraDto>>
{
    public async Task<ResultadoPaginado<ReservaQuadraDto>> Handle(ListarQuadraQuery query, CancellationToken ct)
    {
        var (itens, total) = await repositorio.ListarAsync(
            query.Pagina,
            query.TamanhoPagina,
            query.Busca,
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
