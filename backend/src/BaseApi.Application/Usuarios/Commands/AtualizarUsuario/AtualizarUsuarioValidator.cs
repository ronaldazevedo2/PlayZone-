using BaseApi.Domain.Interfaces.Repositorios;
using FluentValidation;

namespace BaseApi.Application.Usuarios.Commands.AtualizarUsuario;

public class AtualizarUsuarioValidator : AbstractValidator<AtualizarUsuarioCommand>
{
    public AtualizarUsuarioValidator(IUsuarioRepositorio repositorio)
    {
        RuleFor(x => x.Id)
            .NotEmpty().WithMessage("Id do usuário é obrigatório.");

        RuleFor(x => x.NomeCompleto)
            .NotEmpty().WithMessage("Nome completo é obrigatório.")
            .MaximumLength(150).WithMessage("Nome deve ter no máximo 150 caracteres.");

        RuleFor(x => x.Cpf)
            .NotEmpty().WithMessage("CPF é obrigatório.")
            .Matches(@"^\d{11}$")
            .WithMessage("CPF deve conter exatamente 11 números.");

        RuleFor(x => x.Telefone)
            .NotEmpty().WithMessage("Telefone é obrigatório.")
            .Matches(@"^\d{10,11}$")
            .WithMessage("Telefone deve conter 10 ou 11 números (DDD + número).");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail é obrigatório.")
            .EmailAddress().WithMessage("E-mail inválido.")
            .MustAsync(async (command, email, ct) =>
                !await repositorio.EmailExisteAsync(email, command.Id, ct))
            .WithMessage("Este e-mail já está em uso por outro usuário.");

        RuleFor(x => x.PerfilId)
            .GreaterThan(0).WithMessage("Perfil inválido.");
    }
}