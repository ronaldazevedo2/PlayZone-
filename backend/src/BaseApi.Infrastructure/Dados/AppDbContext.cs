using BaseApi.Domain.Entidades;
using BaseApi.Infrastructure.Repositorios;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Org.BouncyCastle.Crypto.Macs;
using static Org.BouncyCastle.Bcpg.Attr.ImageAttrib;
using System;

namespace BaseApi.Infrastructure.Dados;

/// <summary>
/// Contexto principal do Entity Framework Core.
/// Gerencia todas as entidades e a conexão com o banco MySQL.
///
/// As migrations são criadas pelo CLI do EF e aplicadas automaticamente no startup.
/// Para criar uma nova migration após alterar entidades:
///   dotnet ef migrations add NomeDaMigration --project src/BaseApi.Infrastructure --startup-project src/BaseApi.API
/// </summary>
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Perfil> Perfis => Set<Perfil>();
    public DbSet<Quadra> Quadra => Set<Quadra>();
    public DbSet<Reserva> Reserva => Set<Reserva>();
    public DbSet<DadosSecretaria> DadosSecretaria => Set<DadosSecretaria>();
    public DbSet<Vigilantes> Vigilantes => Set<Vigilantes>();

    public DbSet<Notificacao> Telefones => Set<Notificacao>();

    public DbSet<DataHorarioReserva> DataHorarioReservas => Set<DataHorarioReserva>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Aplica todas as configurações do assembly automaticamente (Fluent API)
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        // =============================================
        // SEED — dados iniciais criados automaticamente
        // =============================================
        SeedPerfis(modelBuilder);
        SeedUsuarioAdmin(modelBuilder);
        SeedUsuarios(modelBuilder);
        SeedDadosSecretaria(modelBuilder);
        SeedQuadras(modelBuilder);
        SeedReservas(modelBuilder);
        SeedVigilantes(modelBuilder);

    }
    private static void SeedPerfis(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Perfil>().HasData(
            new Perfil { Id = 1, Nome = "Admin", Descricao = "Acesso total ao sistema" },
            new Perfil { Id = 2, Nome = "Vigilante", Descricao = "Acesso de vigilante ao sistema" },
            new Perfil { Id = 3, Nome = "Usuário", Descricao = "Acesso básico ao sistema" }
        );
    }

    private static void SeedUsuarioAdmin(ModelBuilder modelBuilder)
    {
        // Usuário padrão: admin@baseapi.com / Admin@123
        // Hash gerado com BCrypt (work factor 12)
        modelBuilder.Entity<Usuario>().HasData(new Usuario
        {
            UsuariosId = Guid.Parse("00000000-0000-0000-0000-000000000001"),
            NomeCompleto = "Administrador do Sistema",
            Email = "admin@baseapi.com",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
            PerfilId = 1,
            Ativo = true,
            CriadoEm = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            AtualizadoEm = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
        });
    }

    private static void SeedUsuarios(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Usuario>().HasData(

        new Usuario
        {
            UsuariosId = Guid.Parse("11111111-1111-1111-1111-111111111111"),
            NomeCompleto = "Gabrieli Arpini",
            Email = "gabrieli.arpini@gmail.com",
            Cpf = "12569348712",
            Telefone = "27998123456",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = new DateTime(2026, 1, 1),
            AtualizadoEm = new DateTime(2026, 1, 1)
        },
        new Usuario
        {
            UsuariosId = Guid.Parse("22222222-2222-2222-2222-222222222222"),
            NomeCompleto = "Lucas Henrique Ferreira",
            Email = "lucashenriquef@gmail.com",
            Cpf = "38495127604",
            Telefone = "27998254731",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = new DateTime(2026, 1, 1),
            AtualizadoEm = new DateTime(2026, 1, 1)
        },
        new Usuario
        {
            UsuariosId = Guid.Parse("33333333-3333-3333-3333-333333333333"),
            NomeCompleto = "Mariana Oliveira Santos",
            Email = "mariana.oliveira@gmail.com",
            Cpf = "56381927401",
            Telefone = "27998361425",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = new DateTime(2026, 1, 1),
            AtualizadoEm = new DateTime(2026, 1, 1)
        },
        new Usuario
        {
            UsuariosId = Guid.Parse("44444444-4444-4444-4444-444444444444"),
            NomeCompleto = "Pedro Henrique Almeida",
            Email = "pedro.henrique.a@gmail.com",
            Cpf = "71438296510",
            Telefone = "27998472516",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = new DateTime(2026, 1, 1),
            AtualizadoEm = new DateTime(2026, 1, 1)
        },
        new Usuario
        {
            UsuariosId = Guid.Parse("55555555-5555-5555-5555-555555555555"),
            NomeCompleto = "Ana Carolina Lima",
            Email = "anacarolinalima@gmail.com",
            Cpf = "29617483592",
            Telefone = "27998581342",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = new DateTime(2026, 1, 1),
            AtualizadoEm = new DateTime(2026, 1, 1)
        },
        new Usuario
        {
            UsuariosId = Guid.Parse("66666666-6666-6666-6666-666666666666"),
            NomeCompleto = "Rafael Costa Pereira",
            Email = "rafael.costa@gmail.com",
            Cpf = "84752063198",
            Telefone = "27998693574",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = new DateTime(2026, 1, 1),
            AtualizadoEm = new DateTime(2026, 1, 1)
        },
        new Usuario
        {
            UsuariosId = Guid.Parse("77777777-7777-7777-7777-777777777777"),
            NomeCompleto = "Juliana Martins Rocha",
            Email = "julianamartins@gmail.com",
            Cpf = "53069182477",
            Telefone = "27998714653",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = new DateTime(2026, 1, 1),
            AtualizadoEm = new DateTime(2026, 1, 1)
        },
        new Usuario
        {
            UsuariosId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
            NomeCompleto = "Felipe Augusto Almeida",
            Email = "felipe.almeida@gmail.com",
            Cpf = "18240795634",
            Telefone = "27998835791",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = new DateTime(2026, 1, 1),
            AtualizadoEm = new DateTime(2026, 1, 1)
        },
        new Usuario
        {
            UsuariosId = Guid.Parse("99999999-9999-9999-9999-999999999999"),
            NomeCompleto = "Beatriz Gomes da Silva",
            Email = "beatriz.gomes@gmail.com",
            Cpf = "40528691375",
            Telefone = "27998926418",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = new DateTime(2026, 1, 1),
            AtualizadoEm = new DateTime(2026, 1, 1)
        },
        new Usuario
        {
            UsuariosId = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
            NomeCompleto = "Gustavo Ribeiro Nascimento",
            Email = "gustavo.ribeiro@gmail.com",
            Cpf = "69135824780",
            Telefone = "27999047185",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            PerfilId = 3,
            Ativo = true,
            CriadoEm = new DateTime(2026, 1, 1),
            AtualizadoEm = new DateTime(2026, 1, 1)
        }
        );
    }

    private static void SeedDadosSecretaria(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<DadosSecretaria>().HasData(
            new DadosSecretaria
            {
                SecretariaId = Guid.Parse("11111111-1111-1111-1111-111111111111"),
                Nome = "Secretaria Municipal de Esporte e Lazer",
                Email = "semel@linhares.es.gov.br",
                Contato = "(27) 98105-0171",
                Cep = "29906-725",
                Endereço = "Av. Roberto Marinho",
                Numero = "306",
                Bairro = "Palmital",
                Cidade = "Linhares"
            }
        );
    }

    private static void SeedQuadras(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Quadra>().HasData(

        new Quadra
        {
            Id = Guid.Parse("33333333-3333-3333-3333-333333333333"),
            Nome = "GINÁSIO POLIESPORTIVO \"EURICO GUILHERME SCHULZ\"",
            Descricao = "Ginásio Poliesportivo localizado no bairro São José.",
            Capacidade = 20,
            Localizacao = "São José",
            Modalidade = "Futebol",
            ImagemUrl = "https://altipisos.com.br/wp-content/uploads/2022/05/quadra-esportiva-1-1.jpeg"
        },

        new Quadra
        {
            Id = Guid.Parse("44444444-4444-4444-4444-444444444444"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO AVISO",
            Descricao = "Ginásio Poliesportivo localizado no bairro Aviso.",
            Capacidade = 20,
            Localizacao = "Aviso",
            Modalidade = "Futebol",
            ImagemUrl = "https://www.juvenil.com.br/portal/imgs/textos/quadra-poliesportiva-apos-reforma1678137566.jpeg"
        },

        new Quadra
        {
            Id = Guid.Parse("55555555-5555-5555-5555-555555555555"),
            Nome = "GINÁSIO POLIESPORTIVO \"LEANDRO SILVA DOS REIS\"",
            Descricao = "Ginásio Poliesportivo localizado no bairro Interlagos.",
            Capacidade = 20,
            Localizacao = "Interlagos",
            Modalidade = "Futebol",
            ImagemUrl = "https://mid-noticias.curitiba.pr.gov.br/2022/00341942.jpg"
        },

        new Quadra
        {
            Id = Guid.Parse("66666666-6666-6666-6666-666666666666"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO ARAÇÁ",
            Descricao = "Ginásio Poliesportivo localizado no bairro Araçá.",
            Capacidade = 20,
            Localizacao = "Araçá",
            Modalidade = "Futebol",
            ImagemUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSIF0n5FrisqvRa5ulciyD48kfQ1wUOBlXz-r5BO8zH7Iovgh1RIEPJOunz&s=10"
        },
        new Quadra
        {
            Id = Guid.Parse("77777777-7777-7777-7777-777777777777"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO CONCEIÇÃO",
            Descricao = "Ginásio Poliesportivo localizado no bairro Conceição.",
            Capacidade = 20,
            Localizacao = "Conceição",
            Modalidade = "Futebol",
            ImagemUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3_cuXIPJxJTR-aLEquO3IGEhZbaTbaLB_mOY_tKEW0xJKTo_SNVckXLna&s=10"
        },

        new Quadra
        {
            Id = Guid.Parse("88888888-8888-8888-8888-888888888888"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO SHELL",
            Descricao = "Ginásio Poliesportivo localizado no bairro Shell.",
            Capacidade = 20,
            Localizacao = "Shell",
            Modalidade = "Futsal",
            ImagemUrl = "https://psd.org.br/wp-content/uploads/2023/11/Quadra-do-Jardim-Figueiras.-Divulgacao-Prefeitura-de-Valinhos.jpg"
        },

        new Quadra
        {
            Id = Guid.Parse("99999999-9999-9999-9999-999999999999"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO CANIVETE",
            Descricao = "Ginásio Poliesportivo localizado no bairro Canivete.",
            Capacidade = 20,
            Localizacao = "Canivete",
            Modalidade = "Basquete",
            ImagemUrl = "https://www.sescpr.com.br/wp-content/uploads/2020/11/20201001_173756.jpg"
        },

        new Quadra
        {
            Id = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO NOVO HORIZONTE",
            Descricao = "Ginásio Poliesportivo localizado no bairro Novo Horizonte.",
            Capacidade = 20,
            Localizacao = "Novo Horizonte",
            Modalidade = "Vôlei",
            ImagemUrl = "https://img.magnific.com/fotos-gratis/quadra-de-tenis-interna_1385-1396.jpg"
        },

        new Quadra
        {
            Id = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO JARDIM LAGUNA",
            Descricao = "Ginásio Poliesportivo localizado no bairro Jardim Laguna.",
            Capacidade = 20,
            Localizacao = "Jardim Laguna",
            Modalidade = "Beach Tennis",
            ImagemUrl = "https://tenisclubepaulista.com/wp-content/uploads/2023/03/quadra-beach-tennis.jpeg"
        },

        new Quadra
        {
            Id = Guid.Parse("cccccccc-cccc-cccc-cccc-cccccccccccc"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO MOVELAR",
            Descricao = "Ginásio Poliesportivo localizado no bairro Movelar.",
            Capacidade = 20,
            Localizacao = "Movelar",
            Modalidade = "Handebol",
            ImagemUrl = "https://nprpinturasereformas.com.br/wp-content/uploads/2022/09/Pinturas-e-Reformas-de-Quadras-Poliesportivas-12-3.jpeg"
        },

        new Quadra
        {
            Id = Guid.Parse("dddddddd-dddd-dddd-dddd-dddddddddddd"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO TRÊS BARRAS",
            Descricao = "Ginásio Poliesportivo localizado no bairro Três Barras.",
            Capacidade = 20,
            Localizacao = "Três Barras",
            Modalidade = "Futebol",
            ImagemUrl = "https://urupes.sp.gov.br/noticias/upload/postagens/1715802666_32167.jpg"
        },

        new Quadra
        {
            Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO SANTA CRUZ",
            Descricao = "Ginásio Poliesportivo localizado no bairro Santa Cruz.",
            Capacidade = 20,
            Localizacao = "Santa Cruz",
            Modalidade = "Basquete",
            ImagemUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQN_q4bBB3iBwSsrFh5nsqEuJhIuXRJmn8jjpDmy57QCy1wx_nqOeKQ0GE&s=10"
        },

        new Quadra
        {
            Id = Guid.Parse("ffffffff-ffff-ffff-ffff-ffffffffffff"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO PLANALTO",
            Descricao = "Ginásio Poliesportivo localizado no bairro Planalto.",
            Capacidade = 20,
            Localizacao = "Planalto",
            Modalidade = "Vôlei",
            ImagemUrl = "https://harmoniaclubedecampo.com.br/img/esportes/g/harmoniaclubedecampo_esportes_15102025_155937_0001.jpg"
        },

        new Quadra
        {
            Id = Guid.Parse("12121212-1212-1212-1212-121212121212"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO LAGOA DO MEIO",
            Descricao = "Ginásio Poliesportivo localizado no bairro Lagoa do Meio.",
            Capacidade = 20,
            Localizacao = "Lagoa do Meio",
            Modalidade = "Futsal",
            ImagemUrl = "https://media-cdn.tripadvisor.com/media/photo-s/14/bc/5b/b9/futsal-and-basketball.jpg"
        }

    );
    }

    private static void SeedReservas(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Reserva>().HasData(
            // Quadra Society
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000001"),
                QuadraId = Guid.Parse("33333333-3333-3333-3333-333333333333"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(8, 0, 0)
            },
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000002"),
                QuadraId = Guid.Parse("33333333-3333-3333-3333-333333333333"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(9, 0, 0)
            },

            // Quadra Futsal
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000003"),
                QuadraId = Guid.Parse("44444444-4444-4444-4444-444444444444"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(10, 0, 0)
            },
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000004"),
                QuadraId = Guid.Parse("44444444-4444-4444-4444-444444444444"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(11, 0, 0)
            },

            // Quadra Vôlei
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000005"),
                QuadraId = Guid.Parse("55555555-5555-5555-5555-555555555555"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(14, 0, 0)
            },

            // Quadra Basquete
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000006"),
                QuadraId = Guid.Parse("66666666-6666-6666-6666-666666666666"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(16, 0, 0)
            }
        );
    }

    private static void SeedVigilantes(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Vigilantes>().HasData(
            new Vigilantes
            {
                Id = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
                NomeCompleto = "Carlos Eduardo Silva",
                Cpf = "12345678901",
                Email = "carlos.silva@gmail.com",
                Telefone = "(11) 99523-1569",
                DataNascimento = new DateTime(1988, 5, 15),
                FotoPerfil = "https://img.magnific.com/fotos-gratis/policial-masculino-atraente-com-municao-segurando-arma-com-ambas-as-maos-vista-frontal-do-homem-barbudo-de-preto_7502-10633.jpg?semt=ais_hybrid&w=740&q=80",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG001",
                Arena = "GINÁSIO POLIESPORTIVO BAIRRO AVISO"
            },
            new Vigilantes
            {
                Id = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
                NomeCompleto = "Marcos Antônio Souza",
                Cpf = "98765432100",
                Email = "marcos.souza@gmail.com",
                Telefone = "(11) 99821-2426",
                DataNascimento = new DateTime(1992, 8, 20),
                FotoPerfil = "https://img.magnific.com/fotos-premium/jovem-guarda-de-seguranca-em-uniforme-isolado-em-branco_495423-104433.jpg?semt=ais_hybrid&w=740&q=80",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG002",
                Arena = "GINÁSIO POLIESPORTIVO BAIRRO ARAÇÁ"
            },
            new Vigilantes
            {
                Id = Guid.Parse("cccccccc-cccc-cccc-cccc-cccccccccccc"),
                NomeCompleto = "Fernanda Oliveira",
                Cpf = "45678912345",
                Email = "fernanda.oliveira@gmail.com",
                Telefone = "(11) 99201-3365",
                DataNascimento = new DateTime(1995, 2, 10),
                FotoPerfil = "https://img.magnific.com/fotos-premium/uma-policial-confiante-em-uniforme-posa-orgulhosamente-com-seu-distintivo-e-chapeu-a-luz-do-dia_489081-6667.jpg?semt=ais_hybrid&w=740&q=80",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG003",
                Arena = "GINÁSIO POLIESPORTIVO LEANDRO SILVA DOS REIS"
            },
            new Vigilantes
            {
                Id = Guid.Parse("dddddddd-dddd-dddd-dddd-dddddddddddd"),
                NomeCompleto = "Ricardo Mendes Pereira",
                Cpf = "32165498710",
                Email = "ricardo.mendes@gmail.com",
                Telefone = "(27) 99845-7132",
                DataNascimento = new DateTime(1987, 11, 8),
                FotoPerfil = "https://randomuser.me/api/portraits/men/32.jpg",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG004",
                Arena = "GINÁSIO POLIESPORTIVO INTERLAGOS"
            },
            new Vigilantes
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"),
                NomeCompleto = "Juliana Cristina Rocha",
                Cpf = "65412378945",
                Email = "juliana.rocha@gmail.com",
                Telefone = "(27) 99783-4621",
                DataNascimento = new DateTime(1994, 6, 18),
                FotoPerfil = "https://gestaodesegurancaprivada.com.br/wp-content/uploads/Vigilante-feminina.jpg",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG005",
                Arena = "GINÁSIO POLIESPORTIVO CONCEIÇÃO"
            },
            new Vigilantes
            {
                Id = Guid.Parse("ffffffff-ffff-ffff-ffff-ffffffffffff"),
                NomeCompleto = "André Luiz Barbosa",
                Cpf = "78945612308",
                Email = "andre.barbosa@gmail.com",
                Telefone = "(27) 99914-5873",
                DataNascimento = new DateTime(1990, 9, 27),
                FotoPerfil = "https://st3.depositphotos.com/1177973/13163/i/450/depositphotos_131632566-stock-photo-security-man-standing-indoors.jpg",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG006",
                Arena = "GINÁSIO POLIESPORTIVO NOVO HORIZONTE"
            },
            new Vigilantes
            {
                Id = Guid.Parse("12121212-1212-1212-1212-121212121212"),
                NomeCompleto = "Patrícia Almeida Costa",
                Cpf = "95175348620",
                Email = "patricia.almeida@gmail.com",
                Telefone = "(27) 99872-6405",
                DataNascimento = new DateTime(1993, 1, 12),
                FotoPerfil = "https://partnersecurity.com.br/wp-content/uploads/2022/03/mulheres-na-seguranca-patrimonial.jpg",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG007",
                Arena = "GINÁSIO POLIESPORTIVO JARDIM CAMBURI"
            },
            new Vigilantes
            {
                Id = Guid.Parse("13131313-1313-1313-1313-131313131313"),
                NomeCompleto = "Thiago Henrique Oliveira",
                Cpf = "85274196314",
                Email = "thiago.oliveira@gmail.com",
                Telefone = "(27) 99751-8936",
                DataNascimento = new DateTime(1989, 4, 30),
                FotoPerfil = "https://img.magnific.com/fotos-gratis/guarda-de-seguranca-no-espaco-de-trabalho_23-2150321639.jpg",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG008",
                Arena = "GINÁSIO POLIESPORTIVO SÃO JOSÉ"
            }
        );
    }
}
