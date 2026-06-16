namespace BaseApi.Domain.Enums;

/// <summary>
/// Enum com os nomes dos perfis padrão do sistema.
/// Use esses valores para verificar permissões nos controllers (ex: [Authorize(Roles = NomePerfil.Admin)]).
/// </summary>
public static class NomePerfil
{
    public const string Admin = "Admin";
    public const string Gerente = "Gerente";
    public const string Usuario = "Usuário";
}
