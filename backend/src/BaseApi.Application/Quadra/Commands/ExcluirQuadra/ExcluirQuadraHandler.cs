using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Application.Quadra.Commands.ExcluirQuadra
{
    public class ExcluirQuadraHandler(IQuadraRepositorio repositorio)
        : IRequestHandler<ExcluirQuadraCommand, Unit>
    {
        public async Task<Unit> Handle(ExcluirQuadraCommand command, CancellationToken ct)
        {
            var quadra = await repositorio.ObterPorIdAsync(command.Id, ct)
                ?? throw new ExcecaoNaoEncontrado($"Quadra com Id '{command.Id}' não encontrada.");

            try
            {
                repositorio.Remover(quadra);
                await repositorio.SalvarAsync(ct);

                return Unit.Value;
            }
            catch (DbUpdateException)
            {
                throw new ExcecaoDominio("Não é possível excluir a quadra porque existem reservas vinculadas a ela.");
            }
        }
    }
}