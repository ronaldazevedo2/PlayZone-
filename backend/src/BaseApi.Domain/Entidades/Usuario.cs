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
    /// CPF do usuário.
    /// </summary>
    public string Cpf { get; set; } = string.Empty;

    public string Telefone { get; set; } = string.Empty;


    /// <summary>
    /// Senha armazenada como hash BCrypt — nunca salve senha em texto puro!
    /// </summary>
    public string SenhaHash { get; set; } = string.Empty;

    /// <summary>
    /// Chave estrangeira para o perfil de acesso.
    /// </summary>
    public int PerfilId { get; set; }

    public Perfil? Perfil { get; set; }

    public bool Ativo { get; set; } = true;

    /// <summary>
    /// Token utilizado para recuperação de senha.
    /// </summary>
    public string? TokenRedefinicaoSenha { get; set; }

    /// <summary>
    /// Data de expiração do token de recuperação.
    /// </summary>
    public DateTime? TokenExpiracao { get; set; }

    public DateTime CriadoEm { get; set; } = DateTime.UtcNow;

    public DateTime AtualizadoEm { get; set; } = DateTime.UtcNow;
}