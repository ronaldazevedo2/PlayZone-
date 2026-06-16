using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Domain.Interfaces.Servicos;
using MediatR;

namespace BaseApi.Application.Autenticacao.Commands.Login;

/// <summary>
/// Handler do login.
///
/// Fluxo:
///   1. Busca o usuário pelo e-mail
///   2. Verifica se está ativo
///   3. Valida a senha com ISenhaServico (BCrypt por baixo)
///   4. Gera o token JWT via ITokenServico
///   5. Retorna o token e dados do usuário
/// </summary>
public class LoginHandler(
    IUsuarioRepositorio repositorio,
    ISenhaServico senhaServico,
    ITokenServico tokenServico) : IRequestHandler<LoginCommand, LoginResposta>
{
    public async Task<LoginResposta> Handle(LoginCommand command, CancellationToken ct)
    {
        var usuario = await repositorio.ObterPorEmailAsync(command.Email.ToLowerInvariant().Trim(), ct)
            ?? throw new ExcecaoNaoAutorizado("E-mail ou senha inválidos.");

        if (!usuario.Ativo)
            throw new ExcecaoNaoAutorizado("Usuário inativo. Entre em contato com o administrador.");

        if (!senhaServico.Verificar(command.Senha, usuario.SenhaHash))
            throw new ExcecaoNaoAutorizado("E-mail ou senha inválidos.");

        var token = tokenServico.GerarToken(usuario);
        var expiracao = tokenServico.ObterDataExpiracao();

        return new LoginResposta(
            AccessToken: token,
            ExpiraEm: expiracao,
            NomeCompleto: usuario.NomeCompleto,
            Email: usuario.Email,
            Perfil: usuario.Perfil?.Nome ?? string.Empty
        );
    }
}
