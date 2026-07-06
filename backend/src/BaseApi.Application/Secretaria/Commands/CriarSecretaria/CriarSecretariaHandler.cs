using BaseApi.Application.Usuarios.Commands.CriarUsuario;
using BaseApi.Domain.Entidades;
using BaseApi.Domain.Excecoes;
using MediatR;

namespace BaseApi.Application.Secretaria.Commands.CriarSecretaria;

public class CriarSecretariaHandler(
    IDadosSecretariaRepositorio repositorio) : IRequestHandler<CriarSecretariaCommand, CriarSecretariaResposta>
{
    public async Task<CriarSecretariaResposta> Handle(CriarSecretariaCommand command, CancellationToken ct)
    {
        var secretaria = new DadosSecretaria
        {
            SecretariaId = command.SecretariaId,
            Nome = command.Nome,
            Email = command.Email.ToLowerInvariant().Trim(),
            Contato = command.Contato,
            Cep = command.Cep,
            Endereço = command.Endereço,
            Numero = command.Numero,
            Bairro = command.Bairro,
            Cidade = command.Cidade,
        };

        await repositorio.AdicionarAsync(secretaria, ct);
        await repositorio.SalvarAsync(ct);

        return new CriarSecretariaResposta( secretaria.SecretariaId, secretaria.Nome, secretaria.Email, secretaria.Contato, secretaria.Cep, secretaria.Endereço, secretaria.Numero, secretaria.Bairro, secretaria.Cidade);
    }
} 