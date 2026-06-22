using BaseApi.Domain.Entidades;

public interface IDadosSecretariaRepositorio
{
    Task<DadosSecretaria?> ObterAsync( CancellationToken ct = default);

    Task<DadosSecretaria?> ObterPorIdAsync( Guid secretariaid, CancellationToken ct = default);

    Task<bool> EmailExisteAsync(string email, Guid? ignorarId = null, CancellationToken ct = default);

    Task AdicionarAsync( DadosSecretaria secretaria, CancellationToken ct = default);

    void Atualizar(DadosSecretaria secretaria);
    void Remover(DadosSecretaria secretaria);

    Task SalvarAsync( CancellationToken ct = default);
    Task<(object itens, int total)> ListarAsync(int pagina, int tamanhoPagina, string busca, CancellationToken ct);
}