using BaseApi.Application.Quadra.Commands.AdicionarQuadra;
using BaseApi.Application.Usuarios.Commands.CriarUsuario;
using BaseApi.Domain.Entidades;
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Domain.Interfaces.Servicos;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;



namespace BaseApi.Application.Quadra.Commands.CriarQuadra
{
    public class CriarQuadraHandler(
            IQuadraRepositorio repositorio,
            ISenhaServico senhaServico) : IRequestHandler<CriarQuadraCommand, CriarQuadraResposta>
    {
        public async Task<CriarQuadraResposta> Handle(CriarQuadraCommand command, CancellationToken ct)
        {
            var quadra = new BaseApi.Domain.Entidades.Quadra // Fully qualify the type to avoid ambiguity
            {
                Id = Guid.NewGuid(),
                Nome = command.Nome,
                Descricao = command.Descricao,
                Capacidade = command.Capacidade,
                Localizacao = command.Localizacao,
                Modalidade = command.Modalidade,
                ImagemUrl = command.ImagemUrl,
                Status = string.IsNullOrWhiteSpace(command.Status) ? "Ativa" : command.Status
            };

            await repositorio.AdicionarAsync(quadra, ct);
            await repositorio.SalvarAsync(ct);

            return new CriarQuadraResposta(
                quadra.Id,
                quadra.Nome,
                quadra.Descricao,
                quadra.Capacidade,
                quadra.Localizacao,
                quadra.Modalidade,
                quadra.ImagemUrl,
                quadra.Status
            );
        }
    }
}
