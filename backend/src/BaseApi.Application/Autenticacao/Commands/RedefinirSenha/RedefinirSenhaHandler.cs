using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Domain.Interfaces.Servicos;
using MediatR;

namespace BaseApi.Application.Autenticacao.Commands.RedefinirSenha;

public class RedefinirSenhaHandler(
    IUsuarioRepositorio repositorio,
    ISenhaServico senhaServico) : IRequestHandler<RedefinirSenhaCommand, Unit>
{
    public async Task<Unit> Handle(RedefinirSenhaCommand command, CancellationToken ct)
    {
        var usuario = await repositorio.ObterPorTokenRedefinicaoAsync(command.Token, ct)
            ?? throw new ExcecaoDominio("Token de redefinição inválido ou já utilizado.");

        if (usuario.TokenExpiracao < DateTime.UtcNow)
            throw new ExcecaoDominio("Token de redefinição expirado. Solicite um novo.");

        usuario.SenhaHash = senhaServico.GerarHash(command.NovaSenha);
        usuario.TokenRedefinicaoSenha = null;
        usuario.TokenExpiracao = null;
        usuario.AtualizadoEm = DateTime.UtcNow;

        repositorio.Atualizar(usuario);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}
