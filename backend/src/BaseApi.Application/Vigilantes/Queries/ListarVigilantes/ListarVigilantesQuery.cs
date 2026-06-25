using BaseApi.Application.Comum.Modelos;
using MediatR;

namespace BaseApi.Application.Vigilantes.Queries.ListarVigilantes;

/// <summary>
/// Query para listar vigilantes com paginação e busca.
/// </summary>
public record ListarVigilantesQuery(
    int Pagina = 1,
    int TamanhoPagina = 10,
    string? Busca = null
) : IRequest<ResultadoPaginado<VigilanteListaDto>>;

/// <summary>
/// DTO resumido para listagem
/// </summary>
public record VigilanteListaDto(
    int Id,
    string NomeCompleto,
    string Cpf,
    string Matricula,
    string Arena,
    bool Ativo
);