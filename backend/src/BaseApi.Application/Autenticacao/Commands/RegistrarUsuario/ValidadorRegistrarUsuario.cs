using BaseApi.Domain.Interfaces.Repositorios;
using FluentValidation;

namespace BaseApi.Application.Autenticacao.Commands.RegistrarUsuario;

/// <summary>
/// Validador para o ComandoRegistrarUsuario.
/// </summary>
public class ValidadorRegistrarUsuario : AbstractValidator<ComandoRegistrarUsuario>
{
    public ValidadorRegistrarUsuario(IUsuarioRepositorio repositorioUsuario)
    {
        RuleFor(x => x.NomeCompleto)
            .NotEmpty().WithMessage("Nome completo é obrigatório.")
            .MaximumLength(150).WithMessage("Nome deve ter no máximo 150 caracteres.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail é obrigatório.")
            .EmailAddress().WithMessage("E-mail inválido.")
            .MustAsync(async (email, tokenCancelamento) => !await repositorioUsuario.EmailExisteAsync(email, null, tokenCancelamento))
            .WithMessage("Este e-mail já está cadastrado.");

        RuleFor(x => x.Senha)
            .NotEmpty().WithMessage("Senha é obrigatória.")
            .MinimumLength(8).WithMessage("Senha deve ter no mínimo 8 caracteres.")
            .Matches("[A-Z]").WithMessage("Senha deve conter ao menos uma letra maiúscula.")
            .Matches("[0-9]").WithMessage("Senha deve conter ao menos um número.")
            .Matches("[^a-zA-Z0-9]").WithMessage("Senha deve conter ao menos um caractere especial.");
    }
}
