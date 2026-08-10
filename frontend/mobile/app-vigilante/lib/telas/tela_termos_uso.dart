import 'package:flutter/material.dart';

class TelaTermosUso extends StatelessWidget {
  const TelaTermosUso({super.key});

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
          "TERMOS DE USO",
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
              "Termos de Uso da PlayZone",
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
              "1. Aceitação dos Termos\n"
              "Ao acessar e utilizar o aplicativo PlayZone Vigilante, você concorda em cumprir e estar vinculado a estes Termos de Uso. Este aplicativo é de uso exclusivo para vigilantes e administradores autorizados da Arena PlayZone.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              "2. Uso Autorizado e Responsabilidades\n"
              "O vigilante é responsável por manter a confidencialidade de suas credenciais de acesso. Toda leitura de QR Code e liberação de entrada registrada através do seu login será atribuída a você para fins de auditoria e segurança interna.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              "3. Sigilo e Proteção de Dados de Clientes\n"
              "O vigilante assume o compromisso de não divulgar, copiar ou transferir quaisquer dados de identificação, fotos ou informações de reservas dos clientes visualizados no aplicativo para terceiros sob nenhuma circunstância.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              "4. Rescisão de Acesso\n"
              "A PlayZone reserva-se o direito de suspender ou encerrar imediatamente o seu acesso ao aplicativo em caso de descumprimento de qualquer política de segurança da empresa ou indício de atividade fraudulenta.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
            ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 12),
            Center(
              child: Text(
                "Em caso de dúvidas, contate o administrador do sistema PlayZone.",
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
