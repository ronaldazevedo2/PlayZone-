using MediatR;

namespace BaseApi.Application.Autenticacao.Commands.EsqueceuSenha;

/// <summary>
/// Command disparado quando o usuário esqueceu a senha.
/// Gera um token único, salva no banco com expiração de 2 horas
/// e envia um e-mail com o link de redefinição.
///
/// IMPORTANTE: Mesmo que o e-mail não exista, retorna sucesso
/// (boa prática de segurança — evita enumeração de usuários).
/// </summary>
public record EsqueceuSenhaCommand(string Email, string UrlBase) : IRequest<Unit>;
