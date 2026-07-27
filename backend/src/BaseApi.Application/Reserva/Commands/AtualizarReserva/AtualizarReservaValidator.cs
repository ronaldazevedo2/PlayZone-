using FluentValidation;

namespace BaseApi.Application.Reserva.Commands.AtualizarReserva
{
    public class AtualizarReservaValidator : AbstractValidator<AtualizarReservaCommand>
    {
        public AtualizarReservaValidator()
        {
            RuleFor(x => x.QuadraId)
                .NotEmpty().WithMessage("Marca é obrigatória.");

            RuleFor(x => x.UsuarioId)
                .NotEmpty().WithMessage("Usuario é obrigatório.");


            RuleFor(x => x.DataAgendada)
           .NotEmpty()
           .WithMessage("Data agendada é obrigatória.");

            RuleFor(x => x.HorarioAgendado)
           .NotEmpty()
           .WithMessage("Data agendada é obrigatória.");

        }
    }

}
