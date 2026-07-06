using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.ExcluirVigilante;

public record ExcluirVigilanteCommand(Guid Id) : IRequest<Unit>;