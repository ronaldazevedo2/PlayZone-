using FluentValidation;

namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante;

public class CriarVigilanteValidator : AbstractValidator<CriarVigilanteCommand>
{
    public CriarVigilanteValidator()
    {

        RuleFor(x => x.NomeCompleto)
            .NotEmpty().WithMessage("Nome é obrigatório.")
            .MaximumLength(150).WithMessage("Nome deve ter no máximo 150 caracteres.");

        RuleFor(x => x.Cpf)
            .NotEmpty().WithMessage("CPF é obrigatório.")
            .Length(11).WithMessage("CPF deve possuir 11 dígitos.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email é obrigatória.")
            .MaximumLength(20).WithMessage("Email deve ter no máximo 20 caracteres.");

        RuleFor(x => x.Telefone)
           .NotEmpty().WithMessage("Telefone é obrigatória.")
           .MaximumLength(20).WithMessage("Telefone deve ter no máximo 20 caracteres.");

        RuleFor(x => x.DataNascimento)
           .NotEmpty().WithMessage("Data de nascimento é obrigatória.")
           .LessThan(DateTime.Today).WithMessage("Data de nascimento deve ser no passado.");

        RuleFor(x => x.FotoPerfil)
            .NotEmpty().WithMessage("Foto de perfil é obrigatória.")
            .MaximumLength(500).WithMessage("Foto de perfil deve ter no máximo 500 caracteres.");

        RuleFor(x => x.Matricula)
            .NotEmpty().WithMessage("Matrícula é obrigatória.")
            .MaximumLength(20).WithMessage("Matrícula deve ter no máximo 20 caracteres.");

        RuleFor(x => x.Arena)
            .NotEmpty().WithMessage("Arena é obrigatória.")
            .MaximumLength(100).WithMessage("Arena deve ter no máximo 100 caracteres.");


    }
}