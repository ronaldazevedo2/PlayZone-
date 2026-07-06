using MediatR;

namespace BaseApi.Application.Reserva.Commands.CriarReserva
{
    public record CriarReservaCommand(
    Guid Id,
    Guid QuadraId,
    DateTime DataAgendada,
    TimeSpan HorarioAgendado
) : IRequest<CriarReservaResposta>;

    // <summary>Dados retornados após criação bem-sucedida</summary>
    public record CriarReservaResposta(Guid Id, DateTime DataAgendada, TimeSpan HorarioAgendado, Guid QuadraId);

}
