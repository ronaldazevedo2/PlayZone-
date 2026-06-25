using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante;

public class CriarVigilanteHandler : IRequestHandler<CriarVigilanteCommand, CriarVigilanteResposta>
{
    private readonly IVigilanteRepositorio _repositorio;

    public CriarVigilanteHandler(IVigilanteRepositorio repositorio)
    {
        _repositorio = repositorio;
    }

    public async Task<CriarVigilanteResposta> Handle(CriarVigilanteCommand command, CancellationToken ct)
    {
        var vigilante = new Vigilante
        {
            NomeCompleto = command.NomeCompleto.Trim(),
            Cpf = command.Cpf.Trim(),
            Matricula = command.Matricula,
            Arena = command.Arena.Trim(),
            Ativo = true,
            CriadoEm = DateTime.UtcNow,
            AtualizadoEm = DateTime.UtcNow
        };

        await _repositorio.AdicionarAsync(vigilante, ct);
        await _repositorio.SalvarAsync(ct);

        return new CriarVigilanteResposta(
            vigilante.Id,
            vigilante.NomeCompleto,
            vigilante.Cpf,
            vigilante.Matricula,
            vigilante.Arena
        );
    }
}