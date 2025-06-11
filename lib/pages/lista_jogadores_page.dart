import 'package:flutter/material.dart';
import 'package:futebol_wallace/widgets/jogador_card.dart';
import 'package:futebol_wallace/services/jogador_service.dart';
import '../../models/jogador.dart';
import 'cadastro_jogador_page.dart';

class ListaJogadoresPage extends StatefulWidget {
  const ListaJogadoresPage({super.key});

  @override
  State<ListaJogadoresPage> createState() => _ListaJogadoresPageState();
}

class _ListaJogadoresPageState extends State<ListaJogadoresPage> 
    with TickerProviderStateMixin {
  List<Jogador> _jogadores = [];
  List<Jogador> _jogadoresFiltrados = [];
  bool _isLoading = true;
  String _filtro = '';
  String _ordenacao = 'nome';
  
  late AnimationController _listController;
  late Animation<double> _listAnimation;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeInOut,
    ));
    _carregarJogadores();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _carregarJogadores() async {
    setState(() => _isLoading = true);
    
    try {
      final jogadores = await JogadorService.getJogadores();
      if (mounted) {
        setState(() {
          _jogadores = jogadores;
          _aplicarFiltroEOrdenacao();
          _isLoading = false;
        });
        _listController.forward();
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

  void _aplicarFiltroEOrdenacao() {
    List<Jogador> resultado = _jogadores;

    // Aplicar filtro
    if (_filtro.isNotEmpty) {
      resultado = resultado.where((jogador) =>
          jogador.nome.toLowerCase().contains(_filtro.toLowerCase())).toList();
    }

    // Aplicar ordenação
    switch (_ordenacao) {
      case 'nome':
        resultado.sort((a, b) => a.nome.compareTo(b.nome));
        break;
      case 'overall_desc':
        resultado.sort((a, b) => b.overall.compareTo(a.overall));
        break;
      case 'overall_asc':
        resultado.sort((a, b) => a.overall.compareTo(b.overall));
        break;
    }

    setState(() => _jogadoresFiltrados = resultado);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Jogadores',
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
            onPressed: () => _navegarParaCadastro(),
            icon: Icon(
              Icons.person_add,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com estatísticas
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
            child: Row(
              children: [
                Icon(
                  Icons.groups,
                  size: 40.0,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_jogadores.length} jogadores cadastrados',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (_jogadores.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          'Overall médio: ${(_jogadores.map((j) => j.overall).reduce((a, b) => a + b) / _jogadores.length).toStringAsFixed(1)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Controles de filtro e ordenação
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar jogador...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  onChanged: (value) {
                    setState(() => _filtro = value);
                    _aplicarFiltroEOrdenacao();
                  },
                ),
                
                const SizedBox(height: 12.0),
                
                // Controles de ordenação
                Row(
                  children: [
                    Text(
                      'Ordenar por:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'nome',
                            label: Text('Nome'),
                            icon: Icon(Icons.sort_by_alpha, size: 16),
                          ),
                          ButtonSegment(
                            value: 'overall_desc',
                            label: Text('Overall ↓'),
                            icon: Icon(Icons.trending_down, size: 16),
                          ),
                          ButtonSegment(
                            value: 'overall_asc',
                            label: Text('Overall ↑'),
                            icon: Icon(Icons.trending_up, size: 16),
                          ),
                        ],
                        selected: {_ordenacao},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() => _ordenacao = selection.first);
                          _aplicarFiltroEOrdenacao();
                        },
                        style: SegmentedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          selectedBackgroundColor: colorScheme.primary.withOpacity(0.1),
                          selectedForegroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(
                            color: colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          // Lista de jogadores
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
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
                : _jogadoresFiltrados.isEmpty
                    ? _buildEmptyState()
                    : FadeTransition(
                        opacity: _listAnimation,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _jogadoresFiltrados.length,
                          itemBuilder: (context, index) {
                            final jogador = _jogadoresFiltrados[index];
                            return JogadorCard(
                              jogador: jogador,
                              onEdit: () => _editarJogador(jogador),
                              onDelete: () => _confirmarExclusao(jogador),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaCadastro(),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
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
                _filtro.isNotEmpty ? Icons.search_off : Icons.group_add,
                size: 64.0,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              _filtro.isNotEmpty 
                  ? 'Nenhum jogador encontrado'
                  : 'Nenhum jogador cadastrado',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              _filtro.isNotEmpty
                  ? 'Tente ajustar os filtros de busca'
                  : 'Comece cadastrando seu primeiro jogador',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (_filtro.isEmpty) ...[
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: () => _navegarParaCadastro(),
                icon: const Icon(Icons.person_add),
                label: const Text('Cadastrar Jogador'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _navegarParaCadastro([Jogador? jogador]) async {
    final resultado = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CadastroJogadorPage(jogador: jogador),
      ),
    );
    if (resultado != null) {
      _carregarJogadores();
    }
  }

  void _editarJogador(Jogador jogador) {
    _navegarParaCadastro(jogador);
  }

  Future<void> _confirmarExclusao(Jogador jogador) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Confirmar Exclusão',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir o jogador \"${jogador.nome}\"?\n\nEsta ação não pode ser desfeita.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await _excluirJogador(jogador);
    }
  }

  Future<void> _excluirJogador(Jogador jogador) async {
    try {
      await JogadorService.deleteJogador(jogador.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jogador excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _carregarJogadores();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir jogador: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}