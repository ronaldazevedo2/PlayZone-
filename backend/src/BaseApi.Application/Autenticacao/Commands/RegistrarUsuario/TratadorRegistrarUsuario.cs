using BaseApi.Domain.Entidades;
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Domain.Interfaces.Servicos;
using MediatR;

namespace BaseApi.Application.Autenticacao.Commands.RegistrarUsuario;

/// <summary>
/// Tratador para o ComandoRegistrarUsuario.
/// </summary>
public class TratadorRegistrarUsuario(
    IUsuarioRepositorio repositorioUsuario,
    ISenhaServico servicoSenha
) : IRequestHandler<ComandoRegistrarUsuario, RespostaRegistrarUsuario>
{
    public async Task<RespostaRegistrarUsuario> Handle(
        ComandoRegistrarUsuario comando,
        CancellationToken tokenCancelamento
    )
    {
        // Limpar e validar dados de entrada básicos
        var emailLimpo = comando.Email.ToLowerInvariant().Trim();

        // Verificar duplicidade de e-mail
        var emailExiste = await repositorioUsuario.EmailExisteAsync(emailLimpo, null, tokenCancelamento);
        if (emailExiste)
        {
            throw new ExcecaoDominio("Este e-mail já está cadastrado.");
        }

        // Criar a entidade Usuário (PerfilId 3 = Usuário normal)
        var novoUsuario = new Usuario
        {
            NomeCompleto = comando.NomeCompleto.Trim(),
            Email = emailLimpo,
            SenhaHash = servicoSenha.GerarHash(comando.Senha),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = DateTime.UtcNow,
            AtualizadoEm = DateTime.UtcNow
        };

        await repositorioUsuario.AdicionarAsync(novoUsuario, tokenCancelamento);
        await repositorioUsuario.SalvarAsync(tokenCancelamento);

        return new RespostaRegistrarUsuario(
            novoUsuario.Id,
            novoUsuario.NomeCompleto,
            novoUsuario.Email
        );
    }
}
