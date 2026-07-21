using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.Usuarios.Commands.AtualizarUsuario;
using BaseApi.Application.Usuarios.Commands.CriarUsuario;
using BaseApi.Application.Usuarios.Commands.ExcluirUsuario;
using BaseApi.Application.Usuarios.Queries.ListarUsuarios;
using BaseApi.Application.Usuarios.Queries.ObterUsuarioPorId;
using BaseApi.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BaseApi.API.Controllers;

/// <summary>
/// ============================================================
/// CRUD COMPLETO DE USUÁRIOS — USE COMO EXEMPLO PARA OUTROS CRUDs
/// ============================================================
///
/// Para criar um CRUD para outra entidade (ex: Produto), siga este modelo:
///
///   1. Domain:          Crie Entidades/Produto.cs
///   2. Domain:          Crie Interfaces/Repositorios/IProdutoRepositorio.cs
///   3. Application:     Crie Produtos/Commands/CriarProduto/ (Command + Handler + Validator)
///   4. Application:     Crie Produtos/Commands/AtualizarProduto/
///   5. Application:     Crie Produtos/Commands/ExcluirProduto/
///   6. Application:     Crie Produtos/Queries/ObterProdutoPorId/
///   7. Application:     Crie Produtos/Queries/ListarProdutos/
///   8. Infrastructure:  Crie Dados/Configuracoes/ProdutoConfiguracao.cs
///   9. Infrastructure:  Crie Repositorios/ProdutoRepositorio.cs
///  10. Infrastructure:  Registre em DependencyInjection.cs
///  11. API:             Crie Controllers/ProdutosController.cs (baseado neste arquivo)
///
/// Todos os endpoints exigem autenticação JWT exceto onde marcado como [AllowAnonymous].
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class UsuariosController(IMediator mediator) : ControllerBase
{
    // =========================================================
    // GET /api/usuarios
    // =========================================================
    [HttpGet]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    [ProducesResponseType(typeof(RespostaApi<ResultadoPaginado<UsuarioListaDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar(
        [FromQuery] int pagina = 1,
        [FromQuery] int tamanhoPagina = 10,
        [FromQuery] string? busca = null,
        CancellationToken ct = default)
    {
        var resultado = await mediator.Send(new ListarUsuariosQuery(pagina, tamanhoPagina, busca), ct);
        return Ok(RespostaApi<ResultadoPaginado<UsuarioListaDto>>.Sucesso(resultado));
    }

    // =========================================================
    // GET /api/usuarios/{id}
    // =========================================================
    [HttpGet("{id:guid}")]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    [ProducesResponseType(typeof(RespostaApi<UsuarioDetalheDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(Guid id, CancellationToken ct)
    {
        var resultado = await mediator.Send(new ObterUsuarioPorIdQuery(id), ct);
        return Ok(RespostaApi<UsuarioDetalheDto>.Sucesso(resultado));
    }

    // =========================================================
    // POST /api/usuarios
    // =========================================================
    /// <remarks>
    /// Exemplo de body:
    ///
    /// {
    ///   "nomeCompleto": "João da Silva",
    ///   "cpf": "12345678901",
    ///   "telefone": "(27) 99999-9999",
    ///   "email": "joao@exemplo.com",
    ///   "senha": "Senha@123",
    ///   "perfilId": 3
    /// }
    ///
    /// PerfilId:
    /// 1 = Admin
    /// 2 = Gerente
    /// 3 = Usuário
    /// </remarks>
    [HttpPost]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi<CriarUsuarioResposta>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar([FromBody] CriarUsuarioCommand command, CancellationToken ct)
    {
        var resultado = await mediator.Send(command, ct);

        return CreatedAtAction(
            nameof(ObterPorId),
            new { id = resultado.Id },
            RespostaApi<CriarUsuarioResposta>.Sucesso(resultado, "Usuário criado com sucesso!"));
    }

    // =========================================================
    // PUT /api/usuarios/{id}
    // =========================================================
    [HttpPut("{id:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Atualizar(Guid id, [FromBody] AtualizarUsuarioRequest request, CancellationToken ct)
    {
        var command = new AtualizarUsuarioCommand(
            id,
            request.NomeCompleto,
            request.Cpf,
            request.Telefone,
            request.Email,
            request.PerfilId,
            request.Ativo);

        await mediator.Send(command, ct);

        return Ok(RespostaApi.Sucesso("Usuário atualizado com sucesso!"));
    }

    // =========================================================
    // DELETE /api/usuarios/{id}
    // =========================================================
    [HttpDelete("{id:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Excluir(Guid id, CancellationToken ct)
    {
        await mediator.Send(new ExcluirUsuarioCommand(id), ct);
        return Ok(RespostaApi.Sucesso("Usuário excluído com sucesso!"));
    }
}

// DTO utilizado no PUT
public record AtualizarUsuarioRequest(
    string NomeCompleto,
    string Cpf,
    string Telefone,
    string Email,
    int PerfilId,
    bool Ativo);