using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.Quadra.Commands.AtualizarQuadra;
using BaseApi.Application.Quadra.Commands.AdicionarQuadra;
using BaseApi.Application.Quadra.Commands.ExcluirQuadra;
using BaseApi.Application.Telefones.Queries.ListarTelefones;
using BaseApi.Application.Quadra.Queries;
using BaseApi.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BaseApi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class QuadraController(IMediator mediator) : ControllerBase
{
    // GET /api/quadra
    [HttpGet]
    [AllowAnonymous]
    [ProducesResponseType(typeof(RespostaApi<ResultadoPaginado<ReservaQuadraDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar(
        [FromQuery] int pagina = 1,
        [FromQuery] int tamanhoPagina = 10,
        [FromQuery] string? busca = null,
        CancellationToken ct = default)
    {
        var resultado = await mediator.Send(
            new ListarQuadraQuery(pagina, tamanhoPagina, busca),
            ct);

        return Ok(
            RespostaApi<ResultadoPaginado<ReservaQuadraDto>>
                .Sucesso(resultado));
    }

    // GET /api/quadra/{quadraId}
    [HttpGet("{quadraId:guid}")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(RespostaApi<QuadraDetalheDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(
        Guid quadraId,
        CancellationToken ct)
    {
        var resultado = await mediator.Send(
            new ObterQuadraPorIdQuery(quadraId),
            ct);

        return Ok(
            RespostaApi<QuadraDetalheDto>
                .Sucesso(resultado));
    }

    // POST /api/quadra
    [HttpPost]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi<CriarQuadraResposta>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar(
        [FromBody] CriarQuadraCommand command,
        CancellationToken ct)
    {
        var resultado = await mediator.Send(command, ct);

        return CreatedAtAction(
            nameof(ObterPorId),
            new { quadraId = resultado.Id },
            RespostaApi<CriarQuadraResposta>.Sucesso(
                resultado,
                "Quadra criada com sucesso!"));
    }

    // PUT /api/quadra/{quadraId}
    [HttpPut("{quadraId:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Atualizar(
        Guid quadraId,
        [FromBody] AtualizarQuadraRequest request,
        CancellationToken ct)
    {
        var command = new AtualizarQuadraCommand(
            quadraId,
            request.Nome,
            request.Descricao,
            request.Localizacao,
            request.Capacidade,
            request.Modalidade,
            request.ImagemUrl);

        await mediator.Send(command, ct);

        return Ok(
            RespostaApi.Sucesso(
                "Dados da quadra atualizados com sucesso!"));
    }

    // DELETE /api/quadra/{quadraId}
    [HttpDelete("{quadraId:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Excluir(
        Guid quadraId,
        CancellationToken ct)
    {
        await mediator.Send(
            new ExcluirQuadraCommand(quadraId),
            ct);

        return Ok(
            RespostaApi.Sucesso(
                "Quadra excluída com sucesso!"));
    }
}

public record AtualizarQuadraRequest(
    string Nome,
    string Descricao,
    string Localizacao,
    int Capacidade,
    string Modalidade,
    string ImagemUrl
);