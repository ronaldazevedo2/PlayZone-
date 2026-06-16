namespace BaseApi.Domain.Entidades;

/// <summary>
/// Entidade que representa um perfil de acesso no sistema.
/// Perfis são usados para controlar permissões (ex: Admin, Gerente, Usuário).
/// </summary>
public class Perfil
{
    public int Id { get; set; }

    /// <summary>Nome do perfil (ex: "Admin", "Gerente", "Usuário")</summary>
    public string Nome { get; set; } = string.Empty;

    public string Descricao { get; set; } = string.Empty;

    // Navegação: um perfil pode ter vários usuários
    public ICollection<Usuario> Usuarios { get; set; } = new List<Usuario>();
}
