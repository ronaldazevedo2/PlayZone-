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
        var host = config["Email:Smtp:Host"];
        var usuario = config["Email:Smtp:Usuario"];
        var senha = config["Email:Smtp:Senha"];
        var portaTexto = config["Email:Smtp:Porta"];
        var remetenteNome = config["Email:Smtp:RemetenteNome"] ?? "PlayZone";
        var remetenteEmail = config["Email:Smtp:RemetenteEmail"] ?? "noreply@playzone.com";

        // Verifica se as credenciais são placeholders ou vazias
        bool ehPlaceholder = string.IsNullOrWhiteSpace(usuario) ||
                             usuario.Contains("MAILTRAP") ||
                             string.IsNullOrWhiteSpace(senha) ||
                             senha.Contains("MAILTRAP") ||
                             string.IsNullOrWhiteSpace(host);

        if (ehPlaceholder)
        {
            Console.WriteLine($"\n==================================================");
            Console.WriteLine($"[AVISO SMTP] As credenciais do SMTP em appsettings.json são de teste/placeholder.");
            Console.WriteLine($"E-mail destinado a: {destinatario}");
            Console.WriteLine($"Assunto: {assunto}");
            Console.WriteLine($"==================================================\n");
            return;
        }

        try
        {
            var mensagem = new MimeMessage();
            mensagem.From.Add(new MailboxAddress(remetenteNome, remetenteEmail));
            mensagem.To.Add(MailboxAddress.Parse(destinatario));
            mensagem.Subject = assunto;
            mensagem.Body = new TextPart("html") { Text = corpoHtml };

            using var cliente = new SmtpClient();
            var porta = int.TryParse(portaTexto, out var p) ? p : 587;

            // Usa Auto para negociar a segurança SSL/TLS dinamicamente (Gmail/Mailtrap/Outlook)
            await cliente.ConnectAsync(host, porta, SecureSocketOptions.Auto, ct);
            await cliente.AuthenticateAsync(usuario, senha, ct);
            await cliente.SendAsync(mensagem, ct);
            await cliente.DisconnectAsync(true, ct);

            Console.WriteLine($"[E-MAIL ENVIADO COM SUCESSO] Para: {destinatario}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[FALHA NO ENVIO DO E-MAIL SMTP]: {ex.Message}");
        }
    }

    public async Task EnviarRedefinicaoSenhaAsync(
        string destinatario, string nomeUsuario, string linkRedefinicao, CancellationToken ct = default)
    {
        Console.WriteLine($"\n==================================================");
        Console.WriteLine($"[LINK DE REDEFINIÇÃO DE SENHA GERADO]");
        Console.WriteLine($"Usuário: {nomeUsuario} ({destinatario})");
        Console.WriteLine($"Link para Redefinir: {linkRedefinicao}");
        Console.WriteLine($"==================================================\n");

        var corpo = $"""
            <h2>Redefinição de Senha — PlayZone</h2>
            <p>Olá, <strong>{nomeUsuario}</strong>!</p>
            <p>Recebemos uma solicitação para redefinir a senha da sua conta na PlayZone.</p>
            <p>Clique no botão abaixo para criar uma nova senha. Este link expira em <strong>2 horas</strong>.</p>
            <br/>
            <a href="{linkRedefinicao}"
               style="background:#254EDB;color:#fff;padding:12px 24px;text-decoration:none;border-radius:6px;display:inline-block;font-weight:bold;">
               Redefinir minha senha
            </a>
            <br/><br/>
            <p>Se você não solicitou a redefinição, ignore este e-mail. Sua senha permanece a mesma.</p>
            <p><small>Link direto: {linkRedefinicao}</small></p>
            """;

        await EnviarAsync(destinatario, "Redefinição de senha — PlayZone", corpo, ct);
    }
}
