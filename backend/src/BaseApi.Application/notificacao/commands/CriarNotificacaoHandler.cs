using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Notificacoes.Commands.CriarNotificacao;

/// <summary>
/// Handler que contém a lógica de negócio para criar uma Notificacao.
/// Só é executado se o Validator passar sem erros.
/// </summary>
public class CriarNotificacaoHandler(INotificacaoRepositorio repositorio)
    : IRequestHandler<CriarNotificacaoCommand, CriarNotificacaoResposta>
{
    public async Task<CriarNotificacaoResposta> Handle(CriarNotificacaoCommand command, CancellationToken ct)
    {
        var Notificacao = new Notificacao
        {
            // Inicialize as propriedades necessárias aqui
        };

        await repositorio.AdicionarAsync(Notificacao, ct);
        await repositorio.SalvarAsync(ct);

        // Retorne uma instância de CriarNotificacaoResposta
        return new CriarNotificacaoResposta();
    }
}
