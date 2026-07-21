using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BaseApi.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AumentarTamanhoCampoNome : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "ImagemUrl",
                table: "quadras",
                type: "longtext",
                maxLength: 1000000,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "varchar(500)",
                oldMaxLength: 500)
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "Status",
                table: "quadras",
                type: "longtext",
                nullable: false)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.UpdateData(
                table: "quadras",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "Status",
                value: "Ativa");

            migrationBuilder.UpdateData(
                table: "quadras",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                column: "Status",
                value: "Ativa");

            migrationBuilder.UpdateData(
                table: "quadras",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "Status",
                value: "Ativa");

            migrationBuilder.UpdateData(
                table: "quadras",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "Status",
                value: "Ativa");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                column: "SenhaHash",
                value: "$2a$11$Rs2w12K9Jsz1DZQ2s4FQ4udFsP1F7FkJhN1DHzxwN16ZrFCPf25hy");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "SenhaHash",
                value: "$2a$11$jTLsirZPhHNnIAXwrcPx2eYKPt7bT8dZd3W122S2iJBpsSKEJnTmG");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "SenhaHash",
                value: "$2a$11$nG.5aav0E.X12cJuvKVmVuOMmVM.pPcnPHoiZgvmKEvEjfTdq5MdC");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "SenhaHash",
                value: "$2a$11$Z2reOjYx6S.CQUhU0WCbkeUaqDiL30StHpDmLgkbF0r5u3bNsX5qi");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Status",
                table: "quadras");

            migrationBuilder.AlterColumn<string>(
                name: "ImagemUrl",
                table: "quadras",
                type: "varchar(500)",
                maxLength: 500,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "longtext",
                oldMaxLength: 1000000)
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                column: "SenhaHash",
                value: "$2a$11$XlOWzVJD7e4Rswz6lMMS.e/OUt5H3kfIVpwtZNU4AdNjOWGbNKP4O");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "SenhaHash",
                value: "$2a$11$py1rW8/4XcZ4lI2izMcG4uDVrTD7PwjOupX0SE.UNPQdPLNSdgqS.");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "SenhaHash",
                value: "$2a$11$UCHE0nmY6Lc47ECZptv7T.ieURrdm6/HoSMJJvacR0LPeJJzVUIXe");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "SenhaHash",
                value: "$2a$11$7DvJgn3vOobjKBkLuL6lS.1U4lK9ifc0KLU9uYIXKU8IEXzss7ib.");
        }
    }
}
