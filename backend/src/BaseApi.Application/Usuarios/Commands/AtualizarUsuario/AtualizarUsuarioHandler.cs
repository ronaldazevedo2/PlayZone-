using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Usuarios.Commands.AtualizarUsuario;

public class AtualizarUsuarioHandler(IUsuarioRepositorio repositorio) : IRequestHandler<AtualizarUsuarioCommand, Unit>
{
    public async Task<Unit> Handle(AtualizarUsuarioCommand command, CancellationToken ct)
    {
        var usuario = await repositorio.ObterPorIdAsync(command.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Usuário com Id '{command.Id}' não encontrado.");

        usuario.NomeCompleto = command.NomeCompleto;
        usuario.Email = command.Email.ToLowerInvariant().Trim();
        usuario.PerfilId = command.PerfilId;
        usuario.Ativo = command.Ativo;
        usuario.AtualizadoEm = DateTime.UtcNow;

        repositorio.Atualizar(usuario);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}
