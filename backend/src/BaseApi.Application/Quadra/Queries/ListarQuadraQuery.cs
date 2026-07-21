using BaseApi.Application.Comum.Modelos;
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ListarTelefones;

/// <summary>
/// Query para listar telefones com paginação e busca por marca/modelo.
/// </summary>
public record ListarQuadraQuery(
    int Pagina = 1,
    int TamanhoPagina = 10,
    string? Busca = null
) : IRequest<ResultadoPaginado<ReservaQuadraDto>>;

/// <summary>DTO resumido para listagem</summary>
public record ReservaQuadraDto(
    Guid Id,
    string Nome,
    string Descricao,
    string Localizacao,
    int Capacidade,
    string Modalidade,
    string ImagemUrl,
    string Status
);