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
        var reserva = await repositorio.ObterPorIdAsync(query.ReservasId, ct)
            ?? throw new ExcecaoNaoEncontrado($"Reserva com Id '{query.ReservasId}' não encontrado.");

        return new ReservaDetalheDto(
            reserva.ReservasId,
            reserva.QuadraId,
            reserva.UsuarioId,
            reserva.DataAgendada,
            reserva.HorarioAgendado,
            reserva.Usuario?.NomeCompleto ?? "Usuário do Sistema",
            reserva.Usuario?.Email,
            reserva.Usuario?.Cpf,
            reserva.Usuario?.Telefone,
            reserva.Quadra?.Nome ?? "Quadra",
            reserva.Quadra?.Modalidade ?? "Futebol",
            reserva.Status ?? "Ativa"
        );
    }
}