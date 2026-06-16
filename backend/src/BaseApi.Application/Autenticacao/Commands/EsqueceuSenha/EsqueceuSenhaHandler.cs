using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Domain.Interfaces.Servicos;
using MediatR;

namespace BaseApi.Application.Autenticacao.Commands.EsqueceuSenha;

public class EsqueceuSenhaHandler(
    IUsuarioRepositorio repositorio,
    IEmailServico emailServico) : IRequestHandler<EsqueceuSenhaCommand, Unit>
{
    public async Task<Unit> Handle(EsqueceuSenhaCommand command, CancellationToken ct)
    {
        var usuario = await repositorio.ObterPorEmailAsync(command.Email.ToLowerInvariant().Trim(), ct);

        // Não informa se o e-mail existe ou não (segurança)
        if (usuario is null || !usuario.Ativo)
            return Unit.Value;

        // Gera token único com 2 horas de validade
        usuario.TokenRedefinicaoSenha = Guid.NewGuid().ToString("N");
        usuario.TokenExpiracao = DateTime.UtcNow.AddHours(2);
        usuario.AtualizadoEm = DateTime.UtcNow;

        repositorio.Atualizar(usuario);
        await repositorio.SalvarAsync(ct);

        var linkRedefinicao = $"{command.UrlBase}/redefinir-senha?token={usuario.TokenRedefinicaoSenha}";

        await emailServico.EnviarRedefinicaoSenhaAsync(
            destinatario: usuario.Email,
            nomeUsuario: usuario.NomeCompleto,
            linkRedefinicao: linkRedefinicao,
            ct: ct);

        return Unit.Value;
    }
}
