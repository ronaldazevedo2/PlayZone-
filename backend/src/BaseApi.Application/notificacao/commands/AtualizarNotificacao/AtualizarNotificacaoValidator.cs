using FluentValidation;

namespace BaseApi.Application.Notificacoes.Commands.AtualizarNotificacao;

public class AtualizarNotificacaoValidator : AbstractValidator<AtualizarNotificacaoCommand>
{
    public AtualizarNotificacaoValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty().WithMessage("Id da Notificacao é obrigatório.");

    }  
}