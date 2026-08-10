using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Commands.ExcluirDataHorarioReserva;

public record ExcluirDataHorarioReservaCommand(Guid DataHorarioReservaId) : IRequest<Unit>;