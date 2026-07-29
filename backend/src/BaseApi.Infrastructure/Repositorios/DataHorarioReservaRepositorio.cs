using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Infrastructure.Repositorios;

public class DataHorarioReservaRepositorio : IDataHorarioReservaRepositorio
{
    private readonly AppDbContext _context;

    public DataHorarioReservaRepositorio(AppDbContext context)
    {
        _context = context;
    }

    public async Task<DataHorarioReserva> AdicionarAsync(DataHorarioReserva entidade)
    {
        await _context.DataHorarioReservas.AddAsync(entidade);
        await _context.SaveChangesAsync();

        return entidade;
    }

    public async Task<List<DataHorarioReserva>> ObterPorQuadraAsync(Guid quadraId)
    {
        return await _context.DataHorarioReservas
            .Where(x => x.QuadraId == quadraId)
            .OrderBy(x => x.Data)
            .ThenBy(x => x.Horario)
            .ToListAsync();
    }

    public async Task<List<DataHorarioReserva>> ObterPorDataAsync(Guid quadraId, DateTime data)
    {
        return await _context.DataHorarioReservas
            .Where(x => x.QuadraId == quadraId && x.Data.Date == data.Date)
            .OrderBy(x => x.Horario)
            .ToListAsync();
    }

    public async Task<DataHorarioReserva?> ObterPorIdAsync(Guid id)
    {
        return await _context.DataHorarioReservas
            .FirstOrDefaultAsync(x => x.DataHorarioReservaId == id);
    }

    public async Task AtualizarAsync(DataHorarioReserva entidade)
    {
        _context.DataHorarioReservas.Update(entidade);
        await _context.SaveChangesAsync();
    }

    public async Task RemoverAsync(Guid id)
    {
        var entidade = await _context.DataHorarioReservas.FindAsync(id);

        if (entidade == null)
            return;

        _context.DataHorarioReservas.Remove(entidade);
        await _context.SaveChangesAsync();
    }

    public async Task<(IEnumerable<DataHorarioReserva> itens, int total)> ListarAsync(
    int pagina,
    int tamanhoPagina,
    CancellationToken ct)
    {
        var query = _context.DataHorarioReservas.AsNoTracking();

        var total = await query.CountAsync(ct);

        var itens = await query
            .OrderBy(x => x.Data)
            .ThenBy(x => x.Horario)
            .Skip((pagina - 1) * tamanhoPagina)
            .Take(tamanhoPagina)
            .ToListAsync(ct);

        return (itens, total);
    }
}