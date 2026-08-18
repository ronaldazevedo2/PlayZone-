using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace BaseApi.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class Inicial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "dados_secretaria",
                columns: table => new
                {
                    SecretariaId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    Nome = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Email = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Contato = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Cep = table.Column<string>(type: "varchar(10)", maxLength: 10, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Endereço = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Numero = table.Column<string>(type: "varchar(10)", maxLength: 10, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Bairro = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Cidade = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_dados_secretaria", x => x.SecretariaId);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "notificacoes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    Titulo = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Mensagem = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    DataEnvio = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    Lida = table.Column<bool>(type: "tinyint(1)", nullable: false, defaultValue: false),
                    UsuarioId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_notificacoes", x => x.Id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "perfis",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    Nome = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Descricao = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_perfis", x => x.Id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "quadras",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    Nome = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Descricao = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Capacidade = table.Column<int>(type: "int", nullable: false),
                    Localizacao = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Modalidade = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    ImagemUrl = table.Column<string>(type: "longtext", maxLength: 1000000, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Status = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_quadras", x => x.Id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "vigilantes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    NomeCompleto = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Cpf = table.Column<string>(type: "varchar(14)", maxLength: 14, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Email = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Telefone = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    DataNascimento = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    FotoPerfil = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Ativo = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    CriadoEm = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    AtualizadoEm = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    Matricula = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Arena = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_vigilantes", x => x.Id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "usuarios",
                columns: table => new
                {
                    UsuariosId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    NomeCompleto = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Email = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Cpf = table.Column<string>(type: "varchar(11)", maxLength: 11, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Telefone = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    SenhaHash = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    PerfilId = table.Column<int>(type: "int", nullable: false),
                    Ativo = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    TokenRedefinicaoSenha = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    TokenExpiracao = table.Column<DateTime>(type: "datetime(6)", nullable: true),
                    CriadoEm = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    AtualizadoEm = table.Column<DateTime>(type: "datetime(6)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_usuarios", x => x.UsuariosId);
                    table.ForeignKey(
                        name: "FK_usuarios_perfis_PerfilId",
                        column: x => x.PerfilId,
                        principalTable: "perfis",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "data_horario_reservas",
                columns: table => new
                {
                    DataHorarioReservaId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    QuadraId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    Data = table.Column<DateTime>(type: "date", nullable: false),
                    Horario = table.Column<TimeSpan>(type: "time", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_data_horario_reservas", x => x.DataHorarioReservaId);
                    table.ForeignKey(
                        name: "FK_data_horario_reservas_quadras_QuadraId",
                        column: x => x.QuadraId,
                        principalTable: "quadras",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "reservas",
                columns: table => new
                {
                    ReservasId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    QuadraId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    UsuarioId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    DataAgendada = table.Column<DateTime>(type: "date", nullable: false),
                    HorarioAgendado = table.Column<TimeSpan>(type: "time", nullable: false),
                    Status = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reservas", x => x.ReservasId);
                    table.ForeignKey(
                        name: "FK_reservas_quadras_QuadraId",
                        column: x => x.QuadraId,
                        principalTable: "quadras",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reservas_usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "usuarios",
                        principalColumn: "UsuariosId",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.InsertData(
                table: "dados_secretaria",
                columns: new[] { "SecretariaId", "Bairro", "Cep", "Cidade", "Contato", "Email", "Endereço", "Nome", "Numero" },
                values: new object[] { new Guid("11111111-1111-1111-1111-111111111111"), "Palmital", "29906-725", "Linhares", "(27) 98105-0171", "semel@linhares.es.gov.br", "Av. Roberto Marinho", "Secretaria Municipal de Esporte e Lazer", "306" });

            migrationBuilder.InsertData(
                table: "perfis",
                columns: new[] { "Id", "Descricao", "Nome" },
                values: new object[,]
                {
                    { 1, "Acesso total ao sistema", "Admin" },
                    { 2, "Acesso de vigilante ao sistema", "Vigilante" },
                    { 3, "Acesso básico ao sistema", "Usuário" }
                });

            migrationBuilder.InsertData(
                table: "quadras",
                columns: new[] { "Id", "Capacidade", "Descricao", "ImagemUrl", "Localizacao", "Modalidade", "Nome", "Status" },
                values: new object[,]
                {
                    { new Guid("12121212-1212-1212-1212-121212121212"), 20, "Ginásio Poliesportivo localizado no bairro Lagoa do Meio.", "https://media-cdn.tripadvisor.com/media/photo-s/14/bc/5b/b9/futsal-and-basketball.jpg", "Lagoa do Meio", "Futsal", "GINÁSIO POLIESPORTIVO BAIRRO LAGOA DO MEIO", "Ativa" },
                    { new Guid("33333333-3333-3333-3333-333333333333"), 20, "Ginásio Poliesportivo localizado no bairro São José.", "https://altipisos.com.br/wp-content/uploads/2022/05/quadra-esportiva-1-1.jpeg", "São José", "Futebol", "GINÁSIO POLIESPORTIVO \"EURICO GUILHERME SCHULZ\"", "Ativa" },
                    { new Guid("44444444-4444-4444-4444-444444444444"), 20, "Ginásio Poliesportivo localizado no bairro Aviso.", "https://www.juvenil.com.br/portal/imgs/textos/quadra-poliesportiva-apos-reforma1678137566.jpeg", "Aviso", "Futebol", "GINÁSIO POLIESPORTIVO BAIRRO AVISO", "Ativa" },
                    { new Guid("55555555-5555-5555-5555-555555555555"), 20, "Ginásio Poliesportivo localizado no bairro Interlagos.", "https://mid-noticias.curitiba.pr.gov.br/2022/00341942.jpg", "Interlagos", "Futebol", "GINÁSIO POLIESPORTIVO \"LEANDRO SILVA DOS REIS\"", "Ativa" },
                    { new Guid("66666666-6666-6666-6666-666666666666"), 20, "Ginásio Poliesportivo localizado no bairro Araçá.", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSIF0n5FrisqvRa5ulciyD48kfQ1wUOBlXz-r5BO8zH7Iovgh1RIEPJOunz&s=10", "Araçá", "Futebol", "GINÁSIO POLIESPORTIVO BAIRRO ARAÇÁ", "Ativa" },
                    { new Guid("77777777-7777-7777-7777-777777777777"), 20, "Ginásio Poliesportivo localizado no bairro Conceição.", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3_cuXIPJxJTR-aLEquO3IGEhZbaTbaLB_mOY_tKEW0xJKTo_SNVckXLna&s=10", "Conceição", "Futebol", "GINÁSIO POLIESPORTIVO BAIRRO CONCEIÇÃO", "Ativa" },
                    { new Guid("88888888-8888-8888-8888-888888888888"), 20, "Ginásio Poliesportivo localizado no bairro Shell.", "https://psd.org.br/wp-content/uploads/2023/11/Quadra-do-Jardim-Figueiras.-Divulgacao-Prefeitura-de-Valinhos.jpg", "Shell", "Futsal", "GINÁSIO POLIESPORTIVO BAIRRO SHELL", "Ativa" },
                    { new Guid("99999999-9999-9999-9999-999999999999"), 20, "Ginásio Poliesportivo localizado no bairro Canivete.", "https://www.sescpr.com.br/wp-content/uploads/2020/11/20201001_173756.jpg", "Canivete", "Basquete", "GINÁSIO POLIESPORTIVO BAIRRO CANIVETE", "Ativa" },
                    { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), 20, "Ginásio Poliesportivo localizado no bairro Novo Horizonte.", "https://img.magnific.com/fotos-gratis/quadra-de-tenis-interna_1385-1396.jpg", "Novo Horizonte", "Vôlei", "GINÁSIO POLIESPORTIVO BAIRRO NOVO HORIZONTE", "Ativa" },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), 20, "Ginásio Poliesportivo localizado no bairro Jardim Laguna.", "https://tenisclubepaulista.com/wp-content/uploads/2023/03/quadra-beach-tennis.jpeg", "Jardim Laguna", "Beach Tennis", "GINÁSIO POLIESPORTIVO BAIRRO JARDIM LAGUNA", "Ativa" },
                    { new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), 20, "Ginásio Poliesportivo localizado no bairro Movelar.", "https://nprpinturasereformas.com.br/wp-content/uploads/2022/09/Pinturas-e-Reformas-de-Quadras-Poliesportivas-12-3.jpeg", "Movelar", "Handebol", "GINÁSIO POLIESPORTIVO BAIRRO MOVELAR", "Ativa" },
                    { new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"), 20, "Ginásio Poliesportivo localizado no bairro Três Barras.", "https://urupes.sp.gov.br/noticias/upload/postagens/1715802666_32167.jpg", "Três Barras", "Futebol", "GINÁSIO POLIESPORTIVO BAIRRO TRÊS BARRAS", "Ativa" },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), 20, "Ginásio Poliesportivo localizado no bairro Santa Cruz.", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQN_q4bBB3iBwSsrFh5nsqEuJhIuXRJmn8jjpDmy57QCy1wx_nqOeKQ0GE&s=10", "Santa Cruz", "Basquete", "GINÁSIO POLIESPORTIVO BAIRRO SANTA CRUZ", "Ativa" },
                    { new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"), 20, "Ginásio Poliesportivo localizado no bairro Planalto.", "https://harmoniaclubedecampo.com.br/img/esportes/g/harmoniaclubedecampo_esportes_15102025_155937_0001.jpg", "Planalto", "Vôlei", "GINÁSIO POLIESPORTIVO BAIRRO PLANALTO", "Ativa" }
                });

            migrationBuilder.InsertData(
                table: "vigilantes",
                columns: new[] { "Id", "Arena", "Ativo", "AtualizadoEm", "Cpf", "CriadoEm", "DataNascimento", "Email", "FotoPerfil", "Matricula", "NomeCompleto", "Telefone" },
                values: new object[,]
                {
                    { new Guid("12121212-1212-1212-1212-121212121212"), "GINÁSIO POLIESPORTIVO JARDIM CAMBURI", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "95175348620", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1993, 1, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), "patricia.almeida@gmail.com", "https://partnersecurity.com.br/wp-content/uploads/2022/03/mulheres-na-seguranca-patrimonial.jpg", "VIG007", "Patrícia Almeida Costa", "(27) 99872-6405" },
                    { new Guid("13131313-1313-1313-1313-131313131313"), "GINÁSIO POLIESPORTIVO SÃO JOSÉ", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "85274196314", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1989, 4, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), "thiago.oliveira@gmail.com", "https://img.magnific.com/fotos-gratis/guarda-de-seguranca-no-espaco-de-trabalho_23-2150321639.jpg", "VIG008", "Thiago Henrique Oliveira", "(27) 99751-8936" },
                    { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), "GINÁSIO POLIESPORTIVO BAIRRO AVISO", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "12345678901", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1988, 5, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "carlos.silva@gmail.com", "https://img.magnific.com/fotos-gratis/policial-masculino-atraente-com-municao-segurando-arma-com-ambas-as-maos-vista-frontal-do-homem-barbudo-de-preto_7502-10633.jpg?semt=ais_hybrid&w=740&q=80", "VIG001", "Carlos Eduardo Silva", "(11) 99523-1569" },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), "GINÁSIO POLIESPORTIVO BAIRRO ARAÇÁ", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "98765432100", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1992, 8, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "marcos.souza@gmail.com", "https://img.magnific.com/fotos-premium/jovem-guarda-de-seguranca-em-uniforme-isolado-em-branco_495423-104433.jpg?semt=ais_hybrid&w=740&q=80", "VIG002", "Marcos Antônio Souza", "(11) 99821-2426" },
                    { new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), "GINÁSIO POLIESPORTIVO LEANDRO SILVA DOS REIS", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "45678912345", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1995, 2, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "fernanda.oliveira@gmail.com", "https://img.magnific.com/fotos-premium/uma-policial-confiante-em-uniforme-posa-orgulhosamente-com-seu-distintivo-e-chapeu-a-luz-do-dia_489081-6667.jpg?semt=ais_hybrid&w=740&q=80", "VIG003", "Fernanda Oliveira", "(11) 99201-3365" },
                    { new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"), "GINÁSIO POLIESPORTIVO INTERLAGOS", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "32165498710", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1987, 11, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), "ricardo.mendes@gmail.com", "https://randomuser.me/api/portraits/men/32.jpg", "VIG004", "Ricardo Mendes Pereira", "(27) 99845-7132" },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), "GINÁSIO POLIESPORTIVO CONCEIÇÃO", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "65412378945", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1994, 6, 18, 0, 0, 0, 0, DateTimeKind.Unspecified), "juliana.rocha@gmail.com", "https://gestaodesegurancaprivada.com.br/wp-content/uploads/Vigilante-feminina.jpg", "VIG005", "Juliana Cristina Rocha", "(27) 99783-4621" },
                    { new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"), "GINÁSIO POLIESPORTIVO NOVO HORIZONTE", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "78945612308", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1990, 9, 27, 0, 0, 0, 0, DateTimeKind.Unspecified), "andre.barbosa@gmail.com", "https://st3.depositphotos.com/1177973/13163/i/450/depositphotos_131632566-stock-photo-security-man-standing-indoors.jpg", "VIG006", "André Luiz Barbosa", "(27) 99914-5873" }
                });

            migrationBuilder.InsertData(
                table: "usuarios",
                columns: new[] { "UsuariosId", "Ativo", "AtualizadoEm", "Cpf", "CriadoEm", "Email", "NomeCompleto", "PerfilId", "SenhaHash", "Telefone", "TokenExpiracao", "TokenRedefinicaoSenha" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0000-000000000001"), true, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "admin@baseapi.com", "Administrador do Sistema", 1, "$2a$11$OEmfV3ruyKXQL0ldgJSm6O3Tg0LUy8xB87K7WRhIh44SYdb8psWre", "", null, null },
                    { new Guid("11111111-1111-1111-1111-111111111111"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "12569348712", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "gabrieli.arpini@gmail.com", "Gabrieli Arpini", 3, "$2a$11$yYHCfB6giS5eLGIlnJL9puKeqgR0F0l/ytyUe1VSGYfm9ZiyOF.By", "27998123456", null, null },
                    { new Guid("22222222-2222-2222-2222-222222222222"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "38495127604", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "lucashenriquef@gmail.com", "Lucas Henrique Ferreira", 3, "$2a$11$/wrcEU1JR8f3GtnTYdcJtulVnkjtreCFuHdMZ7OFLCDKTb7o5fhzC", "27998254731", null, null },
                    { new Guid("33333333-3333-3333-3333-333333333333"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "56381927401", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "mariana.oliveira@gmail.com", "Mariana Oliveira Santos", 3, "$2a$11$bQyMwvC97Tygb9hhHOytV.QcNNglD.NZcHc2YFLxsdq7YkTDMv9sC", "27998361425", null, null },
                    { new Guid("44444444-4444-4444-4444-444444444444"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "71438296510", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "pedro.henrique.a@gmail.com", "Pedro Henrique Almeida", 3, "$2a$11$4BQmYCxM2YWULXLugu20qOIjQQy6CLjnbqy9FpjORA5k8yI8nwUBC", "27998472516", null, null },
                    { new Guid("55555555-5555-5555-5555-555555555555"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "29617483592", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "anacarolinalima@gmail.com", "Ana Carolina Lima", 3, "$2a$11$cIFfDAbHEm4teZSinw24rOo0U9NqbqGj5ppqh67cD6T0.A1EKdZX.", "27998581342", null, null },
                    { new Guid("66666666-6666-6666-6666-666666666666"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "84752063198", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "rafael.costa@gmail.com", "Rafael Costa Pereira", 3, "$2a$11$M8wfhKLP2Ja1LpN0jj2WquAso99QTttbuUHtgaBxv7oviylA8xFsq", "27998693574", null, null },
                    { new Guid("77777777-7777-7777-7777-777777777777"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "53069182477", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "julianamartins@gmail.com", "Juliana Martins Rocha", 3, "$2a$11$iz4U/Ap46YFWfjIYo2cF8uyVAtiwsTV.hdFqLofAS39lrE7PKCKLi", "27998714653", null, null },
                    { new Guid("88888888-8888-8888-8888-888888888888"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "18240795634", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "felipe.almeida@gmail.com", "Felipe Augusto Almeida", 3, "$2a$11$5o/UZ2PqF5CXIkkkNkh/qOfKOjyjq/EzfiGbgD0dA8avbyljVmKei", "27998835791", null, null },
                    { new Guid("99999999-9999-9999-9999-999999999999"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "40528691375", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "beatriz.gomes@gmail.com", "Beatriz Gomes da Silva", 3, "$2a$11$DfkzQPZjzLzxo0xmTjGW6ukR7RrTim0779u8dWOAydeaost0BXCby", "27998926418", null, null },
                    { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "69135824780", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "gustavo.ribeiro@gmail.com", "Gustavo Ribeiro Nascimento", 3, "$2a$11$mxKrMry9aarkBHROrX6OBuKUG41vkZeEom8TpMPqr83p7Bu9auBde", "27999047185", null, null }
                });

            migrationBuilder.InsertData(
                table: "reservas",
                columns: new[] { "ReservasId", "DataAgendada", "HorarioAgendado", "QuadraId", "Status", "UsuarioId" },
                values: new object[,]
                {
                    { new Guid("70000000-0000-0000-0000-000000000001"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 8, 0, 0, 0), new Guid("33333333-3333-3333-3333-333333333333"), "Ativa", new Guid("88888888-8888-8888-8888-888888888888") },
                    { new Guid("70000000-0000-0000-0000-000000000002"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 9, 0, 0, 0), new Guid("33333333-3333-3333-3333-333333333333"), "Ativa", new Guid("88888888-8888-8888-8888-888888888888") },
                    { new Guid("70000000-0000-0000-0000-000000000003"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 10, 0, 0, 0), new Guid("44444444-4444-4444-4444-444444444444"), "Ativa", new Guid("88888888-8888-8888-8888-888888888888") },
                    { new Guid("70000000-0000-0000-0000-000000000004"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 11, 0, 0, 0), new Guid("44444444-4444-4444-4444-444444444444"), "Ativa", new Guid("88888888-8888-8888-8888-888888888888") },
                    { new Guid("70000000-0000-0000-0000-000000000005"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 14, 0, 0, 0), new Guid("55555555-5555-5555-5555-555555555555"), "Ativa", new Guid("88888888-8888-8888-8888-888888888888") },
                    { new Guid("70000000-0000-0000-0000-000000000006"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 16, 0, 0, 0), new Guid("66666666-6666-6666-6666-666666666666"), "Ativa", new Guid("88888888-8888-8888-8888-888888888888") }
                });

            migrationBuilder.CreateIndex(
                name: "IX_data_horario_reservas_QuadraId_Data_Horario",
                table: "data_horario_reservas",
                columns: new[] { "QuadraId", "Data", "Horario" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_perfis_Nome",
                table: "perfis",
                column: "Nome",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reservas_QuadraId_DataAgendada_HorarioAgendado",
                table: "reservas",
                columns: new[] { "QuadraId", "DataAgendada", "HorarioAgendado" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reservas_UsuarioId",
                table: "reservas",
                column: "UsuarioId");

            migrationBuilder.CreateIndex(
                name: "IX_usuarios_Cpf",
                table: "usuarios",
                column: "Cpf",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_usuarios_Email",
                table: "usuarios",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_usuarios_PerfilId",
                table: "usuarios",
                column: "PerfilId");

            migrationBuilder.CreateIndex(
                name: "IX_vigilantes_Cpf",
                table: "vigilantes",
                column: "Cpf",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_vigilantes_Email",
                table: "vigilantes",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "dados_secretaria");

            migrationBuilder.DropTable(
                name: "data_horario_reservas");

            migrationBuilder.DropTable(
                name: "notificacoes");

            migrationBuilder.DropTable(
                name: "reservas");

            migrationBuilder.DropTable(
                name: "vigilantes");

            migrationBuilder.DropTable(
                name: "quadras");

            migrationBuilder.DropTable(
                name: "usuarios");

            migrationBuilder.DropTable(
                name: "perfis");
        }
    }
}
