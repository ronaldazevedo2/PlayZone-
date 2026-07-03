using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.Vigilantes.Commands.CriarVigilante;
using BaseApi.Application.Vigilantes.Queries.ListarVigilantes;
using BaseApi.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BaseApi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class VigilantesController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(RespostaApi<ResultadoPaginado<VigilanteListaDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar(
        [FromQuery] int pagina = 1,
        [FromQuery] int tamanhoPagina = 10,
        [FromQuery] string? busca = null,
        CancellationToken ct = default)
    {
        var resultado = await mediator.Send(
            new ListarVigilantesQuery(pagina, tamanhoPagina, busca),
            ct);

        return Ok(
            RespostaApi<ResultadoPaginado<VigilanteListaDto>>
                .Sucesso(resultado));
    }

    [HttpPost]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi<CriarVigilanteResposta>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar(
        [FromBody] CriarVigilanteCommand command,
        CancellationToken ct)
    {
        var resultado = await mediator.Send(command, ct);

        return CreatedAtAction(
            nameof(Listar),
            new { },
            RespostaApi<CriarVigilanteResposta>.Sucesso(
                resultado,
                "Vigilante cadastrado com sucesso!"));
    }
}
