using BaseApi.Domain.Entidades;

public interface IDadosSecretariaRepositorio
{
    Task<DadosSecretaria?> ObterAsync( CancellationToken ct = default);

    Task<DadosSecretaria?> ObterPorIdAsync( Guid id, CancellationToken ct = default);

    Task<bool> EmailExisteAsync(string email, Guid? ignorarId = null, CancellationToken ct = default);

    Task AdicionarAsync( DadosSecretaria dadosSecretaria, CancellationToken ct = default);

    void Atualizar(DadosSecretaria dadosSecretaria);

    Task SalvarAsync( CancellationToken ct = default);
}