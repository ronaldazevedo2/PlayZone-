using BaseApi.Application.Comum.Modelos;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Usuarios.Queries.ListarUsuarios;

public class ListarUsuariosHandler(IUsuarioRepositorio repositorio) : IRequestHandler<ListarUsuariosQuery, ResultadoPaginado<UsuarioListaDto>>
{
    public async Task<ResultadoPaginado<UsuarioListaDto>> Handle(ListarUsuariosQuery query, CancellationToken ct)
    {
        var (itens, total) = await repositorio.ListarAsync(query.Pagina, query.TamanhoPagina, query.Busca, ct);

        return new ResultadoPaginado<UsuarioListaDto>
        {
            Itens = itens.Adapt<IEnumerable<UsuarioListaDto>>(),
            Total = total,
            Pagina = query.Pagina,
            TamanhoPagina = query.TamanhoPagina
        };
    }
}
