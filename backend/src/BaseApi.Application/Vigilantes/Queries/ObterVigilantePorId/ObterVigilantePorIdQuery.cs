using MediatR;

namespace BaseApi.Application.Vigilantes.Queries.ObterVigilantePorId;

/// <summary>
/// Query para buscar um único vigilante pelo Id.
/// Queries nunca alteram dados.
/// </summary>
public record ObterVigilantePorIdQuery(Guid Id) : IRequest<VigilanteDetalheDto>;
/// <summary>
/// DTO com todos os dados do vigilante para exibição.
/// </summary>
public record VigilanteDetalheDto(
    int Id,
    string NomeCompleto,
    string Cpf,
    string Email,
    string Telefone,
    DateTime DataNascimento,
    string FotoPerfil,
    string Matricula,
    string Arena,
    bool Ativo,
    DateTime CriadoEm
);