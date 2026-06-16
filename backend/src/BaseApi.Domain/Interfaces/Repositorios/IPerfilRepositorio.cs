using BaseApi.Domain.Entidades;

namespace BaseApi.Domain.Interfaces.Repositorios;

public interface IPerfilRepositorio
{
    Task<Perfil?> ObterPorIdAsync(int id, CancellationToken ct = default);
    Task<Perfil?> ObterPorNomeAsync(string nome, CancellationToken ct = default);
    Task<IEnumerable<Perfil>> ListarTodosAsync(CancellationToken ct = default);
}
