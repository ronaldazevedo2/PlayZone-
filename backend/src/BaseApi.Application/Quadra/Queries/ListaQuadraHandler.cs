using BaseApi.Application.Comum.Modelos;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ListarTelefones;

public class ListaQuadraHandler(IQuadraRepositorio repositorioQuadra)
    : IRequestHandler<ListarQuadraQuery, ResultadoPaginado<ReservaQuadraDto>>
{
    public async Task<ResultadoPaginado<ReservaQuadraDto>> Handle(ListarQuadraQuery consulta, CancellationToken cancelamentoToken)
    {
        var (itens, total) = await repositorioQuadra.ListarAsync(
            consulta.Pagina,
            consulta.TamanhoPagina,
            consulta.Busca,
            cancelamentoToken
        );

        return new ResultadoPaginado<ReservaQuadraDto>
        {
            Itens = itens.Adapt<IEnumerable<ReservaQuadraDto>>(),
            Total = total,
            Pagina = consulta.Pagina,
            TamanhoPagina = consulta.TamanhoPagina
        };
    }
}
