using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Queries.ObterDataHorarioReservaPorId;

public class ObterDataHorarioReservaPorIdHandler(IDataHorarioReservaRepositorio repositorio)
    : IRequestHandler<ObterDataHorarioReservaPorIdQuery, DataHorarioReservaDetalheDto>
{
    public async Task<DataHorarioReservaDetalheDto> Handle(
        ObterDataHorarioReservaPorIdQuery query,
        CancellationToken ct)
    {
        var dataHorarioReserva = await repositorio.ObterPorIdAsync(query.DataHorarioReservaId)
            ?? throw new ExcecaoNaoEncontrado(
                $"Data/Horário com Id '{query.DataHorarioReservaId}' não encontrado.");

        // Mapster converte a entidade para o DTO automaticamente
        return dataHorarioReserva.Adapt<DataHorarioReservaDetalheDto>();
    }
}