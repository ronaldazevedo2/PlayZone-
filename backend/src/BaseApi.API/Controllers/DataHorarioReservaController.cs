using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.DataHorarioReserva.Commands.AtualizarDataHorarioReserva;
using BaseApi.Application.DataHorarioReserva.Commands.CriarDataHorarioReserva;
using BaseApi.Application.DataHorarioReserva.Commands.ExcluirDataHorarioReserva;
using BaseApi.Application.DataHorarioReserva.Queries.ListarDataHorarioReserva;
using BaseApi.Application.DataHorarioReserva.Queries.ListarHorariosDisponiveis;
using BaseApi.Application.DataHorarioReserva.Queries.ObterDataHorarioReservaPorId;
using BaseApi.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BaseApi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class DataHorarioReservaController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Listar(
        [FromQuery] int pagina = 1,
        [FromQuery] int tamanhoPagina = 10,
        CancellationToken ct = default)
    {
        var resultado = await mediator.Send(
            new ListarDataHorarioReservaQuery(pagina, tamanhoPagina), ct);

        return Ok(RespostaApi<ResultadoPaginado<DataHorarioReservaListaDto>>.Sucesso(resultado));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> ObterPorId(Guid id, CancellationToken ct)
    {
        var resultado = await mediator.Send(
            new ObterDataHorarioReservaPorIdQuery(id), ct);

        return Ok(RespostaApi<DataHorarioReservaDetalheDto>.Sucesso(resultado));
    }

    [HttpGet("quadra/{quadraId:guid}")]
    public async Task<IActionResult> ListarPorQuadra(Guid quadraId, CancellationToken ct)
    {
        var resultado = await mediator.Send(new ListarHorariosDaQuadraQuery(quadraId), ct);
        return Ok(RespostaApi<IEnumerable<DataHorarioReservaListaDto>>.Sucesso(resultado));
    }

    [HttpGet("disponiveis")]
    public async Task<IActionResult> ListarHorariosDisponiveis(
    [FromQuery] Guid quadraId,
    [FromQuery] DateTime data,
    CancellationToken ct)
    {
        var resultado = await mediator.Send(
            new ListarHorariosDisponiveisQuery(quadraId, data), ct);

        return Ok(RespostaApi.Sucesso(resultado));
    }

    [HttpPost]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    public async Task<IActionResult> Criar(
        [FromBody] CriarDataHorarioReservaCommand command,
        CancellationToken ct)
    {
        var resultado = await mediator.Send(command, ct);

        return CreatedAtAction(
            nameof(ObterPorId),
            new { id = resultado.DataHorarioReservaId },
            RespostaApi<CriarDataHorarioReservaResposta>.Sucesso(
                resultado,
                "Data e horário cadastrados com sucesso!"
            )
        );
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    public async Task<IActionResult> Atualizar(
        Guid id,
        [FromBody] AtualizarDataHorarioReservaRequest request,
        CancellationToken ct)
    {
        var command = new AtualizarDataHorarioReservaCommand(
            id,
            request.QuadraId,
            request.Data,
            request.Horario
        );

        await mediator.Send(command, ct);

        return Ok(RespostaApi.Sucesso("Data e horário atualizados com sucesso!"));
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    public async Task<IActionResult> Excluir(Guid id, CancellationToken ct)
    {
        await mediator.Send(new ExcluirDataHorarioReservaCommand(id), ct);

        return Ok(RespostaApi.Sucesso("Data e horário removidos com sucesso!"));
    }
}

public record AtualizarDataHorarioReservaRequest(
    Guid QuadraId,
    DateTime Data,
    TimeSpan Horario
);