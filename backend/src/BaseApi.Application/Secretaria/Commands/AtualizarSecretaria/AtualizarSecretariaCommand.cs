using MediatR;

namespace BaseApi.Application.Secretaria.Commands.AtualizarSecretaria;

public record AtualizarSecretariaCommand(
    Guid SecretariaId,
    string Nome,
    string Email,
    string Contato,
    string Cep,
    string Endereço,
    string Numero,
    string Bairro,
    string Cidade
) : IRequest<Unit>;
