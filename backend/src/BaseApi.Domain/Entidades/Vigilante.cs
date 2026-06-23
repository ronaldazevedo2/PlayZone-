namespace BaseApi.Domain.Entidades
{
    
    public class Vigilante
    {
        public int Id { get; set; }

        /// <summary>Nome completo do vigilante</summary>
        public string NomeCompleto { get; set; } = string.Empty;

        /// <summary>CPF do vigilante</summary>
        public string Cpf { get; set; } = string.Empty;

        /// <summary>E-mail do vigilante</summary>
        public string Email { get; set; } = string.Empty;

        /// <summary>Telefone para contato</summary>
        public string Telefone { get; set; } = string.Empty;

        /// <summary>Data de nascimento</summary>
        public DateTime DataNascimento { get; set; }

        /// <summary>Caminho ou URL da foto de perfil</summary>
        public string FotoPerfil { get; set; } = string.Empty;

        /// <summary>Status do vigilante (ativo/inativo)</summary>
        public bool Ativo { get; set; } = true;

        public DateTime CriadoEm { get; set; } = DateTime.UtcNow;

        public DateTime AtualizadoEm { get; set; } = DateTime.UtcNow;
        public string Matricula { get; set; }
        public string Arena { get; set; }
    }
}