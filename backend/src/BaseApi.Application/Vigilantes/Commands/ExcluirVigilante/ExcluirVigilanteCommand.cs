using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.ExcluirVigilante;

public record ExcluirVigilanteCommand(int Id) : IRequest<Unit>;