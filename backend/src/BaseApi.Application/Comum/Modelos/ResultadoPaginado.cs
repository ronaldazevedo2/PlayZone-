namespace BaseApi.Application.Comum.Modelos;

/// <summary>
/// Modelo genérico para respostas paginadas.
/// Use em Queries que retornam listas (ex: ListarUsuariosQuery).
/// </summary>
public class ResultadoPaginado<T>
{
    /// <summary>Itens da página atual</summary>
    public IEnumerable<T> Itens { get; set; } = Enumerable.Empty<T>();

    /// <summary>Total de registros no banco (não apenas da página)</summary>
    public int Total { get; set; }

    /// <summary>Página atual (começa em 1)</summary>
    public int Pagina { get; set; }

    /// <summary>Quantidade de itens por página</summary>
    public int TamanhoPagina { get; set; }

    /// <summary>Total de páginas calculado automaticamente</summary>
    public int TotalPaginas => (int)Math.Ceiling((double)Total / TamanhoPagina);

    public bool TemProximaPagina => Pagina < TotalPaginas;
    public bool TemPaginaAnterior => Pagina > 1;
}
