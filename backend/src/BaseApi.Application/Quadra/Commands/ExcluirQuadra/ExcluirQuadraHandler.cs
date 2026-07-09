using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Application.Quadra.Commands.ExcluirQuadra
{
    public class ExcluirQuadraHandler(IQuadraRepositorio repositorio)
    : IRequestHandler<ExcluirQuadraCommand, Unit>
    {
        public async Task<Unit> Handle(ExcluirQuadraCommand command, CancellationToken ct)
        {
            var quadra = await repositorio.ObterPorIdAsync(command.Id, ct)
                ?? throw new ExcecaoNaoEncontrado($"Quadra com Id '{command.Id}' não encontrado.");

            repositorio.Remover(quadra);
            await repositorio.SalvarAsync(ct);

            return Unit.Value;
        }
    }

}
