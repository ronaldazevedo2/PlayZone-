using BaseApi.Application.Comum.Modelos;
using MediatR;

namespace BaseApi.Application.Usuarios.Queries.ListarUsuarios;

/// <summary>
/// Query para listar usuários com paginação e busca por nome/e-mail.
/// </summary>
public record ListarUsuariosQuery(
    int Pagina = 1,
    int TamanhoPagina = 10,
    string? Busca = null
) : IRequest<ResultadoPaginado<UsuarioListaDto>>;

/// <summary>DTO resumido para listagem (sem dados sensíveis)</summary>
public record UsuarioListaDto(
    Guid Id,
    string NomeCompleto,
    string Email,
    string NomePerfil,
    bool Ativo
);
