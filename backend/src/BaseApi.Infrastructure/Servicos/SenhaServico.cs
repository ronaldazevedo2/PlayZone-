using BaseApi.Domain.Interfaces.Servicos;

namespace BaseApi.Infrastructure.Servicos;

public class SenhaServico : ISenhaServico
{
    public string GerarHash(string senha) => BCrypt.Net.BCrypt.HashPassword(senha);
    public bool Verificar(string senha, string hash) => BCrypt.Net.BCrypt.Verify(senha, hash);
}
