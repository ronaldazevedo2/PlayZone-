using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Domain.Entidades
{
   public class Reserva
    {
        public Guid Id { get; set; }

        public Guid QuadraId { get; set; }

        public DateTime DataAgendada { get; set; }

        public TimeSpan HorarioAgendado { get; set; }

    }
}
