using MediatR;

namespace BaseApi.Application.Telefones.Queries.ObterTelefonePorId;

/// <summary>
/// Query para buscar um único telefone pelo Id.
/// Queries NUNCA alteram dados — apenas leem.
/// </summary>
public record ObterReservaPorIdQuery(Guid ReservasId) : IRequest<ReservaDetalheDto>;

/// <summary>DTO com todos os dados da reserva para exibição</summary>
public record ReservaDetalheDto(
    Guid ReservasId,
    Guid QuadraId,
    Guid UsuarioId,
    DateTime DataAgendada,
    TimeSpan HorarioAgendado,
    string? NomeUsuario = null,
    string? EmailUsuario = null,
    string? CpfUsuario = null,
    string? TelefoneUsuario = null,
    string? NomeQuadra = null,
    string? Modalidade = null,
    string? Status = "Ativa"
);