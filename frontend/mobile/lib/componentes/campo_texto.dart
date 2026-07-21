import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoTexto extends StatefulWidget {
  final String rotulo;
  final String dicaTexto;
  final IconData icone;
  final TextEditingController controlador;
  final FocusNode? noFoco;
  final FocusNode? proximoNoFoco;
  final bool ehSenha;
  final String? Function(String?)? validador;
  final TextInputType tipoTeclado;
  final bool somenteLeitura;
  final VoidCallback? aoClicar;
  final void Function(String)? aoSubmeter;
  final List<TextInputFormatter>? formatadores;
  final Color? corIcone;
  final IconData? iconeSufixo;
  final VoidCallback? aoClicarIconeSufixo;

  const CampoTexto({
    super.key,
    required this.rotulo,
    required this.dicaTexto,
    required this.icone,
    required this.controlador,
    this.noFoco,
    this.proximoNoFoco,
    this.ehSenha = false,
    this.validador,
    this.tipoTeclado = TextInputType.text,
    this.somenteLeitura = false,
    this.aoClicar,
    this.aoSubmeter,
    this.formatadores,
    this.corIcone,
    this.iconeSufixo,
    this.aoClicarIconeSufixo,
  });

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  late bool _senhaOculta;

  @override
  void initState() {
    super.initState();
    _senhaOculta = widget.ehSenha;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rótulo superior do campo
        Text(
          widget.rotulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        // Campo de entrada propriamente dito
        TextFormField(
          controller: widget.controlador,
          focusNode: widget.noFoco,
          obscureText: _senhaOculta,
          keyboardType: widget.tipoTeclado,
          readOnly: widget.somenteLeitura,
          onTap: widget.aoClicar,
          inputFormatters: widget.formatadores,
          textInputAction: widget.proximoNoFoco != null
              ? TextInputAction.next
              : TextInputAction.done,
          onFieldSubmitted: (valor) {
            if (widget.aoSubmeter != null) {
              widget.aoSubmeter!(valor);
            }
            if (widget.proximoNoFoco != null) {
              FocusScope.of(context).requestFocus(widget.proximoNoFoco);
            }
          },
          validator: widget.validador,
          style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: widget.dicaTexto,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
            filled: true,
            fillColor: const Color(0xFFF8FAFC), // Fundo levemente cinza
            prefixIcon: Icon(
              widget.icone,
              color:
                  widget.corIcone ??
                  const Color(0xFF22C55E), // Verde clássico ou customizado
              size: 22,
            ),
            suffixIcon: widget.ehSenha
                ? IconButton(
                    icon: Icon(
                      _senhaOculta
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF64748B),
                    ),
                    onPressed: () {
                      setState(() {
                        _senhaOculta = !_senhaOculta;
                      });
                    },
                  )
                : widget.aoClicarIconeSufixo != null
                    ? IconButton(
                        icon: Icon(
                          widget.iconeSufixo ?? Icons.calendar_today_outlined,
                          color: const Color(0xFF64748B),
                        ),
                        onPressed: widget.aoClicarIconeSufixo,
                      )
                    : widget.somenteLeitura &&
                          widget.tipoTeclado == TextInputType.datetime
                    ? const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF64748B),
                      )
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            // Bordas customizadas
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 2,
              ), // Azul primário
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
