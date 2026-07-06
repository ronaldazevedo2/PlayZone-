/** Envelope padrão da API */
export interface RespostaApi<T = null> {
  ok: boolean;
  mensagem: string;
  dados: T;
  erros: string[] | null;
}
