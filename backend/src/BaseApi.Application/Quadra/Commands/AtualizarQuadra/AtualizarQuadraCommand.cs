using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Application.Quadra.Commands.AtualizarQuadra
{
    public record AtualizarQuadraCommand(
    Guid Id,
    string Nome,
    string Descricao,
    string Localizacao,
    int Capacidade,
    string Modalidade,
    string ImagemUrl,
    string Status
) : IRequest<Unit>;

    public record AtualizarQuadraResposta(Guid Id, string Nome, string Descricao, int Capacidade, string Localizacao, string Modalidade, string ImagemUrl, string Status);


}
