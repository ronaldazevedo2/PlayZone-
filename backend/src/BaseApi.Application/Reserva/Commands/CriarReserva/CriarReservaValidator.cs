using FluentValidation;

namespace BaseApi.Application.Reserva.Commands.CriarReserva
{
    public class CriarReservaValidator : AbstractValidator<CriarReservaCommand>
    {
        public CriarReservaValidator()
        {
            RuleFor(x => x.QuadraId)
                .NotEmpty().WithMessage("Marca é obrigatória.");


            RuleFor(x => x.DataAgendada)
           .NotEmpty()
           .WithMessage("Data agendada é obrigatória.");

            RuleFor(x => x.HorarioAgendado)
           .NotEmpty()
           .WithMessage("Data agendada é obrigatória.");

        }
    }


}
