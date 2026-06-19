using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Application.Quadra.Commands.ExcluirQuadra
{
    public record ExcluirQuadraCommand(Guid Id) : IRequest<Unit>;

}


