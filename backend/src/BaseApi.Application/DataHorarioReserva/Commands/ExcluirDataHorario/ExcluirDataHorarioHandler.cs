using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Application.DataHorarioReserva.Commands.ExcluirDataHorarioReserva;

public class ExcluirDataHorarioReservaHandler(IDataHorarioReservaRepositorio repositorio)
    : IRequestHandler<ExcluirDataHorarioReservaCommand, Unit>
{
    public async Task<Unit> Handle(ExcluirDataHorarioReservaCommand command, CancellationToken ct)
    {
        var dataHorarioReserva = await repositorio.ObterPorIdAsync(command.DataHorarioReservaId)
            ?? throw new ExcecaoNaoEncontrado(
                $"Data/Horário com Id '{command.DataHorarioReservaId}' não encontrado.");

        try
        {
            await repositorio.RemoverAsync(command.DataHorarioReservaId);

            return Unit.Value;
        }
        catch (DbUpdateException)
        {
            throw new ExcecaoDominio(
                "Não foi possível excluir o horário cadastrado.");
        }
    }
}