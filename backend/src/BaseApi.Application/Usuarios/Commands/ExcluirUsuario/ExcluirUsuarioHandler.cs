using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Usuarios.Commands.ExcluirUsuario;

public class ExcluirUsuarioHandler(IUsuarioRepositorio repositorio) : IRequestHandler<ExcluirUsuarioCommand, Unit>
{
    public async Task<Unit> Handle(ExcluirUsuarioCommand command, CancellationToken ct)
    {
        var usuario = await repositorio.ObterPorIdAsync(command.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Usuário com Id '{command.Id}' não encontrado.");

        repositorio.Remover(usuario);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}
