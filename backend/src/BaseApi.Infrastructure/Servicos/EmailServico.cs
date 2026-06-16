using BaseApi.Domain.Interfaces.Servicos;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using MimeKit;

namespace BaseApi.Infrastructure.Servicos;

/// <summary>
/// Serviço de envio de e-mails usando MailKit + SMTP do Mailtrap.
///
/// ======================================================
/// CONFIGURAÇÃO DO MAILTRAP (serviço gratuito para testes)
/// ======================================================
/// 1. Acesse https://mailtrap.io e crie uma conta gratuita
/// 2. Vá em "Email Testing" → "My Inbox" → "SMTP Settings"
/// 3. Selecione "MailKit" no dropdown de integração
/// 4. Copie as credenciais e cole no appsettings.json:
///
///    "Email": {
///      "Smtp": {
///        "Host": "sandbox.smtp.mailtrap.io",
///        "Porta": 2525,
///        "Usuario": "SEU_USUARIO_MAILTRAP",
///        "Senha": "SUA_SENHA_MAILTRAP",
///        "RemetenteNome": "BaseApi Sistema",
///        "RemetenteEmail": "noreply@baseapi.com"
///      }
///    }
///
/// Os e-mails enviados ficam capturados no painel do Mailtrap
/// sem chegar de verdade no destinatário — ideal para testes!
/// </summary>
public class EmailServico(IConfiguration config) : IEmailServico
{
    public async Task EnviarAsync(string destinatario, string assunto, string corpoHtml, CancellationToken ct = default)
    {
        var mensagem = new MimeMessage();

        mensagem.From.Add(new MailboxAddress(
            config["Email:Smtp:RemetenteNome"],
            config["Email:Smtp:RemetenteEmail"]));

        mensagem.To.Add(MailboxAddress.Parse(destinatario));
        mensagem.Subject = assunto;
        mensagem.Body = new TextPart("html") { Text = corpoHtml };

        using var cliente = new SmtpClient();
        await cliente.ConnectAsync(
            config["Email:Smtp:Host"],
            int.Parse(config["Email:Smtp:Porta"]!),
            SecureSocketOptions.StartTls,
            ct);

        await cliente.AuthenticateAsync(
            config["Email:Smtp:Usuario"],
            config["Email:Smtp:Senha"],
            ct);

        await cliente.SendAsync(mensagem, ct);
        await cliente.DisconnectAsync(true, ct);
    }

    public async Task EnviarRedefinicaoSenhaAsync(
        string destinatario, string nomeUsuario, string linkRedefinicao, CancellationToken ct = default)
    {
        var corpo = $"""
            <h2>Redefinição de Senha</h2>
            <p>Olá, <strong>{nomeUsuario}</strong>!</p>
            <p>Recebemos uma solicitação para redefinir a senha da sua conta.</p>
            <p>Clique no botão abaixo para criar uma nova senha. Este link expira em <strong>2 horas</strong>.</p>
            <br/>
            <a href="{linkRedefinicao}"
               style="background:#1a73e8;color:#fff;padding:12px 24px;text-decoration:none;border-radius:4px;display:inline-block;">
               Redefinir minha senha
            </a>
            <br/><br/>
            <p>Se você não solicitou a redefinição, ignore este e-mail. Sua senha permanece a mesma.</p>
            <p><small>Link direto: {linkRedefinicao}</small></p>
            """;

        await EnviarAsync(destinatario, "Redefinição de senha — BaseApi", corpo, ct);
    }
}
