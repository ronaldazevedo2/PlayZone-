using BaseApi.Domain.Interfaces.Repositorios;
using FluentValidation;

namespace BaseApi.Application.Secretaria.Commands.AtualizarSecretaria;

public class AtualizarSecretariaValidator : AbstractValidator<AtualizarSecretariaCommand>
{
    public AtualizarSecretariaValidator(IDadosSecretariaRepositorio repositorio)
    {
        RuleFor(x => x.SecretariaId)
           .NotEmpty()
           .WithMessage("Id da Secretaria é obrigatório.");

        RuleFor(x => x.Nome)
           .NotEmpty().WithMessage("Nome completo é obrigatório.")
           .MaximumLength(150).WithMessage("Nome deve ter no máximo 100 caracteres.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail é obrigatório.")
            .EmailAddress().WithMessage("E-mail inválido.")
            .MustAsync(async (email, ct) => !await repositorio.EmailExisteAsync(email, ct: ct))
            .WithMessage("Este e-mail já está cadastrado.");

        RuleFor(x => x.Contato)
            .NotEmpty().WithMessage("Contato é obrigatório.")
            .Matches(@"^\(?\d{2}\)?\s?\d{4,5}-?\d{4}$")
            .WithMessage("Contato inválido.");

        RuleFor(x => x.Cep)
            .NotEmpty().WithMessage("CEP é obrigatório.")
            .Matches(@"^\d{5}-?\d{3}$")
            .WithMessage("CEP inválido. Exemplo: 12345-678.");

        RuleFor(x => x.Endereço)
            .NotEmpty().WithMessage("Endereço é obrigatório.")
            .MaximumLength(150).WithMessage("Endereço deve ter no máximo 200 caracteres.");

        RuleFor(x => x.Numero)
            .NotEmpty().WithMessage("Numero é obrigatório.")
            .MaximumLength(150).WithMessage("Numero deve ter no máximo 10 caracteres.");

        RuleFor(x => x.Bairro)
            .NotEmpty().WithMessage("Bairo é obrigatório.")
            .MaximumLength(150).WithMessage("Bairro deve ter no máximo 50 caracteres.");

        RuleFor(x => x.Cidade)
            .NotEmpty().WithMessage("Cidade é obrigatório.")
            .MaximumLength(150).WithMessage("Cidade deve ter no máximo 100 caracteres.");

       
    }
}
