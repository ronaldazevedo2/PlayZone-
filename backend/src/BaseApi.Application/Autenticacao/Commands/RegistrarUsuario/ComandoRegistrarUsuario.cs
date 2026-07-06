using MediatR;

namespace BaseApi.Application.Autenticacao.Commands.RegistrarUsuario;

/// <summary>
/// Comando de registro de usuário (público).
/// </summary>
public record ComandoRegistrarUsuario(
    string NomeCompleto,
    string Email,
    string Senha
) : IRequest<RespostaRegistrarUsuario>;

/// <summary>
/// Resposta de sucesso do registro de usuário.
/// </summary>
public record RespostaRegistrarUsuario(
    Guid Id,
    string NomeCompleto,
    string Email
);
