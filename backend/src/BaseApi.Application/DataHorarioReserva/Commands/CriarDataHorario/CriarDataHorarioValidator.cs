using BaseApi.Domain.Interfaces.Repositorios;
using FluentValidation;

namespace BaseApi.Application.DataHorarioReserva.Commands.CriarDataHorarioReserva;

public class CriarDataHorarioReservaValidator : AbstractValidator<CriarDataHorarioReservaCommand>
{
    public CriarDataHorarioReservaValidator(IDataHorarioReservaRepositorio repositorio)
    {
        RuleFor(x => x.QuadraId)
            .NotEmpty()
            .WithMessage("A quadra é obrigatória.");

        RuleFor(x => x.Data)
            .NotEmpty()
            .WithMessage("A data é obrigatória.")
            .Must(data => data.Date >= DateTime.Today)
            .WithMessage("A data não pode ser anterior à data atual.");

        RuleFor(x => x.Horario)
            .NotEmpty()
            .WithMessage("O horário é obrigatório.");

        RuleFor(x => x.Horario)
            .Must(h => h >= TimeSpan.FromHours(0) && h <= TimeSpan.FromHours(23).Add(TimeSpan.FromMinutes(59)))
            .WithMessage("Horário inválido.");
    }
}