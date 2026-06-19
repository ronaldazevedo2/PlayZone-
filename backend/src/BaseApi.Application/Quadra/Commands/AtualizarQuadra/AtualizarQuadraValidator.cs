using BaseApi.Domain.Interfaces.Repositorios;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Application.Quadra.Commands.AtualizarQuadra
{
    public class AtualizarQuadraValidator : AbstractValidator<AtualizarQuadraCommand>
    {
        public AtualizarQuadraValidator(IQuadraRepositorio repositorio)
        {
            RuleFor(x => x.Nome)
                 .NotEmpty().WithMessage("O nome da quadra é obrigatório.")
                 .MaximumLength(100).WithMessage("O nome da quadra deve ter no máximo 50 caracteres.")
                 .MustAsync(async (nome, ct) => !await repositorio.NomeExisteAsync(nome, ct: ct))
                 .WithMessage("Já existe uma quadra com este nome.");

            RuleFor(x => x.Descricao)
                .MaximumLength(500).WithMessage("A descrição deve ter no máximo 500 caracteres.");

            RuleFor(x => x.Capacidade)
                .GreaterThan(0).WithMessage("A capacidade deve ser um número positivo.");

            RuleFor(x => x.Localizacao)
                .NotEmpty().WithMessage("A localização é obrigatória.")
                .MaximumLength(200).WithMessage("A localização deve ter no máximo 200 caracteres.");

            RuleFor(x => x.Modalidade)
                .NotEmpty().WithMessage("A modalidade é obrigatória.")
                .MaximumLength(50).WithMessage("A modalidade deve ter no máximo 50 caracteres.");

            RuleFor(x => x.ImagemUrl)
                .NotEmpty().WithMessage("A Imagem é obrigatória.")
                .MaximumLength(200);



        }
    }
}
