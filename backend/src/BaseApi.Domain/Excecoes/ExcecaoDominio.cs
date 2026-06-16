namespace BaseApi.Domain.Excecoes;

/// <summary>
/// Exceção base para erros de regras de negócio do domínio.
/// Lançada quando uma operação viola uma regra de negócio (ex: e-mail duplicado).
/// O middleware global captura essa exceção e retorna HTTP 400 Bad Request.
/// </summary>
public class ExcecaoDominio : Exception
{
    public ExcecaoDominio(string mensagem) : base(mensagem) { }
}

/// <summary>
/// Exceção para recursos não encontrados.
/// O middleware global captura e retorna HTTP 404 Not Found.
/// </summary>
public class ExcecaoNaoEncontrado : Exception
{
    public ExcecaoNaoEncontrado(string mensagem) : base(mensagem) { }
}

/// <summary>
/// Exceção para erros de autenticação e autorização.
/// O middleware global captura e retorna HTTP 401 Unauthorized.
/// </summary>
public class ExcecaoNaoAutorizado : Exception
{
    public ExcecaoNaoAutorizado(string mensagem) : base(mensagem) { }
}
