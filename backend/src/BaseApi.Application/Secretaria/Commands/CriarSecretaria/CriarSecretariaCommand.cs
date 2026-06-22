using MediatR;

namespace BaseApi.Application.Usuarios.Commands.CriarUsuario;
public record CriarSecretariaCommand(
    Guid SecretariaId,
    string Nome,
    string Email,
    string Contato,
    string Cep,
    string Endereço,
    string Numero,
    string Bairro,
    string Cidade
) : IRequest<CriarSecretariaResposta>;

/// <summary>DTO retornado após criação bem-sucedida</summary>
public record CriarSecretariaResposta(Guid SecretariaId, string Nome, string Email, string Contato, string Cep, string endereço, string Numero, string Bairro, string Cidade);
