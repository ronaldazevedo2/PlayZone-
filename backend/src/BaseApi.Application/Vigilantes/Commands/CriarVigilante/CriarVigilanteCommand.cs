using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace BaseApi.Application.Vigilantes.Commands.CriarVigilante;

public record CriarVigilanteCommand(
    string NomeCompleto,
    string Cpf,
    string Email,
    string Telefone,
    DateTime DataNascimento,
    string? FotoPerfil
) : IRequest<CriarVigilanteResposta>;
