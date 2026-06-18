namespace BaseApi.Domain.Entidades;

/// <summary>
/// Entidade principal do sistema. Representa um usuário cadastrado.
/// Contém dados de autenticação e referência ao perfil de acesso.
/// </summary>
public class DadosSecretaria
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Nome { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string Contato { get; set; } = string.Empty;

    public string Cep { get; set; } = string.Empty;

    public string Endereço { get; set; } = string.Empty;

    public string Numero { get; set; } = string.Empty;

    public string Bairro { get; set; } = string.Empty;

    public string Cidade { get; set; } = string.Empty;

}
