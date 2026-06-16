using BaseApi.Domain.Entidades;

namespace BaseApi.Domain.Interfaces.Repositorios;

/// <summary>
/// Contrato do repositório de usuários.
/// Define as operações de persistência sem acoplar ao banco de dados.
/// A implementação fica na camada Infrastructure.
/// </summary>
public interface IUsuarioRepositorio
{
    Task<Usuario?> ObterPorIdAsync(Guid id, CancellationToken ct = default);
    Task<Usuario?> ObterPorEmailAsync(string email, CancellationToken ct = default);
    Task<Usuario?> ObterPorTokenRedefinicaoAsync(string token, CancellationToken ct = default);
    Task<(IEnumerable<Usuario> Itens, int Total)> ListarAsync(int pagina, int tamanhoPagina, string? busca, CancellationToken ct = default);
    Task<bool> EmailExisteAsync(string email, Guid? ignorarId = null, CancellationToken ct = default);
    Task AdicionarAsync(Usuario usuario, CancellationToken ct = default);
    void Atualizar(Usuario usuario);
    void Remover(Usuario usuario);
    Task SalvarAsync(CancellationToken ct = default);
}
