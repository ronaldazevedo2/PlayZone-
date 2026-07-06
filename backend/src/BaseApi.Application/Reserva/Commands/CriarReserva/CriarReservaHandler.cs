using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Reserva.Commands.CriarReserva
{
    public class CriarReservaHandler : IRequestHandler<CriarReservaCommand, CriarReservaResposta>
    {
        private readonly IReservaRepositorio _repositorio;

        public CriarReservaHandler(IReservaRepositorio repositorio)
        {
            _repositorio = repositorio;
        }

        public async Task<CriarReservaResposta> Handle(CriarReservaCommand command, CancellationToken ct)
        {
            var reserva = new BaseApi.Domain.Entidades.Reserva // Fully qualify the Reserva class to avoid namespace conflict
            {
                Id = Guid.NewGuid(), // Ensure the Id is initialized
                QuadraId = command.QuadraId, // Assuming QuadraId is part of the command
                DataAgendada = command.DataAgendada, // Assuming DataAgendada is part of the command
                HorarioAgendado = command.HorarioAgendado
            };

            await _repositorio.AdicionarAsync(reserva, ct);
            await _repositorio.SalvarAsync(ct);

            return new CriarReservaResposta(

                reserva.Id,
                reserva.DataAgendada,
                reserva.HorarioAgendado,
                reserva.QuadraId
            );
        }
    }
}
