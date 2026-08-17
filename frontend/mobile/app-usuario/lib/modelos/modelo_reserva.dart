class ModeloReserva {
  final String id;
  final String quadraId;
  final DateTime dataAgendada;
  final String horarioAgendado;

  const ModeloReserva({
    required this.id,
    required this.quadraId,
    required this.dataAgendada,
    required this.horarioAgendado,
  });

  factory ModeloReserva.deJson(Map<String, dynamic> json) {
    final rawData = (json['dataAgendada'] ?? json['DataAgendada'] ?? json['data'] ?? json['Data'] ?? json['dataReserva'] ?? json['DataReserva'])?.toString() ?? '';
    DateTime data;
    try {
      data = DateTime.parse(rawData);
    } catch (_) {
      data = DateTime.now();
    }

    final rawHorario = (json['horarioAgendado'] ?? json['HorarioAgendado'] ?? json['horario'] ?? json['Horario'] ?? json['hora'] ?? json['Hora'])?.toString() ?? '';
    final idReserva = (json['id'] ?? json['Id'] ?? json['idReserva'] ?? json['IdReserva'])?.toString() ?? '';
    final idQuadra = (json['quadraId'] ?? json['QuadraId'] ?? json['idQuadra'] ?? json['IdQuadra'])?.toString() ?? '';

    return ModeloReserva(
      id: idReserva,
      quadraId: idQuadra,
      dataAgendada: DateTime(data.year, data.month, data.day),
      horarioAgendado: _normalizarHorario(rawHorario),
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'quadraId': quadraId,
      'dataAgendada': dataAgendada.toIso8601String(),
      'horarioAgendado': horarioAgendado,
    };
  }

  static String _normalizarHorario(String horario) {
    if (horario.isEmpty) return '00:00';
    final partes = horario.split(':');
    if (partes.length >= 2) {
      final hora = partes[0].padLeft(2, '0');
      final minuto = partes[1].padLeft(2, '0');
      return '$hora:$minuto';
    }
    return horario;
  }
}
