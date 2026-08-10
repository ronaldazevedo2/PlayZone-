using BaseApi.Application.Comum.Modelos;
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ListarTelefones;

/// <summary>
/// Query para listar telefones com paginação e busca por marca/modelo.
/// </summary>
public record ListarReservaQuery(
    int Pagina = 1,
    int TamanhoPagina = 10,
    string? Busca = null,
    Guid? QuadraId = null
) : IRequest<ResultadoPaginado<ReservaListaDto>>;

/// <summary>DTO resumido para listagem</summary>
public record ReservaListaDto(
    Guid ReservasId,
    Guid QuadraId,
    Guid UsuarioId,
    DateTime DataAgendada,
    TimeSpan HorarioAgendado,
    string? NomeUsuario = null,
    string? EmailUsuario = null,
    string? CpfUsuario = null,
    string? TelefoneUsuario = null,
    string? NomeQuadra = null,
    string? Modalidade = null,
    string? Status = "Ativa"
);