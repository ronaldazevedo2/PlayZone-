using MediatR;


namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante;

public record CriarVigilanteCommand(
    string NomeCompleto,
    string Cpf,
    string Email,
    string Telefone,
    DateTime DataNascimento,
    string? FotoPerfil
) : IRequest<CriarVigilanteResposta>
{
    public string Matricula { get; internal set; }
    public string Arena { get; internal set; }
}
