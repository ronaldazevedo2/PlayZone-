using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ObterTelefonePorId;

public class ObterReservaPorIdHandler(IReservaRepositorio repositorio)
    : IRequestHandler<ObterReservaPorIdQuery, ReservaDetalheDto>
{
    public async Task<ReservaDetalheDto> Handle(ObterReservaPorIdQuery query, CancellationToken ct)
    {
        var reserva = await repositorio.ObterPorIdAsync(query.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Reserva com Id '{query.Id}' não encontrado.");

        // Mapster converte a entidade para o DTO automaticamente
        return reserva.Adapt<ReservaDetalheDto>();
    }
}