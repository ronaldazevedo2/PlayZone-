using BaseApi.Domain.Entidades;
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante;

public class CriarVigilanteHandler(
    IVigilanteRepositorio repositorio) : IRequestHandler<CriarVigilanteCommand, CriarVigilanteResposta>
{
    public async Task<CriarVigilanteResposta> Handle(CriarVigilanteCommand command, CancellationToken ct)
    {
        if (await repositorio.CpfExisteAsync(command.Cpf, ct))
            throw new ExcecaoDominio("CPF já cadastrado para outro vigilante.");

        if (await repositorio.EmailExisteAsync(command.Email, ct))
            throw new ExcecaoDominio("E-mail já cadastrado para outro vigilante.");

        var vigilante = new Vigilante
        {
            NomeCompleto = command.NomeCompleto,
            Cpf = command.Cpf,
            Email = command.Email.ToLowerInvariant().Trim(),
            Telefone = command.Telefone,
            DataNascimento = command.DataNascimento,
            FotoPerfil = command.FotoPerfil ?? string.Empty,
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
            vigilante.Email,
            vigilante.Telefone,
            vigilante.DataNascimento,
            vigilante.FotoPerfil,
            vigilante.Ativo
        );
    }
}
