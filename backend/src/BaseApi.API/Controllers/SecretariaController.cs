using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.Secretaria.Commands.AtualizarSecretaria;
using BaseApi.Application.Secretaria.Commands.ExcluirSecretaria;
using BaseApi.Application.Secretaria.Queries.ListarSecretaria;
using BaseApi.Application.Secretaria.Queries.ObterSecretariaPorId;
using BaseApi.Application.Usuarios.Commands.CriarUsuario;
using BaseApi.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BaseApi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class SecretariaController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    [ProducesResponseType(typeof(RespostaApi<ResultadoPaginado<SecretariaListaDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar(
        [FromQuery] int pagina = 1,
        [FromQuery] int tamanhoPagina = 10,
        [FromQuery] string? busca = null,
        CancellationToken ct = default)
    {
        var resultado = await mediator.Send(
            new ListarSecretariaQuery(pagina, tamanhoPagina, busca),
            ct);

        return Ok(
            RespostaApi<ResultadoPaginado<SecretariaListaDto>>
                .Sucesso(resultado));
    }

    // GET /api/secretaria/{secretariaId}
    [HttpGet("{secretariaId:guid}")]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    [ProducesResponseType(typeof(RespostaApi<SecretariaDetalheDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(
        Guid secretariaId,
        CancellationToken ct)
    {
        var resultado = await mediator.Send(
            new ObterSecretariaPorIdQuery(secretariaId),
            ct);

        return Ok(
            RespostaApi<SecretariaDetalheDto>
                .Sucesso(resultado));
    }

    // POST /api/secretaria
    [HttpPost]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi<CriarSecretariaResposta>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar(
        [FromBody] CriarSecretariaCommand command,
        CancellationToken ct)
    {
        var resultado = await mediator.Send(command, ct);

        return CreatedAtAction(
            nameof(ObterPorId),
            new { secretariaId = resultado.SecretariaId },
            RespostaApi<CriarSecretariaResposta>.Sucesso(
                resultado,
                "Secretaria criada com sucesso!"));
    }

    // PUT /api/secretaria/{secretariaId}
    [HttpPut("{secretariaId:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Atualizar(
        Guid secretariaId,
        [FromBody] AtualizarSecretariaRequest request,
        CancellationToken ct)
    {
        var command = new AtualizarSecretariaCommand(
            secretariaId,
            request.Nome,
            request.Email,
            request.Contato,
            request.Cep,
            request.Endereco,
            request.Numero,
            request.Bairro,
            request.Cidade);

        await mediator.Send(command, ct);

        return Ok(
            RespostaApi.Sucesso(
                "Dados da secretaria atualizados com sucesso!"));
    }

    // DELETE /api/secretaria/{secretariaId}
    [HttpDelete("{secretariaId:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Excluir(
        Guid secretariaId,
        CancellationToken ct)
    {
        await mediator.Send(
            new ExcluirSecretariaCommand(secretariaId),
            ct);

        return Ok(
            RespostaApi.Sucesso(
                "Secretaria excluída com sucesso!"));
    }
}

public record AtualizarSecretariaRequest(
    string Nome,
    string Email,
    string Contato,
    string Cep,
    string Endereco,
    string Numero,
    string Bairro,
    string Cidade
);