using MediatR;

namespace BaseApi.Application.Autenticacao.Commands.RedefinirSenha;

/// <summary>
/// Command para redefinir a senha usando o token recebido por e-mail.
/// O token tem validade de 2 horas e é invalidado após o uso.
/// </summary>
public record RedefinirSenhaCommand(string Token, string NovaSenha, string ConfirmacaoSenha) : IRequest<Unit>;
