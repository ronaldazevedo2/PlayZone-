using BaseApi.Application.Comum.Modelos;
using Mapster;
using MediatR;

namespace BaseApi.Application.Secretaria.Queries.ListarSecretaria;

public class ListarSecretariaHandler(IDadosSecretariaRepositorio repositorio) : IRequestHandler<ListarSecretariaQuery, ResultadoPaginado<SecretariaListaDto>>
{
    public async Task<ResultadoPaginado<SecretariaListaDto>> Handle(ListarSecretariaQuery query, CancellationToken ct)
    {
        var (itens, total) = await repositorio.ListarAsync(query.Pagina, query.TamanhoPagina, query.Busca, ct);

        return new ResultadoPaginado<SecretariaListaDto>
        {
            Itens = itens.Adapt<IEnumerable<SecretariaListaDto>>(),
            Total = total,
            Pagina = query.Pagina,
            TamanhoPagina = query.TamanhoPagina
        };
    }
}
