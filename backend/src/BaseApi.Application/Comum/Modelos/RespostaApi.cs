namespace BaseApi.Application.Comum.Modelos;

/// <summary>
/// Wrapper padrão para todas as respostas da API.
/// Garante que o cliente sempre receba um formato consistente de resposta.
///
/// Exemplo de uso no controller:
///   return Ok(RespostaApi&lt;UsuarioDto&gt;.Sucesso(dto, "Usuário criado com sucesso!"));
/// </summary>
public class RespostaApi<T>
{
    public bool Ok { get; set; }
    public string Mensagem { get; set; } = string.Empty;
    public T? Dados { get; set; }
    public IEnumerable<string>? Erros { get; set; }

    public static RespostaApi<T> Sucesso(T dados, string mensagem = "Operação realizada com sucesso.")
        => new() { Ok = true, Mensagem = mensagem, Dados = dados };

    public static RespostaApi<T> Falha(string mensagem, IEnumerable<string>? erros = null)
        => new() { Ok = false, Mensagem = mensagem, Erros = erros };
}

// Versão sem dados de retorno (para deletes, por exemplo)
public class RespostaApi : RespostaApi<object>
{
    public static RespostaApi Sucesso(string mensagem = "Operação realizada com sucesso.")
        => new() { Ok = true, Mensagem = mensagem };

    public static new RespostaApi Falha(string mensagem, IEnumerable<string>? erros = null)
        => new() { Ok = false, Mensagem = mensagem, Erros = erros };
}
