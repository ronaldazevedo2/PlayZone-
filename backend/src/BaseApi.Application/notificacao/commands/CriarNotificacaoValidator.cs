using BaseApi.Application.Notificacoes.Commands.CriarNotificacao;
using FluentValidation;

namespace BaseApi.Application.Notificacoes.Commands.CriarTelefone;

/// <summary>
/// Validações executadas automaticamente antes do Handler.
/// Se qualquer regra falhar, retorna HTTP 400 com as mensagens.
/// </summary>
public class CriarNotificacaoValidator : AbstractValidator<CriarNotificacaoCommand>
{
    public CriarNotificacaoValidator()
    {
        
    }
}