import 'package:flutter/material.dart';

class TelaPoliticaPrivacidade extends StatelessWidget {
  const TelaPoliticaPrivacidade({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF09398E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "POLÍTICA DE PRIVACIDADE",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Política de Privacidade PlayZone",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF09398E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Última atualização: 21 de Julho de 2026",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "1. Coleta de Informações\n"
              "O aplicativo PlayZone Vigilante processa dados locais sobre autenticação de vigilantes e simula a leitura de QR Code contendo identificação básica de clientes (Nome, CPF, Matrícula e detalhes da quadra agendada). Nenhuma gravação externa de câmera real ou áudio é enviada para servidores terceiros sem consentimento.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              "2. Uso das Informações Coletadas\n"
              "Os dados coletados servem unicamente para registrar logs de acessos temporários na Arena, garantindo o monitoramento de ocupação e segurança física do local.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              "3. Armazenamento e Exclusão\n"
              "As informações de cadastro de vigilantes e histórico de entradas são mantidas localmente em memória temporária ou mockada para fins operacionais da arena. A exclusão de logs e dados pode ser realizada diretamente na tela de configurações.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              "4. Segurança de Dados\n"
              "Implementamos medidas técnicas adequadas para proteger os dados de acessos não autorizados. Recomendamos a ativação do Acesso Biométrico nas configurações do aplicativo para restringir acessos indevidos à tela de controle do vigilante.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
            ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 12),
            Center(
              child: Text(
                "PlayZone - Gestão e Tecnologia Esportiva.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
