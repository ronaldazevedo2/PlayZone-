using BaseApi.Application.Usuarios.Commands.CriarUsuario;
using BaseApi.Application.Usuarios.Queries.ObterUsuarioPorId;
using BaseApi.Application.Usuarios.Queries.ListarUsuarios;
using BaseApi.Domain.Entidades;
using Mapster;

namespace BaseApi.Application.Comum.Mapeamentos;

/// <summary>
/// Configuração de mapeamentos Mapster para a entidade Usuario.
/// Registrada automaticamente no startup via MapsterConfig.
///
/// Para criar CRUD de outra entidade, crie um arquivo SuaEntidadeMapeamento.cs
/// nesta pasta seguindo o mesmo padrão.
/// </summary>
public class UsuarioMapeamento : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        // Usuario → UsuarioDetalheDto
        config.NewConfig<Usuario, UsuarioDetalheDto>()
            .Map(dest => dest.NomePerfil, src => src.Perfil != null ? src.Perfil.Nome : string.Empty);

        // Usuario → UsuarioListaDto
        config.NewConfig<Usuario, UsuarioListaDto>()
            .Map(dest => dest.NomePerfil, src => src.Perfil != null ? src.Perfil.Nome : string.Empty);

        // CriarUsuarioCommand → Usuario (sem mapear SenhaHash aqui, é feito no Handler)
        config.NewConfig<CriarUsuarioCommand, Usuario>()
            .Ignore(dest => dest.SenhaHash)
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.CriadoEm)
            .Ignore(dest => dest.AtualizadoEm)
            .Ignore(dest => dest.Perfil!)
            .Ignore(dest => dest.TokenRedefinicaoSenha!)
            .Ignore(dest => dest.TokenExpiracao!);
    }
}
