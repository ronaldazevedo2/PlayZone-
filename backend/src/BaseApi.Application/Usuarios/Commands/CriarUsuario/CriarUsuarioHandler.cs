using BaseApi.Domain.Entidades;
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Domain.Interfaces.Servicos;
using MediatR;

namespace BaseApi.Application.Usuarios.Commands.CriarUsuario;

/// <summary>
/// Handler do Command CriarUsuario.
/// Contém a lógica de negócio para criação de um novo usuário.
///
/// Fluxo de execução:
///   1. ValidationBehavior executa o CriarUsuarioValidator
///   2. Se válido, este Handler é chamado
///   3. Handler aplica regras de negócio e persiste no banco
/// </summary>
public class CriarUsuarioHandler(
    IUsuarioRepositorio repositorio,
    ISenhaServico senhaServico) : IRequestHandler<CriarUsuarioCommand, CriarUsuarioResposta>
{
    public async Task<CriarUsuarioResposta> Handle(CriarUsuarioCommand command, CancellationToken ct)
    {
        var perfilValido = command.PerfilId is >= 1 and <= 3;
        if (!perfilValido)
            throw new ExcecaoDominio("Perfil de acesso inválido.");

        var usuario = new Usuario
        {
            NomeCompleto = command.NomeCompleto,
            Email = command.Email.ToLowerInvariant().Trim(),
            SenhaHash = senhaServico.GerarHash(command.Senha),
            PerfilId = command.PerfilId,
            Ativo = true,
            CriadoEm = DateTime.UtcNow,
            AtualizadoEm = DateTime.UtcNow
        };

        await repositorio.AdicionarAsync(usuario, ct);
        await repositorio.SalvarAsync(ct);

        return new CriarUsuarioResposta(usuario.Id, usuario.NomeCompleto, usuario.Email);
    }
}
