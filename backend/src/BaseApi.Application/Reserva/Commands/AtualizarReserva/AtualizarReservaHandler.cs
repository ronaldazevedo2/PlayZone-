using MediatR;

namespace BaseApi.Application.Reserva.Commands.AtualizarReserva;

public record AtualizarReservaCommand(
    Guid Id,
    Guid QuadraId,
    DateTime DataAgendada,
    TimeSpan HorarioAgendado
) : IRequest<Unit>;