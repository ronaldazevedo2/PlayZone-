using BaseApi.Application.Notificacoes.Queries.ObterNotificacaoPorId;
using BaseApi.Domain.Entidades;
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Notificacoes.Queries.ObterNotificacaoPorId;

public class ObterNotificacaoPorIdHandler(INotificacaoRepositorio repositorio)
    : IRequestHandler<ObterNotificacaoPorIdQuery, NotificacaoDetalheDto>
{
    public async Task<NotificacaoDetalheDto> Handle(ObterNotificacaoPorIdQuery query, CancellationToken ct)
    {
        var Notificacao = await repositorio.ObterPorIdAsync(query.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Notificacao com Id '{query.Id}' não encontrado.");

        // Mapster converte a entidade para o DTO automaticamente
        return Notificacao.Adapt<NotificacaoDetalheDto>();
    }
}