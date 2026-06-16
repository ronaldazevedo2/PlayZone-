using FluentValidation;

namespace BaseApi.Application.Autenticacao.Commands.RedefinirSenha;

public class RedefinirSenhaValidator : AbstractValidator<RedefinirSenhaCommand>
{
    public RedefinirSenhaValidator()
    {
        RuleFor(x => x.Token)
            .NotEmpty().WithMessage("Token é obrigatório.");

        RuleFor(x => x.NovaSenha)
            .NotEmpty().WithMessage("Nova senha é obrigatória.")
            .MinimumLength(8).WithMessage("Senha deve ter no mínimo 8 caracteres.")
            .Matches("[A-Z]").WithMessage("Senha deve conter ao menos uma letra maiúscula.")
            .Matches("[0-9]").WithMessage("Senha deve conter ao menos um número.")
            .Matches("[^a-zA-Z0-9]").WithMessage("Senha deve conter ao menos um caractere especial.");

        RuleFor(x => x.ConfirmacaoSenha)
            .Equal(x => x.NovaSenha).WithMessage("Confirmação de senha não confere.");
    }
}
