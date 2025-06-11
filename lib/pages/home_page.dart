import 'package:flutter/material.dart';
import 'package:futebol_wallace/pages/cadastro_jogador_page.dart';
import 'package:futebol_wallace/services/jogador_service.dart';
import 'package:futebol_wallace/pages/lista_jogadores_page.dart';
import 'package:futebol_wallace/pages/sorteio_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _totalJogadores = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadJogadores();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadJogadores() async {
    final jogadores = await JogadorService.getJogadores();
    if (mounted) {
      setState(() {
        _totalJogadores = jogadores.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '⚽ Soccer Teams',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 15.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 64.0,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Sorteio de Times',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Organize times balanceados para suas partidas',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32.0),
              
              // Stats Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: colorScheme.tertiary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.people,
                      label: 'Jogadores',
                      value: _totalJogadores.toString(),
                      theme: theme,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                    _buildStatItem(
                      icon: Icons.groups,
                      label: 'Times Possíveis',
                      value: (_totalJogadores ~/ 6).toString(),
                      theme: theme,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32.0),
              
              // Action Buttons
              _buildActionButton(
                context: context,
                icon: Icons.person_add,
                title: 'Cadastrar Jogador',
                subtitle: 'Adicione novos jogadores ao sistema',
                color: colorScheme.primary,
                onTap: () => _navigateToPage(const CadastroJogadorPage()),
              ),
              
              const SizedBox(height: 16.0),
              
              _buildActionButton(
                context: context,
                icon: Icons.list,
                title: 'Gerenciar Jogadores',
                subtitle: 'Visualize e edite a lista de jogadores',
                color: colorScheme.secondary,
                onTap: () => _navigateToPage(const ListaJogadoresPage()),
              ),
              
              const SizedBox(height: 16.0),
              
              _buildActionButton(
                context: context,
                icon: Icons.shuffle,
                title: 'Sortear Times',
                subtitle: 'Forme times balanceados automaticamente',
                color: colorScheme.tertiary,
                onTap: _totalJogadores >= 6 
                    ? () => _navigateToPage(const SorteioPage())
                    : null,
                enabled: _totalJogadores >= 6,
              ),
              
              if (_totalJogadores < 6) ...[
                const SizedBox(height: 16.0),
                Container(
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
                          'Cadastre pelo menos 6 jogadores para poder sortear times',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32.0,
          color: theme.colorScheme.tertiary,
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: enabled 
                ? colorScheme.surface 
                : colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: enabled 
                  ? color.withOpacity(0.3) 
                  : colorScheme.outline.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: enabled ? [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: enabled 
                      ? color.withOpacity(0.15) 
                      : colorScheme.outline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  icon,
                  color: enabled ? color : colorScheme.outline,
                  size: 28.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled 
                            ? colorScheme.onSurface 
                            : colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: enabled 
                            ? colorScheme.onSurface.withOpacity(0.7) 
                            : colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.outline,
                  size: 16.0,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToPage(Widget page) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
    _loadJogadores(); // Recarrega dados ao voltar
  }
}