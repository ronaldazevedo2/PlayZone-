using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Usuarios.Queries.ObterUsuarioPorId;

public class ObterUsuarioPorIdHandler(IUsuarioRepositorio repositorio) : IRequestHandler<ObterUsuarioPorIdQuery, UsuarioDetalheDto>
{
    public async Task<UsuarioDetalheDto> Handle(ObterUsuarioPorIdQuery query, CancellationToken ct)
    {
        var usuario = await repositorio.ObterPorIdAsync(query.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Usuário com Id '{query.Id}' não encontrado.");

        return usuario.Adapt<UsuarioDetalheDto>();
    }
}
