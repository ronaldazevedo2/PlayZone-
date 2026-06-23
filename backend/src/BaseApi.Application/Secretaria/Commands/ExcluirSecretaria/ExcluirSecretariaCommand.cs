using MediatR;

namespace BaseApi.Application.Secretaria.Commands.ExcluirSecretaria;

public record ExcluirSecretariaCommand(Guid SecretariaId) : IRequest<Unit>;
