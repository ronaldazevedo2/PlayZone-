using BaseApi.Domain.Entidades;

namespace BaseApi.Domain.Interfaces.Repositorios;

/// <summary>
/// Contrato do repositório de quadras.
/// Define as operações de persistência sem acoplar ao banco de dados.
/// A implementação fica na camada Infrastructure.
/// </summary>
public interface IQuadraRepositorio
{
    Task<Quadra?> ObterPorIdAsync(Guid id, CancellationToken ct = default);
    Task<Quadra?> ObterPorNomeAsync(string nome, CancellationToken ct = default);
    Task<IEnumerable<Quadra>> FiltrarPorModalidadeAsync(string modalidade, CancellationToken ct = default);
    Task<IEnumerable<Quadra>> FiltrarPorLocalizacaoAsync(string localizacao, CancellationToken ct = default);
    Task<(IEnumerable<Quadra> Itens, int Total)> ListarAsync(int pagina, int tamanhoPagina, string? busca, CancellationToken ct = default);
    Task<bool> NomeExisteAsync(string nome, Guid? ignorarId = null, CancellationToken ct = default);
    Task AdicionarAsync(Quadra quadra, CancellationToken ct = default);
    void Atualizar(Quadra quadra);
    void Remover(Quadra quadra);
    Task SalvarAsync(CancellationToken ct = default);
}