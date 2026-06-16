using MediatR;

namespace BaseApi.Application.Autenticacao.Commands.Login;

/// <summary>
/// Command de login. Recebe e-mail e senha, retorna o token JWT.
/// </summary>
public record LoginCommand(string Email, string Senha) : IRequest<LoginResposta>;

/// <summary>
/// Resposta do login com o token JWT e sua expiração.
/// O cliente deve enviar este token no header: Authorization: Bearer {AccessToken}
/// </summary>
public record LoginResposta(
    string AccessToken,
    DateTime ExpiraEm,
    string NomeCompleto,
    string Email,
    string Perfil
);
