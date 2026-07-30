using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Usuarios.Commands.ExcluirUsuario;

public class ExcluirUsuarioHandler(IUsuarioRepositorio repositorio) : IRequestHandler<ExcluirUsuarioCommand, Unit>
{
    public async Task<Unit> Handle(ExcluirUsuarioCommand command, CancellationToken ct)
    {
        var usuario = await repositorio.ObterPorIdAsync(command.UsuariosId, ct)
            ?? throw new ExcecaoNaoEncontrado($"Usuário com Id '{command.UsuariosId}' não encontrado.");

        repositorio.Remover(usuario);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}
