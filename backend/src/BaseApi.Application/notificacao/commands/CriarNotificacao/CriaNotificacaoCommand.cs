using MediatR;

namespace BaseApi.Application.Notificacoes.Commands.CriarNotificacao;

/// <summary>
/// Command para criar um novo Notificacao no catálogo.
/// "record" é imutável — ideal para Commands (não muda depois de criado).
/// </summary>
public record CriarNotificacaoCommand(
    
) : IRequest<CriarNotificacaoResposta>;

/// <summary>Dados retornados após criação bem-sucedida</summary>
