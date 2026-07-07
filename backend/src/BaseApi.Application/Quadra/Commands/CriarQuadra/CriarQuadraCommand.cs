using MediatR;

namespace BaseApi.Application.Quadra.Commands.AdicionarQuadra
{
    public record CriarQuadraCommand(

    string Nome,
    string Descricao,
    int Capacidade,
    string Localizacao,
    string Modalidade,
    string ImagemUrl
    
     


) : IRequest<CriarQuadraResposta>;

    /// <summary>DTO retornado após criação bem-sucedida</summary>
    public record CriarQuadraResposta(Guid Id, string Nome, string Descricao, int Capacidade, string Localizacao, string Modalidade, string ImagemUrl);

}
