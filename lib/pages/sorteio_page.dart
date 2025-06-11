import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/jogador.dart';
import '../../models/time.dart';
import '../../services/jogador_service.dart';
import '../../services/sorteio_service.dart';
import '../../widgets/jogador_card.dart';
import 'times_page.dart';

class SorteioPage extends StatefulWidget {
  const SorteioPage({super.key});

  @override
  State<SorteioPage> createState() => _SorteioPageState();
}

class _SorteioPageState extends State<SorteioPage> with TickerProviderStateMixin {
  List<Jogador> _todosJogadores = [];
  List<Jogador> _jogadoresSelecionados = [];
  bool _isLoading = true;
  bool _isSorteando = false;
  
  late AnimationController _fadeController;
  late AnimationController _sorteioController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sorteioAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sorteioController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _sorteioAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sorteioController,
      curve: Curves.elasticOut,
    ));
    
    _carregarJogadores();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _sorteioController.dispose();
    super.dispose();
  }

  Future<void> _carregarJogadores() async {
    setState(() => _isLoading = true);
    
    try {
      final jogadores = await JogadorService.getJogadores();
      if (mounted) {
        setState(() {
          _todosJogadores = jogadores;
          _jogadoresSelecionados = List.from(jogadores);
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar jogadores: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timesFormados = _jogadoresSelecionados.length ~/ 6;
    final jogadoresSobra = _jogadoresSelecionados.length % 6;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Sorteio de Times',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Carregando jogadores...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header com informações do sorteio
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(20.0),
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.shuffle,
                                color: colorScheme.primary,
                                size: 32.0,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Configuração do Sorteio',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Selecione os jogadores que participarão',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20.0),
                        
                        // Estatísticas
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.people,
                                label: 'Selecionados',
                                value: _jogadoresSelecionados.length.toString(),
                                color: colorScheme.primary,
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.groups,
                                label: 'Times',
                                value: timesFormados.toString(),
                                color: colorScheme.secondary,
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.person_outline,
                                label: 'Reservas',
                                value: jogadoresSobra.toString(),
                                color: colorScheme.tertiary,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Ações rápidas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selecionarTodos(),
                            icon: Icon(
                              Icons.select_all,
                              color: colorScheme.primary,
                            ),
                            label: Text(
                              'Selecionar Todos',
                              style: TextStyle(color: colorScheme.primary),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              side: BorderSide(color: colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _limparSelecao(),
                            icon: Icon(
                              Icons.clear_all,
                              color: colorScheme.error,
                            ),
                            label: Text(
                              'Limpar Seleção',
                              style: TextStyle(color: colorScheme.error),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              side: BorderSide(color: colorScheme.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Lista de jogadores
                  Expanded(
                    child: _todosJogadores.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _todosJogadores.length,
                            itemBuilder: (context, index) {
                              final jogador = _todosJogadores[index];
                              final isSelected = _jogadoresSelecionados.contains(jogador);
                              
                              return JogadorCard(
                                jogador: jogador,
                                showActions: false,
                                isSelected: isSelected,
                                onTap: () => _toggleJogador(jogador),
                              );
                            },
                          ),
                  ),

                  // Botão de sortear
                  if (_jogadoresSelecionados.length >= 6)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: AnimatedBuilder(
                        animation: _sorteioAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_sorteioAnimation.value * 0.1),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSorteando ? null : _executarSorteio,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  elevation: _isSorteando ? 0 : 4,
                                ),
                                child: _isSorteando
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20.0,
                                            height: 20.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                colorScheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12.0),
                                          Text(
                                            'Sorteando...',
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.casino,
                                            color: colorScheme.onPrimary,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            'Sortear Times (${_jogadoresSelecionados.length} jogadores)',
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  if (_jogadoresSelecionados.length < 6)
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: colorScheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.error,
                            size: 20.0,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              'Selecione pelo menos 6 jogadores para formar times',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.0,
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 10.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add,
                size: 64.0,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Nenhum jogador encontrado',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Cadastre jogadores para poder sortear times',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleJogador(Jogador jogador) {
    setState(() {
      if (_jogadoresSelecionados.contains(jogador)) {
        _jogadoresSelecionados.remove(jogador);
      } else {
        _jogadoresSelecionados.add(jogador);
      }
    });
  }

  void _selecionarTodos() {
    setState(() {
      _jogadoresSelecionados = List.from(_todosJogadores);
    });
  }

  void _limparSelecao() {
    setState(() {
      _jogadoresSelecionados.clear();
    });
  }

  Future<void> _executarSorteio() async {
    if (_jogadoresSelecionados.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione pelo menos 6 jogadores'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isSorteando = true);
    _sorteioController.reset();
    _sorteioController.forward();

    // Simular delay do sorteio
    await Future.delayed(const Duration(seconds: 2));

    try {
      final times = SorteioService.sortearTimes(_jogadoresSelecionados);
      
      if (mounted) {
        setState(() => _isSorteando = false);
        
        // Navegar para a página de times
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TimesPage(
              times: times,
              jogadoresSobra: SorteioService.getJogadoresSobra(
                _jogadoresSelecionados, 
                times,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSorteando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sortear times: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}