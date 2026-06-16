namespace BaseApi.Domain.Interfaces.Servicos;

/// <summary>
/// Contrato do serviço de envio de e-mails.
/// Implementado na Infrastructure usando MailKit + Mailtrap.
/// </summary>
public interface IEmailServico
{
    Task EnviarAsync(string destinatario, string assunto, string corpoHtml, CancellationToken ct = default);
    Task EnviarRedefinicaoSenhaAsync(string destinatario, string nomeUsuario, string linkRedefinicao, CancellationToken ct = default);
}
