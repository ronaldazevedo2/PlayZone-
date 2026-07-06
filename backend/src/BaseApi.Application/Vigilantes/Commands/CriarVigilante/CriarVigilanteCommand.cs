using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante;

using MediatR;

public record CriarVigilanteCommand(
    string NomeCompleto,
    string Cpf,
    string Email,
    string Telefone,
    DateTime DataNascimento,
    string? FotoPerfil,
    string Matricula,
    string Arena
) : IRequest<CriarVigilanteResposta>;

public record CriarVigilanteResposta(
    Guid Id,
    string NomeCompleto,
    string Cpf,
    string Email,
    string Telefone,
    DateTime DataNascimento,
    string? FotoPerfil,
    bool Ativo,
    DateTime CriadoEm,
    DateTime AtualizadoEm,
    string Matricula,
    string Arena
)
{
    public record CriarVigilanteCommand(
     string NomeCompleto,
     string Cpf,
     string Email,
     string Telefone,
     DateTime DataNascimento,
     string? FotoPerfil,
     string Matricula,
     string Arena
 ) : IRequest<CriarVigilanteResposta>;


}

