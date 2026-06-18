using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante;

/// <summary>
/// Command para criar um novo vigilante.
/// </summary>
public record CriarVigilanteCommand(
    string NomeCompleto,
    string Cpf,
    string Matricula,
    string Arena
) : IRequest<CriarVigilanteResposta>;

/// <summary>
/// Dados retornados após criação bem-sucedida.
/// </summary>
public record CriarVigilanteResposta(
    Guid Id,
    string NomeCompleto,
    string Cpf,
    string Matricula,
    string Arena
)
{
    private int id;

    public CriarVigilanteResposta(int id, string nomeCompleto, string cpf, string matricula, string arena)
    {
        this.id = id;
        NomeCompleto = nomeCompleto;
        Cpf = cpf;
        Matricula = matricula;
        Arena = arena;
    }
}
