import 'package:flutter/material.dart';
import '../models/jogador.dart';
import '../models/time.dart';

class CampoFutebolWidget extends StatefulWidget {
  final List<Time> times;
  
  const CampoFutebolWidget({
    super.key,
    required this.times,
  });

  @override
  State<CampoFutebolWidget> createState() => _CampoFutebolWidgetState();
}

class _CampoFutebolWidgetState extends State<CampoFutebolWidget> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.times.isEmpty) {
      return const Center(
        child: Text('Nenhum time para exibir'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: widget.times.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.times.length - 1 ? 32.0 : 0,
            ),
            child: _buildCampoTime(time, index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCampoTime(Time time, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final corTime = Color(int.parse(time.cor.replaceFirst('#', '0xFF')));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                corTime.withOpacity(0.1),
                corTime.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: corTime.withOpacity(0.3),
              width: 2.0,
            ),
          ),
          child: Column(
            children: [
              // Header do time
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: corTime.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: corTime.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                            color: corTime,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          time.nome,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: corTime.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Overall: ${time.overallMedio.toStringAsFixed(1)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: corTime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20.0),
              
              // Campo de futebol
              AspectRatio(
                aspectRatio: 1.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Colors.green.shade300,
                      width: 3.0,
                    ),
                  ),
                  child: CustomPaint(
                    painter: CampoPainter(),
                    child: _buildPosicionamentoJogadores(time.jogadores, corTime),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosicionamentoJogadores(List<Jogador> jogadores, Color corTime) {
    // Posições fixas no campo (percentuais da largura/altura)
    final posicoes = [
      const Offset(0.15, 0.5),  // Goleiro
      const Offset(0.35, 0.25), // Zagueiro 1
      const Offset(0.35, 0.75), // Zagueiro 2
      const Offset(0.6, 0.35),  // Meio-campo 1
      const Offset(0.6, 0.65),  // Meio-campo 2
      const Offset(0.85, 0.5),  // Atacante
    ];

    return Stack(
      children: jogadores.asMap().entries.map((entry) {
        final index = entry.key;
        final jogador = entry.value;
        
        // Se não houver posição definida para o índice, usar uma posição padrão
        final posicao = index < posicoes.length 
            ? posicoes[index] 
            : Offset(0.5 + (index % 2 == 0 ? 0.1 : -0.1), 0.5 + (index % 3 == 0 ? 0.1 : -0.1));
        
        return Positioned.fill(
          child: FractionallySizedBox(
            alignment: Alignment.topLeft,
            child: FractionalOffset(
              posicao.dx,
              posicao.dy,
            ).withinOffset(
              child: _buildJogadorWidget(jogador, corTime, index),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildJogadorWidget(Jogador jogador, Color corTime, int posicao) {
    final theme = Theme.of(context);
    final posicaoNome = _getNomePosicao(posicao);
    
    return Transform.translate(
      offset: const Offset(-35, -35), // Centralizar o widget
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar do jogador
          Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              color: corTime,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                jogador.nome.isNotEmpty 
                    ? jogador.nome[0].toUpperCase() 
                    : '?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 4.0),
          
          // Nome do jogador
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6.0,
              vertical: 2.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                color: corTime.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getNomeResumido(jogador.nome),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: corTime,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  posicaoNome,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: corTime.withOpacity(0.7),
                    fontSize: 8.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${jogador.overall}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: corTime,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getNomePosicao(int index) {
    switch (index) {
      case 0: return 'GOL';
      case 1:
      case 2: return 'ZAG';
      case 3:
      case 4: return 'MEI';
      case 5: return 'ATA';
      default: return 'JOG';
    }
  }

  String _getNomeResumido(String nomeCompleto) {
    final partes = nomeCompleto.trim().split(' ');
    if (partes.length == 1) {
      return partes[0].length > 8 
          ? '${partes[0].substring(0, 7)}.'
          : partes[0];
    }
    
    final primeiroNome = partes[0];
    final ultimoNome = partes.last;
    
    if (primeiroNome.length + ultimoNome.length <= 10) {
      return '$primeiroNome $ultimoNome';
    }
    
    return primeiroNome.length > 8 
        ? '${primeiroNome.substring(0, 7)}.'
        : primeiroNome;
  }
}

class CampoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.green.shade200.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Fundo do campo
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      fillPaint,
    );

    // Linha central
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Círculo central
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.15,
      paint,
    );

    // Área do goleiro esquerda
    final areaGolEsq = Rect.fromLTWH(
      0,
      size.height * 0.3,
      size.width * 0.15,
      size.height * 0.4,
    );
    canvas.drawRect(areaGolEsq, paint);

    // Área do goleiro direita
    final areaGolDir = Rect.fromLTWH(
      size.width * 0.85,
      size.height * 0.3,
      size.width * 0.15,
      size.height * 0.4,
    );
    canvas.drawRect(areaGolDir, paint);

    // Marca do pênalti esquerda
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height / 2),
      3.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Marca do pênalti direita
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height / 2),
      3.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on FractionalOffset {
  Widget withinOffset({required Widget child}) {
    return Transform.translate(
      offset: Offset.zero,
      child: child,
    );
  }
}