using FluentValidation;

namespace BaseApi.Application.Vigilantes.Commands.AtualizarVigilante;

public class AtualizarVigilanteValidator : AbstractValidator<AtualizarVigilanteCommand>
{
    public AtualizarVigilanteValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Id do vigilante é obrigatório.");

        RuleFor(x => x.NomeCompleto)
            .NotEmpty().WithMessage("Nome é obrigatório.")
            .MaximumLength(150).WithMessage("Nome deve ter no máximo 150 caracteres.");

        RuleFor(x => x.Cpf)
            .NotEmpty().WithMessage("CPF é obrigatório.")
            .Length(11).WithMessage("CPF deve possuir 11 dígitos.");

        RuleFor(x => x.Matricula)
            .NotEmpty().WithMessage("Matrícula é obrigatória.")
            .MaximumLength(20).WithMessage("Matrícula deve ter no máximo 20 caracteres.");

        RuleFor(x => x.Arena)
            .NotEmpty().WithMessage("Arena é obrigatória.")
            .MaximumLength(100).WithMessage("Arena deve ter no máximo 100 caracteres.");
    }
}