using MediatR;

namespace BaseApi.Application.Usuarios.Commands.AtualizarUsuario;

public record AtualizarUsuarioCommand(
    Guid Id,
    string NomeCompleto,
    string Email,
    string Cpf,
    string Telefone,
    int PerfilId,
    bool Ativo
) : IRequest<Unit>;
