using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.Reserva.Commands.AtualizarReserva;
using BaseApi.Application.Reserva.Commands.CriarReserva;
using BaseApi.Application.Telefones.Commands.ExcluirTelefone;
using BaseApi.Application.Telefones.Queries.ListarTelefones;
using BaseApi.Application.Telefones.Queries.ObterTelefonePorId;
using BaseApi.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BaseApi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class ReservasController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Listar(
        [FromQuery] int pagina = 1,
        [FromQuery] int tamanhoPagina = 10,
        CancellationToken ct = default)
    {
        var resultado = await mediator.Send(
            new ListarReservaQuery(pagina, tamanhoPagina), ct);

        return Ok(RespostaApi<ResultadoPaginado<ReservaListaDto>>.Sucesso(resultado));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> ObterPorId(Guid id, CancellationToken ct)
    {
        var resultado = await mediator.Send(new ObterReservaPorIdQuery(id), ct);

        return Ok(RespostaApi<ReservaDetalheDto>.Sucesso(resultado));
    }

    [HttpPost]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    public async Task<IActionResult> Criar(
        [FromBody] CriarReservaCommand command,
        CancellationToken ct)
    {
        var resultado = await mediator.Send(command, ct);

        return CreatedAtAction(
            nameof(ObterPorId),
            new { id = resultado.Id },
            RespostaApi<CriarReservaResposta>.Sucesso(
                resultado,
                "Reserva cadastrada com sucesso!"
            )
        );
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    public async Task<IActionResult> Atualizar(
        Guid id,
        [FromBody] AtualizarReservaRequest request,
        CancellationToken ct)
    {
        var command = new AtualizarReservaCommand(
            id,
            request.QuadraId,
            request.DataAgendada,
            request.HorarioAgendado
        );

        await mediator.Send(command, ct);

        return Ok(RespostaApi.Sucesso("Reserva atualizada com sucesso!"));
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    public async Task<IActionResult> Excluir(Guid id, CancellationToken ct)
    {
        await mediator.Send(new ExcluirReservaCommand(id), ct);

        return Ok(RespostaApi.Sucesso("Reserva removida com sucesso!"));
    }
}

public record AtualizarReservaRequest(
    Guid QuadraId,
    DateTime DataAgendada,
    TimeSpan HorarioAgendado
);