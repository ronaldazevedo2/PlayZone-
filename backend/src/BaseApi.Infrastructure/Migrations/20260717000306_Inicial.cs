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
                    ImagemUrl = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: false)
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
                    FotoPerfil = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: false)
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
                    Id = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    NomeCompleto = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Email = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false)
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
                    table.PrimaryKey("PK_usuarios", x => x.Id);
                    table.ForeignKey(
                        name: "FK_usuarios_perfis_PerfilId",
                        column: x => x.PerfilId,
                        principalTable: "perfis",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "reservas",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    QuadraId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    DataAgendada = table.Column<DateTime>(type: "date", nullable: false),
                    HorarioAgendado = table.Column<TimeSpan>(type: "time", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reservas", x => x.Id);
                    table.ForeignKey(
                        name: "FK_reservas_quadras_QuadraId",
                        column: x => x.QuadraId,
                        principalTable: "quadras",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.InsertData(
                table: "dados_secretaria",
                columns: new[] { "SecretariaId", "Bairro", "Cep", "Cidade", "Contato", "Email", "Endereço", "Nome", "Numero" },
                values: new object[,]
                {
                    { new Guid("11111111-1111-1111-1111-111111111111"), "Centro", "01001000", "São Paulo", "(11) 99999-9999", "esportes@prefeitura.com", "Rua das Flores", "Secretaria Municipal de Esportes", "100" },
                    { new Guid("22222222-2222-2222-2222-222222222222"), "Jardim América", "02002000", "São Paulo", "(11) 98888-8888", "educacao@prefeitura.com", "Av. Brasil", "Secretaria Municipal de Educação", "250" }
                });

            migrationBuilder.InsertData(
                table: "perfis",
                columns: new[] { "Id", "Descricao", "Nome" },
                values: new object[,]
                {
                    { 1, "Acesso total ao sistema", "Admin" },
                    { 2, "Acesso intermediário ao sistema", "Gerente" },
                    { 3, "Acesso básico ao sistema", "Usuário" }
                });

            migrationBuilder.InsertData(
                table: "quadras",
                columns: new[] { "Id", "Capacidade", "Descricao", "ImagemUrl", "Localizacao", "Modalidade", "Nome" },
                values: new object[,]
                {
                    { new Guid("33333333-3333-3333-3333-333333333333"), 20, "Ginásio Poliesportivo localizado no bairro São José.", "https://www.aecweb.com.br/revista/materias/projetando-areas-esportivas-conheca-os-materiais-mais-indicados/6698", "São José", "Futebol", "GINÁSIO POLIESPORTIVO \"EURICO GUILHERME SCHULZ\"" },
                    { new Guid("44444444-4444-4444-4444-444444444444"), 20, "Ginásio Poliesportivo localizado no bairro Aviso.", "https://www.newquadras.com.br/images/Projetos/Fotos/ESCOLA%20IPSG%20(2).jpg", "Aviso", "Futebol", "GINÁSIO POLIESPORTIVO BAIRRO AVISO" },
                    { new Guid("55555555-5555-5555-5555-555555555555"), 20, "Ginásio Poliesportivo localizado no bairro Interlagos.", "https://exemplo.com/imagens/interlagos.jpg", "Interlagos", "Futebol", "GINÁSIO POLIESPORTIVO \"LEANDRO SILVA DOS REIS\"" },
                    { new Guid("66666666-6666-6666-6666-666666666666"), 20, "Ginásio Poliesportivo localizado no bairro Araçá.", "https://exemplo.com/imagens/araca.jpg", "Araçá", "Futebol", "GINÁSIO POLIESPORTIVO BAIRRO ARAÇÁ" }
                });

            migrationBuilder.InsertData(
                table: "vigilantes",
                columns: new[] { "Id", "Arena", "Ativo", "AtualizadoEm", "Cpf", "CriadoEm", "DataNascimento", "Email", "FotoPerfil", "Matricula", "NomeCompleto", "Telefone" },
                values: new object[,]
                {
                    { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), "Arena Central", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "12345678901", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1988, 5, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "carlos.silva@playzone.com", "https://exemplo.com/fotos/carlos.jpg", "VIG001", "Carlos Eduardo Silva", "(11) 99999-1111" },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), "Arena Norte", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "98765432100", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1992, 8, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "marcos.souza@playzone.com", "https://exemplo.com/fotos/marcos.jpg", "VIG002", "Marcos Antônio Souza", "(11) 99999-2222" },
                    { new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), "Arena Sul", true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "45678912345", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1995, 2, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "fernanda.oliveira@playzone.com", "https://exemplo.com/fotos/fernanda.jpg", "VIG003", "Fernanda Oliveira", "(11) 99999-3333" }
                });

            migrationBuilder.InsertData(
                table: "reservas",
                columns: new[] { "Id", "DataAgendada", "HorarioAgendado", "QuadraId" },
                values: new object[,]
                {
                    { new Guid("70000000-0000-0000-0000-000000000001"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 8, 0, 0, 0), new Guid("33333333-3333-3333-3333-333333333333") },
                    { new Guid("70000000-0000-0000-0000-000000000002"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 9, 0, 0, 0), new Guid("33333333-3333-3333-3333-333333333333") },
                    { new Guid("70000000-0000-0000-0000-000000000003"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 10, 0, 0, 0), new Guid("44444444-4444-4444-4444-444444444444") },
                    { new Guid("70000000-0000-0000-0000-000000000004"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 11, 0, 0, 0), new Guid("44444444-4444-4444-4444-444444444444") },
                    { new Guid("70000000-0000-0000-0000-000000000005"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 14, 0, 0, 0), new Guid("55555555-5555-5555-5555-555555555555") },
                    { new Guid("70000000-0000-0000-0000-000000000006"), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 16, 0, 0, 0), new Guid("66666666-6666-6666-6666-666666666666") }
                });

            migrationBuilder.InsertData(
                table: "usuarios",
                columns: new[] { "Id", "Ativo", "AtualizadoEm", "CriadoEm", "Email", "NomeCompleto", "PerfilId", "SenhaHash", "TokenExpiracao", "TokenRedefinicaoSenha" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0000-000000000001"), true, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "admin@baseapi.com", "Administrador do Sistema", 1, "$2a$11$wfecw7J8NUgBI8r/aHTVcuwPdMKrDcjNcQixHNl97DJYMztOuDVUi", null, null },
                    { new Guid("77777777-7777-7777-7777-777777777777"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "admin@playzone.com", "Administrador", 1, "$2a$11$PV12jhl97mf5r/yi46FQ7eBoQml2mrOlKZDoCo2tx8ejgWrYxhBYG", null, null },
                    { new Guid("88888888-8888-8888-8888-888888888888"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "joao@playzone.com", "João Silva", 2, "$2a$11$wKuK.WDBn0/DaTvqEy3Ww.qgd4tDQIN8PKQzsN0rPv4W3kNqaVbjK", null, null },
                    { new Guid("99999999-9999-9999-9999-999999999999"), true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "maria@playzone.com", "Maria Souza", 3, "$2a$11$4Ht8XgkTRmlfvDc1eq1OV.4rv36NVStzCT1.ds4GzCXrnj0inyEyO", null, null }
                });

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
                name: "reservas");

            migrationBuilder.DropTable(
                name: "usuarios");

            migrationBuilder.DropTable(
                name: "vigilantes");

            migrationBuilder.DropTable(
                name: "quadras");

            migrationBuilder.DropTable(
                name: "perfis");
        }
    }
}
