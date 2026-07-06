using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Quadra.Queries
{
    public class ObterQuadraPorIdHandler(IQuadraRepositorio repositorio) : IRequestHandler<ObterQuadraPorIdQuery, QuadraDetalheDto>
    {
        public async Task<QuadraDetalheDto> Handle(ObterQuadraPorIdQuery query, CancellationToken ct)
        {
            var quadra = await repositorio.ObterPorIdAsync(query.Id, ct)
                ?? throw new ExcecaoNaoEncontrado($"Quadra com Id '{query.Id}' não encontrado.");

            return quadra.Adapt<QuadraDetalheDto>();
        }
    }

}
