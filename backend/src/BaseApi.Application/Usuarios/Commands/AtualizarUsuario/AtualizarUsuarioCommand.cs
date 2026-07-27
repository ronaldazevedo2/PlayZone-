using MediatR;

namespace BaseApi.Application.Usuarios.Commands.AtualizarUsuario;

public record AtualizarUsuarioCommand(
    Guid UsuariosId,
    string NomeCompleto,
    string Email,
    string Cpf,
    string Telefone,
    int PerfilId,
    bool Ativo
) : IRequest<Unit>;
