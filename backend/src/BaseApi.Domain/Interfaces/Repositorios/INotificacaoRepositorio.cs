using BaseApi.Domain.Entidades;

namespace BaseApi.Domain.Interfaces.Repositorios;

/// <summary>
/// Contrato das operações de persistência de Notificacao.
/// O Domain apenas define o contrato — a Infrastructure implementa.
/// </summary>
public interface INotificacaoRepositorio
{
    Task<Notificacao?> ObterPorIdAsync(Guid id, CancellationToken ct = default);

    Task<(IEnumerable<Notificacao> Itens, int Total)> ListarAsync(
        int pagina,
        int tamanhoPagina,
        string? busca,
        CancellationToken ct = default);

    Task AdicionarAsync(Notificacao Notificacao, CancellationToken ct = default);

    void Atualizar(Notificacao Notificacao);

    void Remover(Notificacao Notificacao);

    Task SalvarAsync(CancellationToken ct = default);
}