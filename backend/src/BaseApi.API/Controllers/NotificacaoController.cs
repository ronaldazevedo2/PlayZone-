using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.Notificacoes.Commands.AtualizarNotificacao;
using BaseApi.Application.Notificacoes.Commands.CriarNotificacao;
using BaseApi.Application.Notificacoes.Commands.ExcluirNotificacao;
using BaseApi.Application.Notificacoes.Queries.ListarNotificacao;
using BaseApi.Application.Notificacoes.Queries.ObterNotificacaoPorId;
using BaseApi.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BaseApi.API.Controllers;

/// <summary>
/// CRUD completo de Notificacoes.
/// Todos os endpoints exigem autenticação JWT.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class NotificacoesController(IMediator mediator) : ControllerBase
{
    /// <summary>
    /// Lista telefones com paginação e filtro por marca/modelo.
    /// Qualquer usuário autenticado pode listar.
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(RespostaApi<ResultadoPaginado<NotificacaoListaDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar(
        [FromQuery] int pagina = 1,
        [FromQuery] int tamanhoPagina = 10,
        [FromQuery] string? busca = null,
        CancellationToken ct = default)
    {
        var resultado = await mediator.Send(new ListarNotificacoesQuery(pagina, tamanhoPagina, busca), ct);
        return Ok(RespostaApi<ResultadoPaginado<NotificacaoListaDto>>.Sucesso(resultado));
    }

    /// <summary>
    /// Busca um telefone específico pelo Id.
    /// </summary>
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(RespostaApi<NotificacaoDetalheDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(Guid id, CancellationToken ct)
    {
        var resultado = await mediator.Send(new ObterNotificacaoPorIdQuery(id), ct);
        return Ok(RespostaApi<NotificacaoDetalheDto>.Sucesso(resultado));
    }

    /// <summary>
    /// Cadastra um novo Notificacao no catálogo.
    /// Apenas Admin e Gerente podem cadastrar.
    /// </summary>
    /// <remarks>
    /// Exemplo de body:
    ///
    ///     {
    ///       "marca": "Samsung",
    ///       "modelo": "Galaxy S24",
    ///       "preco": 3999.90,
    ///       "estoque": 50
    ///     }
    /// </remarks>
    [HttpPost]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    [ProducesResponseType(typeof(RespostaApi<CriarNotificacaoResposta>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar([FromBody] CriarNotificacaoCommand command, CancellationToken ct)
    {
        var resultado = await mediator.Send(command, ct);
        return CreatedAtAction(
            nameof(ObterPorId),
            new { id = resultado.Id },
            RespostaApi<CriarNotificacaoResposta>.Sucesso(resultado, "Notificacao cadastrado com sucesso!"));
    }

    /// <summary>
    /// Atualiza os dados de um Notificacao existente.
    /// Apenas Admin e Gerente podem atualizar.
    /// </summary>
    [HttpPut("{id:guid}")]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Atualizar(Guid id, [FromBody] AtualizarNotificacaoRequest request, CancellationToken ct)
    {
   
        await mediator.Send(command, ct);
        return Ok(RespostaApi.Sucesso("Notificacao atualizado com sucesso!"));
    }

    /// <summary>
    /// Remove um Notificacao do catálogo permanentemente.
    /// Apenas Admin pode excluir.
    /// </summary>
    [HttpDelete("{id:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Excluir(Guid id, CancellationToken ct)
    {
        await mediator.Send(new ExcluirNotificacaoCommand(id), ct);
        return Ok(RespostaApi.Sucesso("Notificacao removida com sucesso!"));
    }
}

// DTO local para o body do PUT (separa o Id da URL dos dados do body)
public record AtualizarNotificacaoRequest(
    );