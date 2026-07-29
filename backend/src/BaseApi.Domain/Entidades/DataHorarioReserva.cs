namespace BaseApi.Domain.Entidades
{
    public class DataHorarioReserva
    {
        public Guid DataHorarioReservaId { get; set; }
        public Guid QuadraId { get; set; }
        public DateTime Data { get; set; }
        public TimeSpan Horario { get; set; }
    }
}