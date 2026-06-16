using MediatR;

namespace BaseApi.Application.Usuarios.Commands.CriarUsuario;

/// <summary>
/// =========================================================
/// EXEMPLO DE COMMAND — USE COMO BASE PARA OUTRAS ENTIDADES
/// =========================================================
///
/// Um Command representa uma INTENÇÃO de alterar o estado do sistema.
/// Segue o padrão CQRS: Commands mudam dados, Queries leem dados.
///
/// Para criar um Command para outra entidade (ex: Produto):
///   1. Crie a pasta: Produtos/Commands/CriarProduto/
///   2. Copie e adapte este arquivo → CriarProdutoCommand.cs
///   3. Copie e adapte o Handler  → CriarProdutoHandler.cs
///   4. Copie e adapte o Validator → CriarProdutoValidator.cs
///   5. Registre no controller
/// </summary>
public record CriarUsuarioCommand(
    string NomeCompleto,
    string Email,
    string Senha,
    int PerfilId
) : IRequest<CriarUsuarioResposta>;

/// <summary>DTO retornado após criação bem-sucedida</summary>
public record CriarUsuarioResposta(Guid Id, string NomeCompleto, string Email);
