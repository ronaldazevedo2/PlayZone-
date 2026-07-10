using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Domain.Entidades
{
    public class Quadra
    {
        public Guid Id { get; set; }

        public string Nome { get; set; } = string.Empty;

        public string Descricao { get; set; } = string.Empty;

        public int Capacidade { get; set; }

        public string Localizacao { get; set; } = string.Empty;


        public string Modalidade { get; set; } = string.Empty;

        public string ImagemUrl { get; set; } = string.Empty;

        public string Status { get; set; } = "Ativa";





    }

}