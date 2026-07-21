using BaseApi.Application.Usuarios.Commands.CriarUsuario;
using BaseApi.Application.Usuarios.Queries.ListarUsuarios;
using BaseApi.Application.Usuarios.Queries.ObterUsuarioPorId;
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
            .Map(dest => dest.NomePerfil, src => src.Perfil != null ? src.Perfil.Nome : string.Empty)
            .Map(dest => dest.Cpf, src => src.Cpf)
            .Map(dest => dest.Telefone, src => src.Telefone);

        // Usuario → UsuarioListaDto
        config.NewConfig<Usuario, UsuarioListaDto>()
            .Map(dest => dest.NomePerfil, src => src.Perfil != null ? src.Perfil.Nome : string.Empty)
            .Map(dest => dest.Cpf, src => src.Cpf)
            .Map(dest => dest.Telefone, src => src.Telefone);

        // CriarUsuarioCommand → Usuario
        config.NewConfig<CriarUsuarioCommand, Usuario>()
            .Map(dest => dest.Cpf, src => src.Cpf)
            .Map(dest => dest.Telefone, src => src.Telefone)
            .Ignore(dest => dest.SenhaHash)
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.CriadoEm)
            .Ignore(dest => dest.AtualizadoEm)
            .Ignore(dest => dest.Perfil!)
            .Ignore(dest => dest.TokenRedefinicaoSenha!)
            .Ignore(dest => dest.TokenExpiracao!);
    }
}