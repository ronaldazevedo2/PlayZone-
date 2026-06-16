using MediatR;

namespace BaseApi.Application.Usuarios.Commands.ExcluirUsuario;

public record ExcluirUsuarioCommand(Guid Id) : IRequest<Unit>;
