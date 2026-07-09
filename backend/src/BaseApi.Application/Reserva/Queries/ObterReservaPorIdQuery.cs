using MediatR;

namespace BaseApi.Application.Telefones.Queries.ObterTelefonePorId;

/// <summary>
/// Query para buscar um único telefone pelo Id.
/// Queries NUNCA alteram dados — apenas leem.
/// </summary>
public record ObterReservaPorIdQuery(Guid Id) : IRequest<ReservaDetalheDto>;

/// <summary>DTO com todos os dados do telefone para exibição</summary>
public record ReservaDetalheDto(
    Guid Id,
    Guid QuadraId,
    DateTime DataAgendada,
    TimeSpan HorarioAgendado
);