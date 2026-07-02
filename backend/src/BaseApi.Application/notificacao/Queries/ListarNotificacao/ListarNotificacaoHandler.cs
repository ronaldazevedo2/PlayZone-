using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.Notificacoes.Queries.ListarNotificacoes;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Notificacoes.Queries.ListarNotificacoes;

// Ensure ListarNotificacoesQuery implements IRequest<ResultadoPaginado<NotificacaoListaDto>>
public class ListarNotificacoesQuery : IRequest<ResultadoPaginado<NotificacaoListaDto>>
{
    public int Pagina { get; set; }
    public int TamanhoPagina { get; set; }
    public string? Busca { get; set; }
}

public class ListarNotificacoesHandler : IRequestHandler<ListarNotificacoesQuery, ResultadoPaginado<NotificacaoListaDto>>
{
    private readonly INotificacaoRepositorio _repositorio;

    public ListarNotificacoesHandler(INotificacaoRepositorio repositorio)
    {
        _repositorio = repositorio;
    }

    public async Task<ResultadoPaginado<NotificacaoListaDto>> Handle(ListarNotificacoesQuery query, CancellationToken ct)
    {
        var (itens, total) = await _repositorio.ListarAsync(query.Pagina, query.TamanhoPagina, query.Busca, ct);

        return new ResultadoPaginado<NotificacaoListaDto>
        {
            Itens = itens.Adapt<IEnumerable<NotificacaoListaDto>>(),
            Total = total,
            Pagina = query.Pagina,
            TamanhoPagina = query.TamanhoPagina
        };
    }
}