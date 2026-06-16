using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Servicos;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace BaseApi.Infrastructure.Servicos;

/// <summary>
/// Serviço responsável por gerar tokens JWT.
///
/// O token contém as seguintes claims:
///   - sub (NameIdentifier): Id do usuário
///   - email: E-mail do usuário
///   - name: Nome completo
///   - role: Nome do perfil (usado pelo [Authorize(Roles = "Admin")])
///   - jti: Identificador único do token
///   - exp: Data de expiração
/// </summary>
public class TokenServico(IConfiguration config) : ITokenServico
{
    private readonly string _chaveSecreta = config["Jwt:ChaveSecreta"]!;
    private readonly string _emissor = config["Jwt:Emissor"]!;
    private readonly string _audiencia = config["Jwt:Audiencia"]!;
    private readonly int _expiracaoHoras = int.Parse(config["Jwt:ExpiracaoHoras"] ?? "8");

    public string GerarToken(Usuario usuario)
    {
        var chave = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_chaveSecreta));
        var credenciais = new SigningCredentials(chave, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, usuario.Id.ToString()),
            new Claim(ClaimTypes.Email, usuario.Email),
            new Claim(ClaimTypes.Name, usuario.NomeCompleto),
            new Claim(ClaimTypes.Role, usuario.Perfil?.Nome ?? string.Empty),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: _emissor,
            audience: _audiencia,
            claims: claims,
            expires: ObterDataExpiracao(),
            signingCredentials: credenciais
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public DateTime ObterDataExpiracao()
        => DateTime.UtcNow.AddHours(_expiracaoHoras);
}
