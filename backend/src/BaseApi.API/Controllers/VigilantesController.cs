using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.Vigilantes.Commands.AtualizarVigilante;
using BaseApi.Application.Vigilantes.Commands.CriarVigilante;
using BaseApi.Application.Vigilantes.Commands.ExcluirVigilante;
using BaseApi.Application.Vigilantes.Queries.ListarVigilantes;
using BaseApi.Application.Vigilantes.Queries.ObterVigilantePorId;
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
    public async Task<IActionResult> Listar(
        [FromQuery] int pagina = 1,
        [FromQuery] int tamanhoPagina = 10,
        [FromQuery] string? busca = null,
        CancellationToken ct = default)
    {
        var resultado = await mediator.Send(new ListarVigilantesQuery(pagina, tamanhoPagina, busca), ct);
        return Ok(RespostaApi<ResultadoPaginado<VigilanteListaDto>>.Sucesso(resultado));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> ObterPorId(Guid id, CancellationToken ct)
    {
        var resultado = await mediator.Send(new ObterVigilantePorIdQuery(id), ct);
        return Ok(RespostaApi<VigilanteDetalheDto>.Sucesso(resultado));
    }

    [HttpPost]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    public async Task<IActionResult> Criar([FromBody] CriarVigilanteCommand command, CancellationToken ct)
    {
        var resultado = await mediator.Send(command, ct);

        return CreatedAtAction(
            nameof(ObterPorId),
            new { id = resultado.Id },
            RespostaApi<CriarVigilanteResposta>.Sucesso(resultado, "Vigilante cadastrado com sucesso!")
        );
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    public async Task<IActionResult> Atualizar(
        Guid id,
        [FromBody] AtualizarVigilanteRequest request,
        CancellationToken ct)
    {
        var command = new AtualizarVigilanteCommand(
            id,
            request.NomeCompleto,
            request.Cpf,
            request.Matricula,
            request.Arena,
            request.Ativo
        );

        await mediator.Send(command, ct);

        return Ok(RespostaApi.Sucesso("Vigilante atualizado com sucesso!"));
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    public async Task<IActionResult> Excluir(Guid id, CancellationToken ct)
    {
        await mediator.Send(new ExcluirVigilanteCommand(id), ct);
        return Ok(RespostaApi.Sucesso("Vigilante removido com sucesso!"));
    }
}

public record AtualizarVigilanteRequest(
    string NomeCompleto,
    string Cpf,
    string Matricula,
    string Arena,
    bool Ativo
);