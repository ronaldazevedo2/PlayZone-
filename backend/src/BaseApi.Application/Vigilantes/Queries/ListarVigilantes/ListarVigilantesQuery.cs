using BaseApi.Application.Comum.Modelos;
using MediatR;

namespace BaseApi.Application.Vigilantes.Queries.ListarVigilantes;

public record ListarVigilantesQuery(
    int Pagina = 1,
    int TamanhoPagina = 10,
    string? Busca = null
) : IRequest<ResultadoPaginado<VigilanteListaDto>>;

public record VigilanteListaDto(
    int Id,
    string NomeCompleto,
    string Cpf,
    string Email,
    string Telefone,
    DateTime DataNascimento,
    string FotoPerfil,
    bool Ativo
);
