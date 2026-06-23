using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante;

public class CriarVigilanteHandler(IVigilanteRepositorio repositorio)
    : IRequestHandler<CriarVigilanteCommand, CriarVigilanteResposta>
{
    public async Task<CriarVigilanteResposta> Handle(CriarVigilanteCommand command, CancellationToken ct)
    {
        var vigilante = new Vigilante
        {
            NomeCompleto = command.NomeCompleto.Trim(),
            Cpf = command.Cpf.Trim(),
            Matricula = command.Matricula.Trim(),
            Arena = command.Arena.Trim(),
            Ativo = true,
            CriadoEm = DateTime.UtcNow,
            AtualizadoEm = DateTime.UtcNow
        };

        await repositorio.AdicionarAsync(vigilante, ct);
        await repositorio.SalvarAsync(ct);

        return new CriarVigilanteResposta(
            vigilante.Id,
            vigilante.NomeCompleto,
            vigilante.Cpf,
            vigilante.Matricula,
            vigilante.Arena
        );
    }
}