using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.ExcluirVigilante;

public class ExcluirVigilanteHandler : IRequestHandler<ExcluirVigilanteCommand, Unit>
{
    private readonly IVigilanteRepositorio _repositorio;

    public ExcluirVigilanteHandler(IVigilanteRepositorio repositorio)
    {
        _repositorio = repositorio;
    }

    public async Task<Unit> Handle(ExcluirVigilanteCommand request, CancellationToken ct)
    {
        var vigilante = await _repositorio.ObterPorIdAsync(request.Id, ct);

        if (vigilante is null)
            throw new ExcecaoNaoEncontrado($"Vigilante com Id '{request.Id}' não encontrado.");

        _repositorio.Remover(vigilante);
        await _repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}