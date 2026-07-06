using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Infrastructure.Repositorios
{
    public class QuadraRepositorio(AppDbContext contexto) : IQuadraRepositorio

    {
        public Task AdicionarAsync(Quadra quadra, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public void Atualizar(Quadra quadra)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Quadra>> FiltrarPorLocalizacaoAsync(string localizacao, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Quadra>> FiltrarPorModalidadeAsync(string modalidade, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public Task<(IEnumerable<Quadra> Itens, int Total)> ListarAsync(int pagina, int tamanhoPagina, string? busca, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public Task<bool> NomeExisteAsync(string nome, Guid? ignorarId = null, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public Task<Quadra?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public Task<Quadra?> ObterPorNomeAsync(string nome, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public void Remover(Quadra quadra)
        {
            throw new NotImplementedException();
        }

        public Task SalvarAsync(CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }
    }
}
