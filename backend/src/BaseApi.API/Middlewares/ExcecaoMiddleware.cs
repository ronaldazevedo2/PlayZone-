using System.Net;
using System.Text.Json;
using BaseApi.Application.Comum.Modelos;
using BaseApi.Domain.Excecoes;
using FluentValidation;

namespace BaseApi.API.Middlewares;

/// <summary>
/// Middleware global de tratamento de exceções.
/// Captura qualquer exceção não tratada e retorna uma resposta JSON padronizada.
///
/// Mapeamento de exceções:
///   ExcecaoNaoEncontrado   → 404 Not Found
///   ExcecaoNaoAutorizado   → 401 Unauthorized
///   ExcecaoDominio         → 400 Bad Request
///   ValidationException    → 400 Bad Request (com lista de erros)
///   Exception              → 500 Internal Server Error
/// </summary>
public class ExcecaoMiddleware(RequestDelegate proximo, ILogger<ExcecaoMiddleware> logger)
{
    private static readonly JsonSerializerOptions _jsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    public async Task InvokeAsync(HttpContext contexto)
    {
        try
        {
            await proximo(contexto);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Exceção não tratada: {Mensagem}", ex.Message);
            await TratarExcecaoAsync(contexto, ex);
        }
    }

    private static async Task TratarExcecaoAsync(HttpContext contexto, Exception ex)
    {
        contexto.Response.ContentType = "application/json";

        var (statusCode, resposta) = ex switch
        {
            ExcecaoNaoEncontrado e => (
                HttpStatusCode.NotFound,
                RespostaApi.Falha(e.Message)),

            ExcecaoNaoAutorizado e => (
                HttpStatusCode.Unauthorized,
                RespostaApi.Falha(e.Message)),

            ExcecaoDominio e => (
                HttpStatusCode.BadRequest,
                RespostaApi.Falha(e.Message)),

            ValidationException e => (
                HttpStatusCode.BadRequest,
                RespostaApi.Falha("Erro de validação.", e.Errors.Select(f => f.ErrorMessage))),

            _ => (
                HttpStatusCode.InternalServerError,
                RespostaApi.Falha("Erro interno. Tente novamente mais tarde."))
        };

        contexto.Response.StatusCode = (int)statusCode;
        await contexto.Response.WriteAsync(JsonSerializer.Serialize(resposta, _jsonOptions));
    }
}
