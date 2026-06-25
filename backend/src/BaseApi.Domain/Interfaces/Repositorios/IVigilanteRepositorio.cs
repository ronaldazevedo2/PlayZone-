using BaseApi.Domain.Entidades;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Domain.Interfaces.Repositorios;

public interface IVigilanteRepositorio
{
    Task<Vigilante?> ObterPorIdAsync(Guid id, CancellationToken ct);
    Task<(IEnumerable<Vigilante> Itens, int Total)> ListarAsync(
        int pagina,
        int tamanhoPagina,
        string? busca,
        CancellationToken ct = default);

    Task AdicionarAsync(Vigilante vigilante , CancellationToken ct = default);

    void Atualizar(Vigilante vigilante );

    void Remover(Vigilante vigilante );

    Task SalvarAsync(CancellationToken ct = default);
}
