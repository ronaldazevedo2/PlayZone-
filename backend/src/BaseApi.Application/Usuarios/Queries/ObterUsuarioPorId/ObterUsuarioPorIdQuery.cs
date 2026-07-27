using MediatR;

namespace BaseApi.Application.Usuarios.Queries.ObterUsuarioPorId;

/// <summary>
/// Query para buscar um único usuário pelo Id.
/// Queries NUNCA alteram o estado — apenas leem dados.
/// </summary>
public record ObterUsuarioPorIdQuery(Guid UsuariosId) : IRequest<UsuarioDetalheDto>;

/// <summary>DTO com todos os detalhes do usuário para exibição</summary>
public record UsuarioDetalheDto(
    Guid UsuariosId,
    string NomeCompleto,
    string Email,
    string Cpf,
    string Telefone,
    string NomePerfil,
    bool Ativo,
    DateTime CriadoEm,
    DateTime AtualizadoEm
);
