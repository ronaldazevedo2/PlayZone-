namespace BaseApi.Domain.Entidades
{
    /// <summary>
    /// Entidade que representa um aparelho de Notificacao no catálogo.
    /// </summary>
    public class Notificacao
    {
        public DateTime CriadoEm { get; set; } = DateTime.UtcNow;

        public DateTime AtualizadoEm { get; set; } = DateTime.UtcNow;
        public object? Id { get; set; }
    }
}