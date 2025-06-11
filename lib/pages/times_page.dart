import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/jogador.dart';
import '../../models/time.dart';
import '../../services/sorteio_service.dart';
import '../../widgets/campo_futebol_widget.dart';
import '../../widgets/jogador_card.dart';

class TimesPage extends StatefulWidget {
  final List<Time> times;
  final List<Jogador> jogadoresSobra;

  const TimesPage({
    super.key,
    required this.times,
    required this.jogadoresSobra,
  });

  @override
  State<TimesPage> createState() => _TimesPageState();
}

class _TimesPageState extends State<TimesPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.times.length + (widget.jogadoresSobra.isNotEmpty ? 1 : 0),
      vsync: this,
    );
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Times Sorteados',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            onPressed: _mostrarEstatisticas,
            icon: Icon(
              Icons.analytics,
              color: colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: _compartilharResultado,
            icon: Icon(
              Icons.share,
              color: colorScheme.secondary,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: colorScheme.primary,
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            ...widget.times.map((time) => Tab(
              text: time.nome,
              icon: Container(
                width: 16.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: Color(int.parse(time.cor.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                ),
              ),
            )),
            if (widget.jogadoresSobra.isNotEmpty)
              const Tab(
                text: 'Reservas',
                icon: Icon(Icons.people_outline, size: 16),
              ),
          ],
        ),
      ),
      body: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: FadeTransition(
          opacity: _slideAnimation,
          child: Column(
            children: [
              // Header com estatísticas rápidas
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.secondary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickStat(
                      icon: Icons.groups,
                      label: 'Times',
                      value: widget.times.length.toString(),
                      color: colorScheme.primary,
                      theme: theme,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                    _buildQuickStat(
                      icon: Icons.people,
                      label: 'Jogadores',
                      value: (widget.times.fold<int>(0, (sum, time) => sum + time.jogadores.length)).toString(),
                      color: colorScheme.secondary,
                      theme: theme,
                    ),
                    if (widget.jogadoresSobra.isNotEmpty) ...[
                      Container(
                        width: 1,
                        height: 40,
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                      _buildQuickStat(
                        icon: Icons.person_outline,
                        label: 'Reservas',
                        value: widget.jogadoresSobra.length.toString(),
                        color: colorScheme.tertiary,
                        theme: theme,
                      ),
                    ],
                  ],
                ),
              ),

              // Conteúdo das abas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ...widget.times.map((time) => _buildTimeTab(time)),
                    if (widget.jogadoresSobra.isNotEmpty)
                      _buildReservasTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _novoSorteio(),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.refresh),
        label: const Text('Novo Sorteio'),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24.0,
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeTab(Time time) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final corTime = Color(int.parse(time.cor.replaceFirst('#', '0xFF')));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações do time
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: corTime.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: corTime.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: corTime.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.groups,
                    color: corTime,
                    size: 32.0,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time.nome,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${time.jogadores.length} jogadores',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: corTime.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Overall',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: corTime,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        time.overallMedio.toStringAsFixed(1),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: corTime,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // Campo visual (somente se tiver exatamente 6 jogadores)
          if (time.jogadores.length == 6) ...[
            Text(
              'Formação no Campo',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16.0),
            CampoFutebolWidget(times: [time]),
            const SizedBox(height: 24.0),
          ],

          // Lista de jogadores
          Text(
            'Jogadores do Time',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16.0),
          
          ...time.jogadores.asMap().entries.map((entry) {
            final index = entry.key;
            final jogador = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: corTime.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: corTime.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: corTime.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: corTime,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jogador.nome,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            time.jogadores.length == 6 ? _getPosicaoJogador(index) : 'Jogador',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: _getOverallColor(jogador.overall, colorScheme).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '${jogador.overall}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _getOverallColor(jogador.overall, colorScheme),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReservasTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: colorScheme.tertiary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: colorScheme.tertiary,
                  size: 32.0,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jogadores Reservas',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${widget.jogadoresSobra.length} jogadores não alocados',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24.0),

          Text(
            'Lista de Reservas',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16.0),

          Expanded(
            child: ListView.builder(
              itemCount: widget.jogadoresSobra.length,
              itemBuilder: (context, index) {
                final jogador = widget.jogadoresSobra[index];
                return JogadorCard(
                  jogador: jogador,
                  showActions: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getPosicaoJogador(int index) {
    switch (index) {
      case 0: return 'Goleiro';
      case 1:
      case 2: return 'Zagueiro';
      case 3:
      case 4: return 'Meio-campo';
      case 5: return 'Atacante';
      default: return 'Jogador';
    }
  }

  Color _getOverallColor(int overall, ColorScheme colorScheme) {
    if (overall >= 90) return Colors.green;
    if (overall >= 80) return colorScheme.secondary;
    if (overall >= 70) return colorScheme.tertiary;
    if (overall >= 60) return colorScheme.primary;
    return colorScheme.error;
  }

  void _mostrarEstatisticas() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final estatisticas = SorteioService.getEstatisticasSorteio(widget.times);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            Icon(
              Icons.analytics,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8.0),
            Text(
              'Estatísticas do Sorteio',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          estatisticas,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _compartilharResultado() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Simular compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Funcionalidade de compartilhamento seria implementada aqui'),
        backgroundColor: colorScheme.secondary,
        action: SnackBarAction(
          label: 'OK',
          textColor: colorScheme.onSecondary,
          onPressed: () {},
        ),
      ),
    );
  }

  void _novoSorteio() {
    Navigator.of(context).pop();
  }
}