using FluentValidation;
using MediatR;

namespace BaseApi.Application.Comum.Comportamentos;

/// <summary>
/// Pipeline do MediatR que executa validações FluentValidation automaticamente
/// antes de qualquer Command ou Query chegar no Handler.
///
/// Como funciona:
///   1. MediatR recebe um Command/Query
///   2. Antes de chamar o Handler, passa por este Behavior
///   3. Se houver um Validator registrado, ele é executado
///   4. Se houver erros de validação, lança ValidationException
///   5. O middleware global captura e retorna HTTP 400 com os erros
///
/// Para usar: crie um arquivo Validator herdando de AbstractValidator&lt;SeuCommand&gt;
/// </summary>
public class ValidationBehavior<TRequest, TResponse>(IEnumerable<IValidator<TRequest>> validators)
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        if (!validators.Any())
            return await next();

        var contexto = new ValidationContext<TRequest>(request);
        var resultados = await Task.WhenAll(validators.Select(v => v.ValidateAsync(contexto, cancellationToken)));

        var erros = resultados
            .SelectMany(r => r.Errors)
            .Where(f => f is not null)
            .ToList();

        if (erros.Count != 0)
            throw new ValidationException(erros);

        return await next();
    }
}
