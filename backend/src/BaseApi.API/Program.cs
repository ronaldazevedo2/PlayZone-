using System.Text;
using BaseApi.API.Middlewares;
using BaseApi.Application;
using BaseApi.Infrastructure;
using BaseApi.Infrastructure.Dados;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// ================================================================
// 1. CORS — libera qualquer origem (ajuste em produção!)
// ================================================================
builder.Services.AddCors(opt =>
    opt.AddPolicy("PermitirTudo", policy =>
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader()));

// ================================================================
// 2. AUTENTICAÇÃO JWT
// ================================================================
var chaveJwt = builder.Configuration["Jwt:ChaveSecreta"]!;
builder.Services.AddAuthentication(opt =>
{
    opt.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    opt.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(opt =>
{
    opt.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Emissor"],
        ValidAudience = builder.Configuration["Jwt:Audiencia"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(chaveJwt)),
        ClockSkew = TimeSpan.Zero // Sem margem de tolerância na expiração
    };
});

builder.Services.AddAuthorization();

// ================================================================
// 3. CAMADAS DA APLICAÇÃO (Clean Architecture)
// ================================================================
builder.Services.AdicionarApplication();
builder.Services.AdicionarInfrastructure(builder.Configuration);

// ================================================================
// 4. CONTROLLERS + SWAGGER
// ================================================================
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(opt =>
{
    opt.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "BaseApi",
        Version = "v1",
        Description = "API base com Clean Architecture, .NET 8, MySQL e JWT."
    });

    // Adiciona suporte ao JWT no Swagger UI (botão "Authorize")
    opt.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Cole o token JWT obtido no endpoint /api/autenticacao/login.\nExemplo: Bearer eyJhbGci..."
    });

    opt.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });

    // Inclui os comentários XML dos controllers no Swagger
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
        opt.IncludeXmlComments(xmlPath);
});

var app = builder.Build();

// ================================================================
// 5. MIGRATION AUTOMÁTICA — aplica ao iniciar a aplicação
// ================================================================
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    try
    {
        logger.LogInformation("Aplicando migrations...");
        await db.Database.MigrateAsync();
        logger.LogInformation("Banco de dados pronto.");
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Erro ao aplicar migrations. Verifique a conexão com o MySQL.");
        throw;
    }
}

// ================================================================
// 6. PIPELINE DE MIDDLEWARES (ordem importa!)
// ================================================================
app.UseMiddleware<ExcecaoMiddleware>(); // Sempre primeiro

app.UseSwagger();
app.UseSwaggerUI(opt =>
{
    opt.SwaggerEndpoint("/swagger/v1/swagger.json", "BaseApi v1");
    opt.RoutePrefix = "swagger";
});

app.UseCors("PermitirTudo");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
