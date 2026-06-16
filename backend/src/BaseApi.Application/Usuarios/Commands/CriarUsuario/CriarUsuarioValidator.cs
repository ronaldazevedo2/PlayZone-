using BaseApi.Domain.Interfaces.Repositorios;
using FluentValidation;

namespace BaseApi.Application.Usuarios.Commands.CriarUsuario;

/// <summary>
/// Validador para CriarUsuarioCommand usando FluentValidation.
/// É executado automaticamente pelo ValidationBehavior antes do Handler.
///
/// Regras definidas aqui geram HTTP 400 com mensagens detalhadas.
/// </summary>
public class CriarUsuarioValidator : AbstractValidator<CriarUsuarioCommand>
{
    public CriarUsuarioValidator(IUsuarioRepositorio repositorio)
    {
        RuleFor(x => x.NomeCompleto)
            .NotEmpty().WithMessage("Nome completo é obrigatório.")
            .MaximumLength(150).WithMessage("Nome deve ter no máximo 150 caracteres.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail é obrigatório.")
            .EmailAddress().WithMessage("E-mail inválido.")
            .MustAsync(async (email, ct) => !await repositorio.EmailExisteAsync(email, ct: ct))
            .WithMessage("Este e-mail já está cadastrado.");

        RuleFor(x => x.Senha)
            .NotEmpty().WithMessage("Senha é obrigatória.")
            .MinimumLength(8).WithMessage("Senha deve ter no mínimo 8 caracteres.")
            .Matches("[A-Z]").WithMessage("Senha deve conter ao menos uma letra maiúscula.")
            .Matches("[0-9]").WithMessage("Senha deve conter ao menos um número.")
            .Matches("[^a-zA-Z0-9]").WithMessage("Senha deve conter ao menos um caractere especial.");

        RuleFor(x => x.PerfilId)
            .GreaterThan(0).WithMessage("Perfil inválido.");
    }
}
