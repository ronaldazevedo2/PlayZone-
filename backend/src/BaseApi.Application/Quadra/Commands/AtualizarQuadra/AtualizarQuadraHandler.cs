using BaseApi.Application.Quadra.Commands.AtualizarQuadra;
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Telefones.Commands.AtualizarTelefone;

public class AtualizarQuadraHandler(IQuadraRepositorio repositorio)

    : IRequestHandler<AtualizarQuadraCommand, Unit>
{
    public async Task<Unit> Handle(AtualizarQuadraCommand command, CancellationToken ct)
    {
        var quadra = await repositorio.ObterPorIdAsync(command.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Quadra com Id '{command.Id}' não encontrado.");

        // Atualiza apenas os campos permitidos
        quadra.Nome = command.Nome.Trim();
        quadra.Descricao = command.Descricao.Trim();
        quadra.Capacidade = command.Capacidade;
        quadra.Localizacao = command.Localizacao;
        quadra.Modalidade = command.Modalidade;
        quadra.ImagemUrl = command.ImagemUrl;
        if (!string.IsNullOrWhiteSpace(command.Status)) {
            quadra.Status = command.Status;
        }

        repositorio.Atualizar(quadra);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}