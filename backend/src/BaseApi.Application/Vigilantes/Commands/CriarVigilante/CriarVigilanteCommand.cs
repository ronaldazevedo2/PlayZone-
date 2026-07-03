using MediatR;


namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante;

public record CriarVigilanteCommand(
    string NomeCompleto,
    string Cpf,
    string Email,
    string Telefone,
    DateTime DataNascimento,
    string? FotoPerfil
) : IRequest<CriarVigilanteResposta>;

public record CriarVigilanteResposta(
    int Id,
    string NomeCompleto,
    string Cpf,
    string Email,
    string Telefone,
    DateTime DataNascimento,
    string FotoPerfil,
    bool Ativo
);