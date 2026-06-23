using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.AtualizarVigilante;

public record AtualizarVigilanteCommand(
    int Id,
    string NomeCompleto,
    string Cpf,
    string Matricula,
    string Arena,
    bool Ativo
) : IRequest<Unit>;