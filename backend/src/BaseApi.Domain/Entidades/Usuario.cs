namespace BaseApi.Domain.Entidades;

/// <summary>
/// Entidade principal do sistema. Representa um usuário cadastrado.
/// Contém dados de autenticação e referência ao perfil de acesso.
/// </summary>
public class Usuario
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string NomeCompleto { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// Senha armazenada como hash BCrypt — nunca salve senha em texto puro!
    /// </summary>
    public string SenhaHash { get; set; } = string.Empty;

    /// <summary>Chave estrangeira para o perfil de acesso</summary>
    public int PerfilId { get; set; }

    public Perfil? Perfil { get; set; }

    public bool Ativo { get; set; } = true;

    // Campos usados no fluxo de recuperação de senha
    public string? TokenRedefinicaoSenha { get; set; }
    public DateTime? TokenExpiracao { get; set; }

    public DateTime CriadoEm { get; set; } = DateTime.UtcNow;
    public DateTime AtualizadoEm { get; set; } = DateTime.UtcNow;
}
