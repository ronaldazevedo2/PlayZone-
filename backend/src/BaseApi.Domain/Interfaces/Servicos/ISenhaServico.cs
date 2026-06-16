namespace BaseApi.Domain.Interfaces.Servicos;

/// <summary>
/// Contrato do serviço de hash de senha.
/// Mantemos BCrypt na Infrastructure — a Application só conhece esta interface.
/// </summary>
public interface ISenhaServico
{
    string GerarHash(string senha);
    bool Verificar(string senha, string hash);
}
