using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BaseApi.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class UpdateFotoPerfilMaxLength : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "FotoPerfil",
                table: "vigilantes",
                type: "longtext",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "varchar(500)",
                oldMaxLength: 500)
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                column: "SenhaHash",
                value: "$2a$11$ybSNeQz4s1RkLfJqJliDkOw/RlLDIw1H3h86sj4KFzTGiZ8Lf6kNa");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "SenhaHash",
                value: "$2a$11$phsEXOTXhrwpOB23DvRW/O1mL47MBSyoW4Kcmkxo6TvsdxVWE3SB6");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "SenhaHash",
                value: "$2a$11$i65Vh2qEwys3JCiUzDiaZeaVq8chWmVkTOjTar0LZBLO4DDY9ex/W");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "SenhaHash",
                value: "$2a$11$/H6UR9mex2GV/AxQtyGel.X.3DksbMQjxpiZh88hbqFMp3ndayv46");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "FotoPerfil",
                table: "vigilantes",
                type: "varchar(500)",
                maxLength: 500,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "longtext")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                column: "SenhaHash",
                value: "$2a$11$wfecw7J8NUgBI8r/aHTVcuwPdMKrDcjNcQixHNl97DJYMztOuDVUi");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "SenhaHash",
                value: "$2a$11$PV12jhl97mf5r/yi46FQ7eBoQml2mrOlKZDoCo2tx8ejgWrYxhBYG");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "SenhaHash",
                value: "$2a$11$wKuK.WDBn0/DaTvqEy3Ww.qgd4tDQIN8PKQzsN0rPv4W3kNqaVbjK");

            migrationBuilder.UpdateData(
                table: "usuarios",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "SenhaHash",
                value: "$2a$11$4Ht8XgkTRmlfvDc1eq1OV.4rv36NVStzCT1.ds4GzCXrnj0inyEyO");
        }
    }
}
