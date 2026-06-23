using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.Usuarios.Commands.CriarUsuario;
using BaseApi.Domain.Entidades;
using BaseApi.Domain.Enums;
using BaseApi.Infrastructure.Dados;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DadosSecretariaController(IMediator mediator): ControllerBase
    {
        private object _context;


        // GET: api/DadosSecretaria
        [HttpGet] //Serve para consultar ou buscar informações.
        public async Task<ActionResult<DadosSecretaria>> Get()
        {
            var dados = await _context.DadosSecretaria.FirstOrDefaultAsync();

            if (dados == null)
                return NotFound("Dados da secretaria não encontrados.");

            return Ok(dados);
        }

        // GET: api/DadosSecretaria/{id}
        [HttpGet("{id}")] //Serve para consultar ou buscar informações.
        public async Task<ActionResult<DadosSecretaria>> GetById(Guid id)
        {
            var dados = await _context.DadosSecretaria.FindAsync(id);

            if (dados == null)
                return NotFound("Dados da secretaria não encontrados.");

            return Ok(dados);
        }
     
        // POST: api/DadosSecretaria
        [HttpPost]//Serve para criar um novo registro.
        [Authorize(Roles = NomePerfil.Admin)]
        [ProducesResponseType(typeof(RespostaApi<CriarUsuarioResposta>), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Criar([FromBody] CriarUsuarioCommand command, CancellationToken ct)
        {
            // Envia o Command para o MediatR → CriarUsuarioHandler
            var resultado = await mediator.Send(command, ct);

            // Retorna 201 Created com o header Location apontando para o novo recurso
            return CreatedAtAction(
                nameof(ObterPorId),
                new { id = resultado.Id },
                RespostaApi<CriarUsuarioResposta>.Sucesso(resultado, "Usuário criado com sucesso!"));
        }

        // PUT: api/DadosSecretaria/{id}
        [HttpPut("{id}")] //Serve para atualizar um registro que já existe.
        public async Task<IActionResult> Put(Guid id, [FromBody] DadosSecretaria dados)
        {
            if (id != dados.Id)
                return BadRequest("O Id informado é diferente do objeto enviado.");

            var dadosExistentes = await _context.DadosSecretaria.FindAsync(id);

            if (dadosExistentes == null)
                return NotFound("Dados da secretaria não encontrados.");

            dadosExistentes.Nome = dados.Nome;
            dadosExistentes.Email = dados.Email;
            dadosExistentes.Contato = dados.Contato;
            dadosExistentes.Cep = dados.Cep;
            dadosExistentes.Endereço = dados.Endereço;
            dadosExistentes.Numero = dados.Numero;
            dadosExistentes.Bairro = dados.Bairro;
            dadosExistentes.Cidade = dados.Cidade;

            await _context.SaveChangesAsync();

            return Ok(dadosExistentes);
        }

        // DELETE: api/DadosSecretaria/{id}
        [HttpDelete("{id}")] //Serve para excluir um registro.
        public async Task<IActionResult> Delete(Guid id)
        {
            var dados = await _context.DadosSecretaria.FindAsync(id);

            if (dados == null)
                return NotFound("Dados da secretaria não encontrados.");

            _context.DadosSecretaria.Remove(dados);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}