using BaseApi.Application.Comum.Modelos;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Vigilantes.Queries.ListarVigilantes;

public class ListarVigilantesHandler(IVigilanteRepositorio repositorio)
    : IRequestHandler<ListarVigilantesQuery, ResultadoPaginado<VigilanteListaDto>>
{
    public async Task<ResultadoPaginado<VigilanteListaDto>> Handle(ListarVigilantesQuery query, CancellationToken ct)
    {
        var (itens, total) = await repositorio.ListarAsync(
            query.Pagina,
            query.TamanhoPagina,
            query.Busca,
            ct);

        return new ResultadoPaginado<VigilanteListaDto>
        {
            Itens = itens.Adapt<IEnumerable<VigilanteListaDto>>(),
            Total = total,
            Pagina = query.Pagina,
            TamanhoPagina = query.TamanhoPagina
        };
    }
}