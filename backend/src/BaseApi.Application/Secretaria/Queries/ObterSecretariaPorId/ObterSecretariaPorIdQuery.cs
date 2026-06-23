using MediatR;

namespace BaseApi.Application.Secretaria.Queries.ObterSecretariaPorId;

/// <summary>
/// Query para buscar os dados da secretaria pelo Id.
/// Queries NUNCA alteram o estado — apenas leem dados.
/// </summary>
public record ObterSecretariaPorIdQuery(Guid SecretariaId)
    : IRequest<SecretariaDetalheDto>;

/// <summary>
/// DTO com todos os detalhes da secretaria para exibição.
/// </summary>
public record SecretariaDetalheDto(
    Guid SecretariaId,
    string Nome,
    string Email,
    string Contato,
    string Cep,
    string Endereco,
    string Numero,
    string Bairro,
    string Cidade
);