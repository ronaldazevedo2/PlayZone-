using BaseApi.Domain.Interfaces.Repositorios;
using FluentValidation;

namespace BaseApi.Application.DataHorarioReserva.Commands.AtualizarDataHorarioReserva;

public class AtualizarDataHorarioReservaValidator : AbstractValidator<AtualizarDataHorarioReservaCommand>
{
    public AtualizarDataHorarioReservaValidator(IDataHorarioReservaRepositorio repositorio)
    {
        RuleFor(x => x.QuadraId)
            .NotEmpty()
            .WithMessage("A quadra é obrigatória.");

        RuleFor(x => x.Data)
            .NotEmpty()
            .WithMessage("A data é obrigatória.");

        RuleFor(x => x.Horario)
            .NotEmpty()
            .WithMessage("O horário é obrigatório.");

        RuleFor(x => x.Data)
            .Must(data => data.Date >= DateTime.Today)
            .WithMessage("A data não pode ser anterior à data atual.");
    }
}