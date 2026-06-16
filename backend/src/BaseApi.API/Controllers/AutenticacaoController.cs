using BaseApi.Application.Autenticacao.Commands.EsqueceuSenha;
using BaseApi.Application.Autenticacao.Commands.Login;
using BaseApi.Application.Autenticacao.Commands.RedefinirSenha;
using BaseApi.Application.Comum.Modelos;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BaseApi.API.Controllers;

/// <summary>
/// ============================================================
/// CONTROLLER DE AUTENTICAÇÃO
/// ============================================================
///
/// Endpoints públicos (sem autenticação):
///   POST /api/autenticacao/login            → Faz login e retorna o JWT
///   POST /api/autenticacao/esqueceu-senha   → Envia e-mail de recuperação
///   POST /api/autenticacao/redefinir-senha  → Redefine a senha com o token
///
/// Como usar o token JWT:
///   1. Faça POST /api/autenticacao/login com { "email": "...", "senha": "..." }
///   2. Copie o campo "accessToken" da resposta
///   3. No Swagger: clique em "Authorize" e cole: Bearer SEU_TOKEN
///   4. Todos os endpoints protegidos com [Authorize] aceitarão suas requisições
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class AutenticacaoController(IMediator mediator) : ControllerBase
{
    /// <summary>
    /// Realiza o login e retorna o token JWT de acesso.
    /// </summary>
    /// <remarks>
    /// Usuário padrão para testes:
    ///   email: admin@baseapi.com
    ///   senha: Admin@123
    /// </remarks>
    [HttpPost("login")]
    [ProducesResponseType(typeof(RespostaApi<LoginResposta>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginCommand command, CancellationToken ct)
    {
        var resultado = await mediator.Send(command, ct);
        return Ok(RespostaApi<LoginResposta>.Sucesso(resultado, "Login realizado com sucesso."));
    }

    /// <summary>
    /// Inicia o fluxo de recuperação de senha.
    /// Envia um e-mail com link de redefinição válido por 2 horas.
    /// </summary>
    /// <remarks>
    /// Sempre retorna sucesso mesmo que o e-mail não exista (segurança).
    /// O link enviado aponta para: {urlBase}/redefinir-senha?token=TOKEN
    /// </remarks>
    [HttpPost("esqueceu-senha")]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    public async Task<IActionResult> EsqueceuSenha([FromBody] EsqueceuSenhaRequest request, CancellationToken ct)
    {
        var urlBase = $"{Request.Scheme}://{Request.Host}";
        var command = new EsqueceuSenhaCommand(request.Email, urlBase);
        await mediator.Send(command, ct);
        return Ok(RespostaApi.Sucesso("Se o e-mail estiver cadastrado, você receberá as instruções em breve."));
    }

    /// <summary>
    /// Redefine a senha usando o token recebido por e-mail.
    /// O token expira em 2 horas e é invalidado após o uso.
    /// </summary>
    [HttpPost("redefinir-senha")]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RedefinirSenha([FromBody] RedefinirSenhaCommand command, CancellationToken ct)
    {
        await mediator.Send(command, ct);
        return Ok(RespostaApi.Sucesso("Senha redefinida com sucesso. Faça login com sua nova senha."));
    }
}

// DTO local para o request de esqueceu senha (não usa o Command diretamente para não expor UrlBase)
public record EsqueceuSenhaRequest(string Email);
