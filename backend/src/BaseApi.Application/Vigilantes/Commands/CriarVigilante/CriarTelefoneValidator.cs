using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante
{
    using BaseApi.Application.vigilantes.Commands.CriarVigilantes;
    using FluentValidation;



    /// <summary>
    /// Validações executadas automaticamente antes do Handler.
    /// Se qualquer regra falhar, retorna HTTP 400 com as mensagens.
    /// </summary>
    public class CriarVigilanteValidator : AbstractValidator<CriarVigilanteCommand>
    {
        public CriarVigilanteValidator()
        {
            RuleFor(x => x.Marca)
                .NotEmpty().WithMessage("Marca é obrigatória.")
                .MaximumLength(100).WithMessage("Marca deve ter no máximo 100 caracteres.");

            RuleFor(x => x.Modelo)
                .NotEmpty().WithMessage("Modelo é obrigatório.")
                .MaximumLength(150).WithMessage("Modelo deve ter no máximo 150 caracteres.");

            RuleFor(x => x.Preco)
                .GreaterThan(0).WithMessage("Preço deve ser maior que zero.");

            RuleFor(x => x.Estoque)
                .GreaterThanOrEqualTo(0).WithMessage("Estoque não pode ser negativo.");
        }
    }
}
