using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


using MediatR;

namespace BaseApi.Application.vigilantes.Commands.CriarVigilantes;

/// <summary>
/// Command para criar um novo telefone no catálogo.
/// "record" é imutável — ideal para Commands (não muda depois de criado).
/// </summary>
public record CriarVigilanteCommand(
    string Marca,
    string Modelo,
    decimal Preco,
    int Estoque
) : IRequest<CriarTelefoneResposta>;

/// <summary>Dados retornados após criação bem-sucedida</summary>
public record CriarTelefoneResposta(Guid Id, string Marca, string Modelo, decimal Preco);