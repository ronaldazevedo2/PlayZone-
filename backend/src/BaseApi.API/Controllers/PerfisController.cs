using BaseApi.Application.Comum.Modelos;
using BaseApi.Domain.Interfaces.Repositorios;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BaseApi.API.Controllers;

/// <summary>
/// Endpoint para listar os perfis disponíveis no sistema.
/// Usado principalmente no frontend ao criar/editar usuários.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class PerfisController(IPerfilRepositorio repositorio) : ControllerBase
{
    /// <summary>Lista todos os perfis de acesso cadastrados.</summary>
    [HttpGet]
    public async Task<IActionResult> Listar(CancellationToken ct)
    {
        var perfis = await repositorio.ListarTodosAsync(ct);
        return Ok(RespostaApi<object>.Sucesso(perfis));
    }
}
