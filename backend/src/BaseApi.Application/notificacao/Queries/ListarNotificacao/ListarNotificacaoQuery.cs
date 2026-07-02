using BaseApi.Application.Comum.Modelos;
using MediatR;

namespace BaseApi.Application.Notificacoes.Queries.ListarNotificacoes;

/// <summary>
/// Query para listar Notificacoes com paginação e busca por marca/modelo.
/// </summary>
public record ListarNotificacaoQuery(
    int Pagina = 1,
    int TamanhoPagina = 10,
    string? Busca = null
) : IRequest<ResultadoPaginado<NotificacaoListaDto>>;

/// <summary>DTO resumido para listagem</summary>
public record NotificacaoListaDto(
    Guid Id,
   
);