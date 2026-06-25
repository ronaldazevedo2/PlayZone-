namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante;

public record CriarVigilanteResposta(
    Guid Id,
    string NomeCompleto,
    string Cpf,
    string Matricula,
    string Arena
);