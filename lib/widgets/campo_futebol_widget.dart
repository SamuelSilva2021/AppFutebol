import 'package:flutter/material.dart';
import 'dart:math';
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
  
  // Novo mapa para armazenar as posições dinâmicas dos jogadores
  final Map<String, Offset> _playerPositions = {}; // id do jogador -> posição relativa (0.0 a 1.0)

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

    // Inicializa as posições dos jogadores
    _initializePlayerPositions();
  }

  @override
  void didUpdateWidget(covariant CampoFutebolWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinicializa as posições se os times mudaram
    // Compara se as listas de times são diferentes (por tamanho ou ID dos jogadores)
    if (widget.times.length != oldWidget.times.length ||
        !_areTeamsEffectivelyEqual(widget.times, oldWidget.times)) {
      _playerPositions.clear(); // Limpa as posições antigas
      _initializePlayerPositions();
    }
  }

  // Método auxiliar para comparar times (pode ser otimizado se precisar de mais granularidade)
  bool _areTeamsEffectivelyEqual(List<Time> newTeams, List<Time> oldTeams) {
    if (newTeams.length != oldTeams.length) return false;
    for (int i = 0; i < newTeams.length; i++) {
      if (newTeams[i].nome != oldTeams[i].nome ||
          newTeams[i].jogadores.length != oldTeams[i].jogadores.length) {
        return false;
      }
      // Poderia adicionar uma comparação mais profunda dos IDs dos jogadores se necessário
    }
    return true;
  }

  // Novo método para inicializar as posições
  void _initializePlayerPositions() {
    // Posições padrão para 6 jogadores (do menor para o maior overall)
    final defaultPositions = [
      const Offset(0.05, 0.45),   // Posição para o Goleiro (menor overall)
      const Offset(0.2, 0.15),    // Posição para Zagueiro 1 (2º menor overall)
      const Offset(0.2, 0.75),    // Posição para Zagueiro 2 (3º menor overall)
      const Offset(0.50, 0.50),   // Posição para Meio-campo 1 (4º menor overall)
      const Offset(0.70, 0.15),   // Posição para Meio-campo 2 (5º menor overall)
      const Offset(0.70, 0.75),   // Posição para Atacante (maior overall)
    ];

    for (final time in widget.times) {
      // Cria uma cópia e ordena os jogadores do time por overall (do menor para o maior)
      final jogadoresDoTimeOrdenados = List<Jogador>.from(time.jogadores)
        ..sort((a, b) => a.overall.compareTo(b.overall));

      for (int i = 0; i < jogadoresDoTimeOrdenados.length; i++) {
        final jogador = jogadoresDoTimeOrdenados[i];
        if (!_playerPositions.containsKey(jogador.id)) {
          // Atribui a posição fixa baseada na ordem de overall
          final pos = i < defaultPositions.length
              ? defaultPositions[i]
              : Offset(
                  0.5 + (i % 2 == 0 ? 0.1 : -0.1),
                  0.5 + (i % 3 == 0 ? 0.1 : -0.1),
                );
          _playerPositions[jogador.id] = pos;
        }
      }
    }
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
                child: LayoutBuilder( // Usar LayoutBuilder para obter o tamanho do campo
                  builder: (context, constraints) {
                    final campoWidth = constraints.maxWidth;
                    final campoHeight = constraints.maxHeight;

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 3.0,
                        ),
                      ),
                      child: CustomPaint(
                        painter: CampoPainter(),
                        child: DragTarget<Jogador>( // O campo é um DragTarget
                          builder: (context, candidateData, rejectedData) {
                            return Stack(
                              children: time.jogadores.map((jogador) {
                                // Obtém a posição do jogador do estado
                                final position = _playerPositions[jogador.id] ?? Offset.zero;

                                // Calcula as posições left e top baseadas nas dimensões do campo
                                final double left = position.dx * campoWidth;
                                final double top = position.dy * campoHeight;

                                return Positioned(
                                  left: left - 25, // Ajuste para centralizar o círculo (metade da largura do jogador)
                                  top: top - 25,  // Ajuste para centralizar o círculo (metade da altura do jogador)
                                  child: Draggable<Jogador>( // Cada jogador é um Draggable
                                    data: jogador,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: _buildJogadorWidget(jogador, corTime),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.5,
                                      child: _buildJogadorWidget(jogador, corTime),
                                    ),
                                    child: _buildJogadorWidget(jogador, corTime),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          onWillAcceptWithDetails: (details) => true, // Aceita qualquer jogador
                          onAcceptWithDetails: (details) {
                            setState(() {
                              // Converte a posição global para a posição relativa ao DragTarget
                              final RenderBox renderBox = context.findRenderObject() as RenderBox;
                              final Offset localOffset = renderBox.globalToLocal(details.offset);

                              // Calcula a nova posição percentual (0.0 a 1.0)
                              final newRelativeX = localOffset.dx / campoWidth;
                              final newRelativeY = localOffset.dy / campoHeight;
                              
                              // Atualiza a posição do jogador no mapa
                              _playerPositions[details.data.id] = Offset(newRelativeX, newRelativeY);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJogadorWidget(Jogador jogador, Color corTime) {
    final theme = Theme.of(context);
    
    return Column(
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
              jogador.nome.substring(0, 1).toUpperCase(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        // Nome do jogador (opcional, pode ser removido se ocupar muito espaço)
        Text(
          jogador.nome.split(' ').first, // Exibe apenas o primeiro nome
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
    // Definir as cores do campo
    final fieldColor = Colors.green.shade500; // Cor principal do campo
    final lineColor = Colors.white; // Cor das linhas

    // Pincel para preencher o fundo do campo
    final fieldBackgroundPaint = Paint()
      ..color = fieldColor
      ..style = PaintingStyle.fill;

    // Aplicar clip para respeitar o borderRadius do Container pai
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(16.0)));

    // Preencher o fundo de todo o campo primeiro
    canvas.drawRect(Offset.zero & size, fieldBackgroundPaint);

    // Pincel para as linhas do campo (contorno)
    final whitePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Pincel para o ponto central (preenchido)
    final filledWhitePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // Linhas do campo
    canvas.drawRect(Offset.zero & size, whitePaint); // Campo principal

    final center = Offset(size.width / 2, size.height / 2);

    // Linha do meio
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), whitePaint);

    // Círculo central
    canvas.drawCircle(center, size.width * 0.15, whitePaint);

    // Ponto central
    canvas.drawCircle(center, 3.0, filledWhitePaint);

    // Áreas do gol (preencher com a cor do campo e depois desenhar as linhas)
    final areaWidth = size.width * 0.15;
    final areaHeight = size.height * 0.4;

    // Pincel para preencher as áreas do gol com a mesma cor do campo
    final goalAreaFillPaint = Paint()
      ..color = fieldColor
      ..style = PaintingStyle.fill;

    // Área esquerda
    canvas.drawRect(Rect.fromLTWH(0, (size.height - areaHeight) / 2, areaWidth, areaHeight), goalAreaFillPaint);
    canvas.drawRect(Rect.fromLTWH(0, (size.height - areaHeight) / 2, areaWidth, areaHeight), whitePaint);

    // Área direita
    canvas.drawRect(Rect.fromLTWH(size.width - areaWidth, (size.height - areaHeight) / 2, areaWidth, areaHeight), goalAreaFillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - areaWidth, (size.height - areaHeight) / 2, areaWidth, areaHeight), whitePaint);

    // Pequenas áreas do gol
    final smallAreaWidth = size.width * 0.05;
    final smallAreaHeight = size.height * 0.2;

    canvas.drawRect(Rect.fromLTWH(0, (size.height - smallAreaHeight) / 2, smallAreaWidth, smallAreaHeight), goalAreaFillPaint);
    canvas.drawRect(Rect.fromLTWH(0, (size.height - smallAreaHeight) / 2, smallAreaWidth, smallAreaHeight), whitePaint);

    canvas.drawRect(Rect.fromLTWH(size.width - smallAreaWidth, (size.height - smallAreaHeight) / 2, smallAreaWidth, smallAreaHeight), goalAreaFillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - smallAreaWidth, (size.height - smallAreaHeight) / 2, smallAreaWidth, smallAreaHeight), whitePaint);

    // Arcos das áreas
    final goalArcRadius = size.width * 0.08;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(areaWidth, center.dy), radius: goalArcRadius),
      -pi / 2,
      pi,
      false,
      whitePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - areaWidth, center.dy), radius: goalArcRadius),
      pi / 2,
      pi,
      false,
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

extension on FractionalOffset {
  Widget withinOffset({required Widget child}) {
    return Transform.translate(
      offset: Offset.zero,
      child: child,
    );
  }
}