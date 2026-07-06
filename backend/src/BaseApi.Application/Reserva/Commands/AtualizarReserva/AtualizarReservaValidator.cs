using BaseApi.Application.Reserva.Commands.CriarReserva;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Application.Reserva.Commands.AtualizarReserva
{
    public class AtualizarReservaValidator : AbstractValidator<AtualizarReservaCommand>
    {
        public AtualizarReservaValidator()
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
