using BaseApi.Application.Comum.Modelos;
using MediatR;

namespace BaseApi.Application.Secretaria.Queries.ListarSecretaria;

public record ListarSecretariaQuery(
    int Pagina = 1,
    int TamanhoPagina = 10,
    string? Busca = null
) : IRequest<ResultadoPaginado<SecretariaListaDto>>;

public record SecretariaListaDto(
    Guid SecretariaId,
    string Nome,
    string Email,
    string Contato,
    string Cep,
    string Endereço,
    string Numero,
    string Bairro,
    string Cidade
);
