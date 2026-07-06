using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Application.Quadra.Queries
{
    public record ObterQuadraPorIdQuery(Guid Id) : IRequest<QuadraDetalheDto>;

    /// <summary>DTO com todos os dados do telefone para exibição</summary>
    public record QuadraDetalheDto(
        Guid Id,
        string Nome,
        string Descricao,
        string Localizacao,
        int Capacidade,
        string Modalidade,
        string ImagemUrl
    );

}
