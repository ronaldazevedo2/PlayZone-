using MediatR;

namespace BaseApi.Application.Telefones.Commands.ExcluirTelefone;

public record ExcluirReservaCommand(Guid Id) : IRequest<Unit>;