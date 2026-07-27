using MediatR;

namespace BaseApi.Application.Reserva.Commands.CriarReserva
{
    public record CriarReservaCommand(
    Guid ReservasId,
    Guid QuadraId,
    Guid UsuarioId,
    DateTime DataAgendada,
    TimeSpan HorarioAgendado
) : IRequest<CriarReservaResposta>;

    // <summary>Dados retornados após criação bem-sucedida</summary>
    public record CriarReservaResposta(Guid ReservasId, Guid QuadraId, Guid UsuarioId, DateTime DataAgendada, TimeSpan HorarioAgendado);

}
