using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BaseApi.Infrastructure.Migrations
{
    public partial class AdicionarCpfETelefoneUsuario : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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

            migrationBuilder.CreateIndex(
                name: "IX_usuarios_Cpf",
                table: "usuarios",
                column: "Cpf",
                unique: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_usuarios_Cpf",
                table: "usuarios");

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
    }
}