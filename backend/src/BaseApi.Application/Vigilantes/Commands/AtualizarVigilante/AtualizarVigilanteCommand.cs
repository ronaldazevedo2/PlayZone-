using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.AtualizarVigilante;

public record AtualizarVigilanteCommand(
    Guid Id,
    string NomeCompleto,
    string Cpf,
    string Matricula,
    string Arena,
    bool Ativo,
    string? FotoPerfil
) : IRequest<Unit>;