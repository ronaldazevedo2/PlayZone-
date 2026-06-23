using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Secretaria.Queries.ObterSecretariaPorId;

public class ObterSecretariaPorIdHandler(IDadosSecretariaRepositorio repositorio)
    : IRequestHandler<ObterSecretariaPorIdQuery, SecretariaDetalheDto>
{
    public async Task<SecretariaDetalheDto> Handle(
        ObterSecretariaPorIdQuery query,
        CancellationToken ct)
    {
        var secretaria = await repositorio.ObterPorIdAsync(query.SecretariaId, ct)
            ?? throw new ExcecaoNaoEncontrado(
                $"Secretaria com Id '{query.SecretariaId}' não encontrada.");

        return secretaria.Adapt<SecretariaDetalheDto>();
    }
}