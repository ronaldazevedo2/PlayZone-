using BaseApi.Application.Vigilantes.Commands.CriarVigilante;
using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

public class CriarVigilanteHandler : IRequestHandler<CriarVigilanteCommand, CriarVigilanteResposta>
{
    private readonly IVigilanteRepositorio _repositorio;

    public CriarVigilanteHandler(IVigilanteRepositorio repositorio)
    {
        _repositorio = repositorio;
    }

    public async Task<CriarVigilanteResposta> Handle(CriarVigilanteCommand command, CancellationToken ct)
    {
        var vigilante = new Vigilantes
        {
            Matricula = command.Matricula,
            Arena = command.Arena,
            NomeCompleto = command.NomeCompleto.Trim(),
            Cpf = command.Cpf.Trim(),
            Email = command.Email.Trim(),
            Telefone = command.Telefone.Trim(),
            DataNascimento = command.DataNascimento,
            FotoPerfil = command.FotoPerfil ?? string.Empty,
            CriadoEm = DateTime.UtcNow,
            AtualizadoEm = DateTime.UtcNow,
        };

        await _repositorio.AdicionarAsync(vigilante, ct);
        await _repositorio.SalvarAsync(ct);

        return new CriarVigilanteResposta(
     vigilante.Id,
     vigilante.NomeCompleto,
     vigilante.Cpf,
     vigilante.Email,
     vigilante.Telefone,
     vigilante.DataNascimento,
     vigilante.FotoPerfil,
     vigilante.Ativo,
     vigilante.CriadoEm,
     vigilante.AtualizadoEm,
     vigilante.Matricula,
     vigilante.Arena
 );
    }
}
