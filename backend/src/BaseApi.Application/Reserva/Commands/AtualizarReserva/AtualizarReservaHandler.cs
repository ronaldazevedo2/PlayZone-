using MediatR;

namespace BaseApi.Application.Reserva.Commands.AtualizarReserva;

public record AtualizarReservaCommand(
    Guid ReservasId,
    Guid QuadraId,
    Guid UsuarioId,
    DateTime DataAgendada,
    TimeSpan HorarioAgendado
) : IRequest<Unit>;