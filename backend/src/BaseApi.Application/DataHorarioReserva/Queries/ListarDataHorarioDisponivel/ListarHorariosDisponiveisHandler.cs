using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Queries.ListarHorariosDisponiveis;

public class ListarHorariosDisponiveisHandler(
    IDataHorarioReservaRepositorio dataHorarioRepositorio,
    IReservaRepositorio reservaRepositorio)
    : IRequestHandler<ListarHorariosDisponiveisQuery, IEnumerable<HorarioDisponivelDto>>
{
    public async Task<IEnumerable<HorarioDisponivelDto>> Handle(
        ListarHorariosDisponiveisQuery query,
        CancellationToken ct)
    {
        // Horários cadastrados pelo administrador
        var horarios = await dataHorarioRepositorio.ObterPorDataAsync(
            query.QuadraId,
            query.Data);

        // Reservas já realizadas para a quadra e data
        var (reservas, _) = await reservaRepositorio.ListarAsync(
            1,
            1000,
            query.QuadraId,
            query.Data,
            query.Data,
            ct);

        var horariosReservados = reservas
            .Select(r => r.HorarioAgendado)
            .ToHashSet();

        return horarios
            .OrderBy(h => h.Horario)
            .Select(h => new HorarioDisponivelDto(
                h.Horario,
                !horariosReservados.Contains(h.Horario)
            ));
    }
}