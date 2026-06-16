using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Infrastructure.Repositorios;

/// <summary>
/// Implementação do repositório de usuários usando Entity Framework Core.
/// Toda lógica de acesso a dados fica aqui — os Handlers nunca acessam o DbContext diretamente.
/// </summary>
public class UsuarioRepositorio(AppDbContext contexto) : IUsuarioRepositorio
{
    public async Task<Usuario?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => await contexto.Usuarios
            .Include(u => u.Perfil)
            .FirstOrDefaultAsync(u => u.Id == id, ct);

    public async Task<Usuario?> ObterPorEmailAsync(string email, CancellationToken ct = default)
        => await contexto.Usuarios
            .Include(u => u.Perfil)
            .FirstOrDefaultAsync(u => u.Email == email, ct);

    public async Task<Usuario?> ObterPorTokenRedefinicaoAsync(string token, CancellationToken ct = default)
        => await contexto.Usuarios
            .FirstOrDefaultAsync(u => u.TokenRedefinicaoSenha == token, ct);

    public async Task<(IEnumerable<Usuario> Itens, int Total)> ListarAsync(
        int pagina, int tamanhoPagina, string? busca, CancellationToken ct = default)
    {
        var query = contexto.Usuarios
            .Include(u => u.Perfil)
            .AsNoTracking(); // Não rastreia para leitura (performance)

        if (!string.IsNullOrWhiteSpace(busca))
        {
            busca = busca.ToLower();
            query = query.Where(u =>
                u.NomeCompleto.ToLower().Contains(busca) ||
                u.Email.ToLower().Contains(busca));
        }

        var total = await query.CountAsync(ct);
        var itens = await query
            .OrderBy(u => u.NomeCompleto)
            .Skip((pagina - 1) * tamanhoPagina)
            .Take(tamanhoPagina)
            .ToListAsync(ct);

        return (itens, total);
    }

    public async Task<bool> EmailExisteAsync(string email, Guid? ignorarId = null, CancellationToken ct = default)
        => await contexto.Usuarios.AnyAsync(u =>
            u.Email == email && (ignorarId == null || u.Id != ignorarId), ct);

    public async Task AdicionarAsync(Usuario usuario, CancellationToken ct = default)
        => await contexto.Usuarios.AddAsync(usuario, ct);

    public void Atualizar(Usuario usuario)
        => contexto.Usuarios.Update(usuario);

    public void Remover(Usuario usuario)
        => contexto.Usuarios.Remove(usuario);

    public async Task SalvarAsync(CancellationToken ct = default)
        => await contexto.SaveChangesAsync(ct);
}
