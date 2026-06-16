using MediatR;

namespace BaseApi.Application.Usuarios.Commands.AtualizarUsuario;

public record AtualizarUsuarioCommand(
    Guid Id,
    string NomeCompleto,
    string Email,
    int PerfilId,
    bool Ativo
) : IRequest<Unit>;
