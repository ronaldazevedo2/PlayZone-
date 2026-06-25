using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Vigilantes.Queries.ObterVigilantePorId;

public class ObterVigilantePorIdHandler(IVigilanteRepositorio repositorio)
    : IRequestHandler<ObterVigilantePorIdQuery, VigilanteDetalheDto>
{
    public async Task<VigilanteDetalheDto> Handle(ObterVigilantePorIdQuery query, CancellationToken ct)
    {
        var vigilante = await repositorio.ObterPorIdAsync(query.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Vigilante com Id '{query.Id}' não encontrado.");

        return vigilante.Adapt<VigilanteDetalheDto>();
    }
}