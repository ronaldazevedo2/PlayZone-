using BaseApi.Domain.Entidades;

namespace BaseApi.Domain.Interfaces.Servicos;

/// <summary>
/// Contrato do serviço de geração e validação de tokens JWT.
/// Implementado na Infrastructure.
/// </summary>
public interface ITokenServico
{
    /// <summary>Gera o token JWT com claims do usuário</summary>
    string GerarToken(Usuario usuario);

    /// <summary>Retorna a data de expiração do próximo token gerado</summary>
    DateTime ObterDataExpiracao();
}
