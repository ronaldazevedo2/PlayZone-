import 'package:flutter/material.dart';
import '../estado_central.dart';

class TelaSplash extends StatefulWidget {
  const TelaSplash({super.key});

  @override
  State<TelaSplash> createState() => _TelaSplashEstado();
}

class _TelaSplashEstado extends State<TelaSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controladorAnimacao;
  late Animation<double> _animacaoFade;
  late Animation<double> _animacaoEscala;
  late Animation<double> _animacaoSlide;

  @override
  void initState() {
    super.initState();

    _controladorAnimacao = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animacaoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controladorAnimacao,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animacaoEscala = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controladorAnimacao,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _animacaoSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controladorAnimacao,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controladorAnimacao.forward();

    // Após animação, verifica sessão salva
    Future.delayed(const Duration(milliseconds: 2200), _verificarSessao);
  }

  @override
  void dispose() {
    _controladorAnimacao.dispose();
    super.dispose();
  }

  Future<void> _verificarSessao() async {
    if (!mounted) return;

    final estadoCentral = EstadoCentral();
    final temSessao = await estadoCentral.restaurarSessao();

    if (!mounted) return;

    if (temSessao) {
      // Vigilante já estava logado — vai direto para a tela principal
      Navigator.of(context).pushReplacementNamed('/principal');
    } else {
      // Nenhuma sessão ativa — vai para o login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF09398E),
              Color(0xFF0B1E4A),
              Color(0xFF051230),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controladorAnimacao,
            builder: (context, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Logo animado
                      Opacity(
                        opacity: _animacaoFade.value,
                        child: Transform.scale(
                          scale: _animacaoEscala.value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0B7F38).withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 120,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.shield,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Textos animados
                      Opacity(
                        opacity: _animacaoFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _animacaoSlide.value),
                          child: Column(
                            children: [
                              const Text(
                                'PLAYZONE',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white54,
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'VIGILANTE',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Controle de acesso inteligente\npara sua arena esportiva.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.7),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Indicador de carregamento
                      Opacity(
                        opacity: _animacaoFade.value,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF0B7F38).withOpacity(0.9),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Verificando sessão...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
