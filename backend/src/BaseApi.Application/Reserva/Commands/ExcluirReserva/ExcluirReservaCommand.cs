using MediatR;

namespace BaseApi.Application.Telefones.Commands.ExcluirTelefone;

public record ExcluirReservaCommand(Guid ReservasId) : IRequest<Unit>;