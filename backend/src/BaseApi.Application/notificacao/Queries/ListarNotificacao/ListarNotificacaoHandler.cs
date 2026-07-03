using MediatR;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Application.Notificacoes.Queries.ObterNotificacaoPorId;
using BaseApi.Domain.Entidades;

namespace BaseApi.Application.Notificacoes.Queries.ListarNotificacao;

public class ListarNotificacaoHandler : IRequestHandler<ListarNotificacaoQuery, List<NotificacaoDetalheDto>>
{
    private readonly INotificacaoRepositorio _notificacaoRepositorio;

    public ListarNotificacaoHandler(INotificacaoRepositorio notificacaoRepositorio)
    {
        _notificacaoRepositorio = notificacaoRepositorio;
    }

    public async Task<List<NotificacaoDetalheDto>> Handle(ListarNotificacaoQuery request, CancellationToken cancellationToken)
    {
        var notificacoes = await _notificacaoRepositorio.ObterTodosAsync();

        // Corrige o problema de tipagem e fornece o valor necessário para o parâmetro 'id'
        return notificacoes.OfType<Notificacao>().Select(n => new NotificacaoDetalheDto(
            Guid.NewGuid(), // Gera um novo Guid para o Id
            n.CriadoEm      // Usa o valor de CriadoEm da entidade Notificacao
        )).ToList();
    }
}

public record NotificacaoDetalheDto : IEquatable<NotificacaoDetalheDto>
{
    public Guid Id { get; init; }
    public DateTime CriadoEm { get; init; }

    // Adiciona um construtor para inicializar as propriedades
    public NotificacaoDetalheDto(Guid id, DateTime criadoEm)
    {
        Id = id;
        CriadoEm = criadoEm;
    }
}

// Renomeia a classe para evitar conflito com outra definição de ListarNotificacaoQuery
public record ListarTodasNotificacoesQuery : IRequest<List<NotificacaoDetalheDto>>, IBaseRequest, IEquatable<ListarTodasNotificacoesQuery>
{
}
